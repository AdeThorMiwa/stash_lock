import { task } from "hardhat/config";

export const deployAll = task("deploy-all", "Deploy all contracts")
  .setAction(() => import("./deploy-all.js"))
  .build();

export default [deployAll];
