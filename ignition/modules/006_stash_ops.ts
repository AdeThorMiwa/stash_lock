import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { STASH_OPS_CONTRACT_NAME } from "../../utils/consts.js";
import { getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(STASH_OPS_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const stashOps = m.contract(STASH_OPS_CONTRACT_NAME, [], { from: deployer });

  return { stashOps };
});
