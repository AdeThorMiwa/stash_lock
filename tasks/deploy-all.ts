import { readdir } from "fs/promises";
import { HardhatRuntimeEnvironment } from "hardhat/types/hre";
import path from "path";

interface DeployAllTaskArgs {}

const getAllModules = async () => {
  const modulesPath = path.join(process.cwd(), "ignition/modules");
  const files = await readdir(modulesPath);
  const validSorted = files.filter((f) => f.endsWith(".ts")).sort();
  return Promise.all(validSorted.map(async (file) => (await import(path.join(modulesPath, file))).default));
};

export default async function (_: DeployAllTaskArgs, hre: HardhatRuntimeEnvironment) {
  const conn = await hre.network.connect();
  console.log("Starting deployment of all contracts...");
  const modules = await getAllModules();
  for (const module of modules) {
    await conn.ignition.deploy(module);
  }
  console.log("All contracts deployed successfully.");
}
