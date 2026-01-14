import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { LOOKUP_OPS_CONTRACT_NAME } from "../../utils/consts.js";
import { getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(LOOKUP_OPS_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const lookupOps = m.contract(LOOKUP_OPS_CONTRACT_NAME, [], { from: deployer });

  return { lookupOps };
});
