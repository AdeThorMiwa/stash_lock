import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { LOOKUP_PROXY_CONTRACT_NAME } from "../../utils/consts.js";
import ProxyAdminModule from "./000_proxy_admin.js";
import LookupOpsModule from "./002_lookup_ops.js";

export default buildModule(getModuleId(LOOKUP_PROXY_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const owner = m.getAccount(1);
  const { proxyAdmin } = m.useModule(ProxyAdminModule);
  const { lookupOps } = m.useModule(LookupOpsModule);
  const lookupProxy = m.contract(LOOKUP_PROXY_CONTRACT_NAME, [owner, proxyAdmin, lookupOps], { from: deployer });

  return { lookupProxy };
});
