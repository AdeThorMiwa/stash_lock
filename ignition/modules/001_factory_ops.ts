import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { FACTORY_OPS_CONTRACT_NAME } from "../../utils/consts.js";
import { getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(FACTORY_OPS_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const factoryOps = m.contract(FACTORY_OPS_CONTRACT_NAME, [], { from: deployer });

  return { factoryOps };
});
