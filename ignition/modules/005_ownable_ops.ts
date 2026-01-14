import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { OWNABLE_OPS_CONTRACT_NAME } from "../../utils/consts.js";
import { getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(OWNABLE_OPS_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const ownableOps = m.contract(OWNABLE_OPS_CONTRACT_NAME, [], { from: deployer });

  return { ownableOps };
});
