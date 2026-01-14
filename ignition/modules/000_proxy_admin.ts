import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { PROXY_ADMIN_CONTRACT_NAME } from "../../utils/consts.js";
import { getEnvOrFail, getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(PROXY_ADMIN_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const owner = m.getAccount(1);
  console.log("ProxyAdmin Owner Address from .env::", owner);
  const proxyAdmin = m.contract(PROXY_ADMIN_CONTRACT_NAME, [owner], { from: deployer });
  console.log(`Prepared ${PROXY_ADMIN_CONTRACT_NAME} module.`);
  return { proxyAdmin };
});
