import assert from "node:assert/strict";
import { before, describe, it } from "node:test";
import { network } from "hardhat";
import { Address, checksumAddress, parseEther, zeroAddress } from "viem";
import { waitForTx } from "../utils/common.js";
import { FacetCut } from "../utils/types.js";
import { buildAddFacet, getCalldata } from "../utils/facets.js";
import { STASH_IMPL_KEY } from "../utils/consts.js";

describe("Stash Deposit", async function () {
  const connection = await network.connect();
  const { viem } = connection;
  const [deployer, ownerWallet, _, userWallet] = await viem.getWalletClients();
  const publicClient = await viem.getPublicClient();

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
    stashDeposit: ContractType<"StashDeposit">,
    stashAtDeposit: ContractType<"StashDeposit">;

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
    const erc20TransferTx = await erc20.write.transfer([userWallet.account.address, 100n], { account: deployer.account });
    await waitForTx(connection, erc20TransferTx);
  });

  it("Should deploy StashDeposit contract", async () => {
    stashDeposit = await viem.deployContract("StashDeposit", [], { client: { wallet: deployer } });
    assert.notEqual(stashDeposit.address, zeroAddress);
    stashAtDeposit = await viem.getContractAt("StashDeposit", stashAddress);
  });

  it("Should register StashDeposit facets", async () => {
    const facets: FacetCut[] = [buildAddFacet(stashDeposit)];
    const initCallData = getCalldata(lookupAtImpl.abi, "lockImplementation", [stashDeposit.address, STASH_IMPL_KEY]);
    const diamondCutTx = await lookupAtImpl.write.diamondCut([facets, lookupAtImpl.address, initCallData], { account: ownerWallet.account });
    await waitForTx(connection, diamondCutTx);
    await viem.assertions.revertWithCustomError(stashAtDeposit.simulate.deposit([0n]), stashAtDeposit, "InvalidOperationAmount");
  });

  it("Should be able to deposit native token", async () => {
    const depositAmount = parseEther("1.0");
    const prevBal = await stashAtOps.read.balance();

    // make deposit
    await viem.assertions.emitWithArgs(stashAtDeposit.write.deposit([depositAmount], { account: userWallet.account, value: depositAmount }), stashAtDeposit, "TokenDeposited", [
      checksumAddress(stashAtDeposit.address),
      checksumAddress(userWallet.account.address),
      zeroAddress,
      depositAmount,
    ]);

    const newBal = await stashAtOps.read.balance();
    assert.equal(newBal, prevBal + depositAmount);
  });

  it("Should reverse surplus value sent for native coin deposit", async () => {
    const prevUserBal = await publicClient.getBalance({ address: userWallet.account.address });
    const depositAmount = parseEther("1.0");
    const valueSent = parseEther("1.5");

    // make deposit
    const tx = await stashAtDeposit.write.deposit([depositAmount], { account: userWallet.account, value: valueSent });
    const reciept = await waitForTx(connection, tx);

    const newBal = await publicClient.getBalance({ address: userWallet.account.address });
    const txFee = reciept.effectiveGasPrice! * reciept.gasUsed;
    assert.equal(newBal, prevUserBal - depositAmount - txFee);
  });

  it("Should be able to deposit erc20 token", async () => {
    const depositAmount = 2n;
    const prevBal = await stashAtOps.read.balance([erc20.address]);

    // make deposit
    const approveTx = await erc20.write.approve([stashAddress, depositAmount], { account: userWallet.account });
    await waitForTx(connection, approveTx);
    await viem.assertions.emitWithArgs(stashAtDeposit.write.deposit([erc20.address, depositAmount], { account: userWallet.account }), stashAtDeposit, "TokenDeposited", [
      checksumAddress(stashAtDeposit.address),
      checksumAddress(userWallet.account.address),
      checksumAddress(erc20.address),
      depositAmount,
    ]);

    const newBal = await stashAtOps.read.balance([erc20.address]);
    assert.equal(newBal, prevBal + depositAmount);
  });

  it("Should revert with: ERC20InsufficientAllowance for deposit of erc20 token without allowance", async () => {
    await viem.assertions.revertWithCustomError(stashAtDeposit.write.deposit([erc20.address, 2n], { account: userWallet.account }), erc20, "ERC20InsufficientAllowance");
  });

  it("Should revert deposit for closed stash", async () => {
    const depositAmount = parseEther("1.0");

    // close stash
    const closeTx = await stashAtOps.write.setStatus([1], { account: userWallet.account });
    await waitForTx(connection, closeTx);

    await viem.assertions.revertWithCustomError(
      stashAtDeposit.write.deposit([depositAmount], { account: userWallet.account, value: depositAmount }),
      stashAtDeposit,
      "ActionRejected"
    );

    // Re-open stash for further tests
    const reopenTx = await stashAtOps.write.setStatus([0], { account: userWallet.account });
    await waitForTx(connection, reopenTx);
  });
});
