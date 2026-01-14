import hre, { network } from "hardhat";
import { prepareLookupInterface } from "../utils/common.js";
import { OWNABLE_OPS_CONTRACT_NAME, STASH_DEPOSIT_CONTRACT_NAME, STASH_IMPL_KEY, STASH_OPS_CONTRACT_NAME, STASH_WITHDRAWAL_CONTRACT_NAME } from "../utils/consts.js";
import { sortAndRegisterFacet } from "../utils/facets.js";

const main = async () => {
  const connection = await hre.network.connect();

  console.log("Updating Proxy Admin");
  await import("./update-proxy-admin.js").then((exec) => exec.default(connection));

  console.log("Updating Proxy Implementations");
  await import("./update-proxy-impl.js").then((exec) => exec.default(connection));

  const Lookup = await prepareLookupInterface(connection);

  console.log("Registering Global Facets");
  await sortAndRegisterFacet(connection, Lookup, OWNABLE_OPS_CONTRACT_NAME);

  console.log("Registering Stash Facets");
  await sortAndRegisterFacet(connection, Lookup, STASH_OPS_CONTRACT_NAME, STASH_IMPL_KEY);
  await sortAndRegisterFacet(connection, Lookup, STASH_DEPOSIT_CONTRACT_NAME, STASH_IMPL_KEY);
  await sortAndRegisterFacet(connection, Lookup, STASH_WITHDRAWAL_CONTRACT_NAME, STASH_IMPL_KEY);
};

main().catch((err) => {
  console.error("Error Occurred:", err);
  process.exit(5);
});
