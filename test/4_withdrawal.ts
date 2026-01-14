import assert from "node:assert/strict";
import { before, describe, it } from "node:test";
import { network } from "hardhat";
import { Address, checksumAddress, parseEther, zeroAddress } from "viem";
import { waitForTx } from "../utils/common.js";
import { FacetCut } from "../utils/types.js";
import { buildAddFacet, getCalldata } from "../utils/facets.js";
import { STASH_IMPL_KEY } from "../utils/consts.js";

describe("Stash Withdrawal", async function () {
  const connection = await network.connect();
  const { viem } = connection;
  const [deployer, ownerWallet, _, userWallet] = await viem.getWalletClients();

  type ContractType<S extends string> = Awaited<ReturnType<typeof viem.deployContract<S>>>;

  let lookup: ContractType<"LookupProxy">,
    lookupOps: ContractType<"LookupOps">,
    factory: ContractType<"FactoryProxy">,
    factoryOps: ContractType<"FactoryOps">,
    proxyAdmin: ContractType<"ProxyAdmin">,
    stashOps: ContractType<"StashOps">,
    stashAtOps: ContractType<"StashOps">,
    proxyAtImpl: ContractType<"FactoryOps">,
    lookupAtImpl: ContractType<"LookupOps">,
    stashAddress: Address,
    erc20: ContractType<"StashToken">,
    stashWithdrawal: ContractType<"StashWithdrawal">,
    stashAtWithdrawal: ContractType<"StashWithdrawal">;

  before(async () => {
    // deploy test ERC20 token
    erc20 = await viem.deployContract("StashToken", [], { client: { wallet: deployer } });

    // deploy factory implementation  contract
    factoryOps = await viem.deployContract("FactoryOps", [], { client: { wallet: deployer } });

    // deploy lookup implementation contract
    lookupOps = await viem.deployContract("LookupOps", [], { client: { wallet: deployer } });

    proxyAdmin = await viem.deployContract("ProxyAdmin", [ownerWallet.account.address], { client: { wallet: deployer } });

    // deploy lookup proxy contract
    lookup = await viem.deployContract("LookupProxy", [ownerWallet.account.address, proxyAdmin.address, lookupOps.address], { client: { wallet: deployer } });

    // deploy factory proxy
    factory = await viem.deployContract("FactoryProxy", [ownerWallet.account.address, proxyAdmin.address, factoryOps.address, lookup.address, 1], {
      client: { wallet: deployer },
    });
    // Attach proxy to implementation
    proxyAtImpl = await viem.getContractAt("FactoryOps", factory.address);

    lookupAtImpl = await viem.getContractAt("LookupOps", lookup.address);

    // create an stash
    // @ts-ignore
    const createStashTx = await proxyAtImpl.write.createStash({ account: userWallet.account });
    await waitForTx(connection, createStashTx);

    [[stashAddress]] = await proxyAtImpl.read.getStashes([userWallet.account.address]);

    // Deploy Stash Operations
    stashOps = await viem.deployContract("StashOps", [], { client: { wallet: deployer } });

    // Register stash operation facets
    const facets: FacetCut[] = [buildAddFacet(stashOps)];

    const regInitCallData = getCalldata(lookupAtImpl.abi, "lockImplementation", [stashOps.address, STASH_IMPL_KEY]);

    const diamondCutTx = await lookupAtImpl.write.diamondCut([facets, lookupAtImpl.address, regInitCallData], { account: ownerWallet.account });
    await waitForTx(connection, diamondCutTx);

    stashAtOps = await viem.getContractAt("StashOps", stashAddress);

    // send some erc20 to userWallet for testing
    const erc20TransferTx = await erc20.write.transfer([stashAddress, 100n], { account: deployer.account });
    const tx = await deployer.sendTransaction({
      to: stashAddress,
      value: parseEther("5.0"),
    });

    await Promise.all([waitForTx(connection, erc20TransferTx), waitForTx(connection, tx)]);
  });

  it("Should deploy StashWithdrawal contract", async () => {
    stashWithdrawal = await viem.deployContract("StashWithdrawal", [], { client: { wallet: deployer } });
    assert.notEqual(stashWithdrawal.address, zeroAddress);
    stashAtWithdrawal = await viem.getContractAt("StashWithdrawal", stashAddress);
  });

  it("Should register StashWithdrawal facets", async () => {
    const facets: FacetCut[] = [buildAddFacet(stashWithdrawal)];
    const initCallData = getCalldata(lookupAtImpl.abi, "lockImplementation", [stashWithdrawal.address, STASH_IMPL_KEY]);
    const diamondCutTx = await lookupAtImpl.write.diamondCut([facets, lookupAtImpl.address, initCallData], { account: ownerWallet.account });
    await waitForTx(connection, diamondCutTx);
    await viem.assertions.revertWithCustomError(stashAtWithdrawal.write.withdraw([0n, zeroAddress]), stashAtWithdrawal, "InvalidOperationAmount");
  });

  it("Should be able to withdraw native token", async () => {
    const withdrawAmount = parseEther("1.0");
    const prevBal = await stashAtOps.read.balance();

    // make withdraw
    await viem.assertions.emitWithArgs(
      stashAtWithdrawal.write.withdraw([withdrawAmount, userWallet.account.address], { account: userWallet.account }),
      stashAtWithdrawal,
      "TokenWithdrawn",
      [checksumAddress(stashAtWithdrawal.address), checksumAddress(userWallet.account.address), zeroAddress, withdrawAmount]
    );

    const newBal = await stashAtOps.read.balance();
    assert.equal(newBal, prevBal - withdrawAmount);
  });

  it("Should be able to withdraw erc20 token", async () => {
    const withdrawAmount = 2n;
    const prevBal = await stashAtOps.read.balance([erc20.address]);
    // make withdrawal
    await viem.assertions.emitWithArgs(
      stashAtWithdrawal.write.withdraw([erc20.address, withdrawAmount, userWallet.account.address], { account: userWallet.account }),
      stashAtWithdrawal,
      "TokenWithdrawn",
      [checksumAddress(stashAtWithdrawal.address), checksumAddress(userWallet.account.address), checksumAddress(erc20.address), withdrawAmount]
    );

    const newBal = await stashAtOps.read.balance([erc20.address]);
    assert.equal(newBal, prevBal - withdrawAmount);
  });

  it("Should revert withdraw for closed stash", async () => {
    const withdrawAmount = parseEther("1.0");

    // close stash
    const closeTx = await stashAtOps.write.setStatus([1], { account: userWallet.account });
    await waitForTx(connection, closeTx);

    await viem.assertions.revertWithCustomError(
      stashAtWithdrawal.write.withdraw([withdrawAmount, userWallet.account.address], { account: userWallet.account }),
      stashAtWithdrawal,
      "ActionRejected"
    );

    // Re-open stash for further tests
    const reopenTx = await stashAtOps.write.setStatus([0], { account: userWallet.account });
    await waitForTx(connection, reopenTx);
  });
});
