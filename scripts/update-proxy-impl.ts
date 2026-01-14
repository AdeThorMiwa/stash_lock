import { NetworkConnection } from "hardhat/types/network";
import { getDeployedAddress, prepareProxyAdminInterface, waitForTx } from "../utils/common.js";
import hre from "hardhat";
import { FACTORY_OPS_CONTRACT_NAME, FACTORY_PROXY_CONTRACT_NAME, LOOKUP_OPS_CONTRACT_NAME, LOOKUP_PROXY_CONTRACT_NAME } from "../utils/consts.js";
import { isDirectInvocation } from "../utils/file.js";
import { ProxyAdmin } from "../utils/types.js";

export const upgradeProxyImpl = async (proxyAdmin: ProxyAdmin, proxyName: string, proxyImplName: string, connection: NetworkConnection) => {
  // Update FactoryProxy Implementation
  const proxy = await getDeployedAddress(connection.networkConfig.chainId!, proxyName);

  if (!proxy) {
    throw new Error(`${proxyName} contract address not found`);
  }

  console.log(`Upgrading implementation of ${proxyName}`);

  // compare implementations
  const oldProxyImpl = await proxyAdmin.read.getProxyImplementation([proxy]);
  const newProxyImpl = await getDeployedAddress(connection.networkConfig.chainId!, proxyImplName);

  console.log(`Moving implementation from ${oldProxyImpl} to ${newProxyImpl}`);
  if (!newProxyImpl) {
    throw new Error(`${proxyImplName} deployment address missing from file`);
  }

  if (newProxyImpl.toLowerCase() === oldProxyImpl.toLowerCase()) {
    console.log(`${proxyImplName} not changed skipping upgrade`);
    return;
  }

  const txHash = await proxyAdmin.write.upgrade([proxy, newProxyImpl]);
  await waitForTx(connection, txHash);

  console.log(`${proxyName} implementation upgraded:`, newProxyImpl, txHash);
};

const main = async (connection: NetworkConnection) => {
  // get and load ProxyAdmin contract
  const ProxyAdmin = await prepareProxyAdminInterface(connection);

  // upgrade FactoryProxy Implementation
  await upgradeProxyImpl(ProxyAdmin, FACTORY_PROXY_CONTRACT_NAME, FACTORY_OPS_CONTRACT_NAME, connection);

  // upgrade LookupProxy Implementation
  await upgradeProxyImpl(ProxyAdmin, LOOKUP_PROXY_CONTRACT_NAME, LOOKUP_OPS_CONTRACT_NAME, connection);
};

if (isDirectInvocation(import.meta)) {
  main(await hre.network.connect()).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

export default main;
