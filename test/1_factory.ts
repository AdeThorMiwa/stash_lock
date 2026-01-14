import assert from "node:assert/strict";
import { before, describe, it } from "node:test";
import { network } from "hardhat";
import { checksumAddress, zeroAddress } from "viem";
import { waitForTx } from "../utils/common.js";

const VANITY_LOOKUP_ADDRESS = "0x4093FFfb363D6946E5F9409b852b76F232867d7D";
const USER_MAX_STASH = 2;

describe("Stash Factory", async function () {
  const connection = await network.connect();
  const { viem } = connection;
  const [deployer, ownerWallet, newOwnerWallet, userWallet, ...otherWallets] = await viem.getWalletClients();

  type ContractType<S extends string> = Awaited<ReturnType<typeof viem.deployContract<S>>>;
  let proxy: ContractType<"FactoryProxy">, proxyAdmin: ContractType<"ProxyAdmin">, factoryOps: ContractType<"FactoryOps">;

  const getContractWithClient = async <S extends string>(contract: S, contractAddress: `0x${string}`, client: any) => {
    return await viem.getContractAt(contract, contractAddress, { client: { wallet: client } });
  };

  before(async () => {
    factoryOps = await viem.deployContract("FactoryOps", [], { client: { wallet: deployer } });
    proxyAdmin = await viem.deployContract("ProxyAdmin", [ownerWallet.account.address], { client: { wallet: deployer } });
  });

  it("Should deploy proxy and set implementation", async () => {
    proxy = await viem.deployContract("FactoryProxy", [ownerWallet.account.address, proxyAdmin.address, factoryOps.address, VANITY_LOOKUP_ADDRESS, USER_MAX_STASH], {
      client: { wallet: deployer },
    });
    assert.notEqual(proxy.address, zeroAddress);
  });

  it("Should setup proxy At implementation", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, ownerWallet);
    assert.equal(await proxyAtFactory.read.owner(), checksumAddress(ownerWallet.account.address));
  });

  it("Should reject only owner allowed call.", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, newOwnerWallet);
    await viem.assertions.revertWithCustomError(proxyAtFactory.simulate.transferOwnership([zeroAddress]), proxyAtFactory, "UnauthorizedAccount");
  });

  it("Should transfer ownership", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, ownerWallet);
    const txHash = await proxyAtFactory.write.transferOwnership([newOwnerWallet.account.address]);

    await waitForTx(connection, txHash);
    assert.equal(await proxyAtFactory.read.owner(), checksumAddress(newOwnerWallet.account.address));
  });

  it("Should allow user to create a stash and emit event", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, userWallet);
    const txHash = await proxyAtFactory.write.createStash();
    await waitForTx(connection, txHash);

    const [stashes, count] = await proxyAtFactory.read.getStashes([userWallet.account.address]);

    assert(stashes.length > 0);
    assert.equal(count, BigInt(stashes.length));
  });

  it("Should revert intermediary stash creation from unauthorized account with: NOT_AUTHORIZED", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, ownerWallet);
    await viem.assertions.revertWithCustomError(proxyAtFactory.simulate.createStash([userWallet.account.address]), proxyAtFactory, "UnauthorizedAccount");
  });

  it("Should increment user stash count.", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, newOwnerWallet);
    const txHash = await proxyAtFactory.write.createStash([userWallet.account.address]);
    await waitForTx(connection, txHash);

    const [stashes] = await proxyAtFactory.read.getStashes([userWallet.account.address]);
    assert(stashes.length > 1);
  });

  it("Should revert with: STASH_LIMIT_REACHED", async () => {
    const proxyAtFactory = await getContractWithClient("FactoryOps", proxy.address, userWallet);
    const [stashes] = await proxyAtFactory.read.getStashes([userWallet.account.address]);
    assert(stashes.length >= 2);
    // @ts-ignore
    await viem.assertions.revertWithCustomError(proxyAtFactory.simulate.createStash({ account: userWallet.account }), proxyAtFactory, "StashLimitReached");
  });
});
