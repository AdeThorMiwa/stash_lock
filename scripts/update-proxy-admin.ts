import hre from "hardhat";
import { getDeployedAddress, prepareProxyAdminInterface, waitForTx } from "../utils/common.js";
import { isDirectInvocation } from "../utils/file.js";
import { NetworkConnection } from "hardhat/types/network";
import { FACTORY_PROXY_CONTRACT_NAME, LOOKUP_PROXY_CONTRACT_NAME, PROXY_ADMIN_CONTRACT_NAME } from "../utils/consts.js";
import { ProxyAdmin } from "../utils/types.js";
import { Address } from "viem";

async function changeProxyAdmin(proxyAdmin: ProxyAdmin, name: string, newAdmin: Address, connection: NetworkConnection) {
  const proxy = await getDeployedAddress(connection.networkConfig.chainId!, name);

  if (!proxy) {
    console.log("Valid proxy contract not found on network. Skipping", name, connection.networkName);
    return;
  }

  const oldAdmin = await proxyAdmin.read.getProxyAdmin([proxy]);

  if (oldAdmin === newAdmin) {
    console.log("Proxy admin not changed on network. Skipping", name, connection.networkName);
    return;
  }

  const txHash = await proxyAdmin.write.changeProxyAdmin([proxy, newAdmin]);

  console.log("Proxy admin changed", name, connection.networkName, txHash);

  await waitForTx(connection, txHash);
}

const main = async (connection: NetworkConnection) => {
  const ProxyAdmin = await prepareProxyAdminInterface(connection);

  console.log("Changing FactoryProxy admin");
  await changeProxyAdmin(ProxyAdmin, FACTORY_PROXY_CONTRACT_NAME, ProxyAdmin.address, connection);

  console.log("Changing LookupProxy admin");
  await changeProxyAdmin(ProxyAdmin, LOOKUP_PROXY_CONTRACT_NAME, ProxyAdmin.address, connection);
};

if (isDirectInvocation(import.meta)) {
  main(await hre.network.connect()).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

export default main;
