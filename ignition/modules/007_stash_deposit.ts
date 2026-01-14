import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { STASH_DEPOSIT_CONTRACT_NAME } from "../../utils/consts.js";
import { getModuleId } from "../../utils/common.js";

export default buildModule(getModuleId(STASH_DEPOSIT_CONTRACT_NAME), (m) => {
  const deployer = m.getAccount(0);
  const stashDeposit = m.contract(STASH_DEPOSIT_CONTRACT_NAME, [], { from: deployer });

  return { stashDeposit };
});
