import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { FACTORY_PROXY_CONTRACT_NAME } from "../../utils/consts.js";
import { getEnvOrFail, getModuleId } from "../../utils/common.js";
import ProxyAdminModule from "./000_proxy_admin.js";
import FactoryOpsModule from "./001_factory_ops.js";
import LookupProxyModule from "./003_lookup_proxy.js";

export default buildModule(getModuleId(FACTORY_PROXY_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const owner = m.getAccount(1);
  const userMaxStash = parseInt(getEnvOrFail("USER_MAX_STASH", "1"));
  const { proxyAdmin } = m.useModule(ProxyAdminModule);
  const { factoryOps } = m.useModule(FactoryOpsModule);
  const { lookupProxy } = m.useModule(LookupProxyModule);
  const factoryProxy = m.contract(FACTORY_PROXY_CONTRACT_NAME, [owner, proxyAdmin, factoryOps, lookupProxy, userMaxStash], { from: deployer });

  return { factoryProxy };
});
