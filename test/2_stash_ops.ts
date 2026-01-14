import assert from "node:assert/strict";
import { before, describe, it } from "node:test";
import { network } from "hardhat";
import { Address, checksumAddress, getContract, parseEther, zeroAddress } from "viem";
import { getFunctionSelectors, waitForTx } from "../utils/common.js";
import { FacetCut, FacetCutAction } from "../utils/types.js";
import { buildAddFacet, getCalldata } from "../utils/facets.js";
import { STASH_IMPL_KEY } from "../utils/consts.js";

describe("Lookup and Stash Ops", async function () {
  const connection = await network.connect();
  const { viem } = connection;
  const [deployer, ownerWallet, _, userWallet, ...otherWallets] = await viem.getWalletClients();

  type ContractType<S extends string> = Awaited<ReturnType<typeof viem.deployContract<S>>>;

  let lookup: ContractType<"LookupProxy">,
    lookupOps: ContractType<"LookupOps">,
    factory: ContractType<"FactoryProxy">,
    factoryOps: ContractType<"FactoryOps">,
    proxyAdmin: ContractType<"ProxyAdmin">,
    stashOps: ContractType<"StashOps">,
    stashAtOps: ContractType<"StashOps">,
    stash: ContractType<"Stash">,
    ownableOps: ContractType<"OwnableOps">,
    stashAtOwnable: ContractType<"OwnableOps">,
    proxyAtImpl: ContractType<"FactoryOps">,
    lookupAtImpl: ContractType<"LookupOps">,
    stashAddress: Address,
    erc20: ContractType<"StashToken">;

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

    ownableOps = await viem.deployContract("OwnableOps", [], { client: { wallet: deployer } });

    // create an stash
    // @ts-ignore
    const createStashTxHash = await proxyAtImpl.write.createStash({ account: userWallet.account });
    await waitForTx(connection, createStashTxHash);

    [[stashAddress]] = await proxyAtImpl.read.getStashes([userWallet.account.address]);

    // Deploy Stash Operations
    stashOps = await viem.deployContract("StashOps", [], { client: { wallet: deployer } });

    stashAtOps = await viem.getContractAt("StashOps", stashAddress);
    stash = await viem.getContractAt("Stash", stashAddress);
  });

  it("Should revert with: InvalidLookupImplementation Error on unregistered implementation ", async () => {
    await viem.assertions.revertWithCustomError(stashAtOps.read.balance(), stash, "InvalidLookupImplementation");
  });

  it("Should revert diamondCut call with: UnauthorizedAccount Error", async () => {
    const selectors = getFunctionSelectors(stashOps.abi);

    const facetCut: FacetCut = {
      facetAddress: stashOps.address,
      functionSelector: selectors,
      action: FacetCutAction.ADD,
    };

    // Filter ABI to only include the single-parameter diamondCut function
    const diamondCutAbi = lookupAtImpl.abi.filter((item) => item.type === "function" && item.name === "diamondCut" && item.inputs?.length === 1);

    const diamondLookup = getContract({
      abi: diamondCutAbi,
      address: lookup.address,
      client: ownerWallet,
    });

    await viem.assertions.revertWithCustomError(diamondLookup.write.diamondCut([[facetCut]], { account: userWallet.account }), lookupAtImpl, "UnauthorizedAccount");
  });

  it("Should allow diamond cut from Owner", async () => {
    const setGlobalInitCallData = getCalldata(lookupAtImpl.abi, "setGlobalUse", [ownableOps.address, true]);
    const lockImplInitCalldata = getCalldata(lookupAtImpl.abi, "lockImplementation", [stashOps.address, STASH_IMPL_KEY]);

    const stashOpsFacet: FacetCut[] = [buildAddFacet(stashOps)];
    const ownableOpsFacet: FacetCut[] = [buildAddFacet(ownableOps)];

    await viem.assertions.emit(
      lookupAtImpl.write.diamondCut([stashOpsFacet, lookupAtImpl.address, lockImplInitCalldata], { account: ownerWallet.account }),
      lookupAtImpl,
      "DiamondCut"
    );

    await viem.assertions.emit(
      lookupAtImpl.write.diamondCut([ownableOpsFacet, lookupAtImpl.address, setGlobalInitCallData], { account: ownerWallet.account }),
      lookupAtImpl,
      "DiamondCut"
    );
  });

  it("Should get owner from ownable facet", async () => {
    stashAtOwnable = await viem.getContractAt("OwnableOps", stashAddress);
    assert.equal(await stashAtOwnable.read.owner(), checksumAddress(userWallet.account.address));
  });

  it("Should returns balances", async () => {
    const tokens = await stashAtOps.read.tokens();

    for (const token of tokens) {
      const balance = await stashAtOps.read.balance([token]);
      assert.equal(balance, BigInt(0));
    }
  });

  it("Should receive network coin", async () => {
    const tx = await otherWallets[0].sendTransaction({
      to: stashAddress,
      value: parseEther("1.0"),
    });

    await waitForTx(connection, tx);

    const balance = await stashAtOps.read.balance();
    // Check availableBalance
    assert.equal(balance, parseEther("1.0"));
  });

  it("Should receive ERC20 token", async () => {
    const tx = await erc20.write.transfer([stashAddress, 10n], { account: deployer.account });
    await waitForTx(connection, tx);

    const tokenBalance = await stashAtOps.read.balance([erc20.address]);
    // Check balance
    assert.equal(await erc20.read.balanceOf([stashAddress]), tokenBalance);
    assert.equal(tokenBalance, BigInt(10));
  });

  it("Should allow owner setStatus", async () => {
    const txHash = await stashAtOps.write.setStatus([1], { account: userWallet.account });
    await waitForTx(connection, txHash);

    const status = await stashAtOps.read.status();
    assert.equal(status, 1);
  });

  it("Should revert with: UnauthorizedAccount for unauthorized setStatus", async () => {
    await viem.assertions.revertWithCustomError(stashAtOps.write.setStatus([1], { account: otherWallets[0].account }), stashAtOps, "UnauthorizedAccount");
  });
});
