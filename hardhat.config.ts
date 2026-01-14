import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";
import "dotenv/config";
import tasks from "./tasks/index.js";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  tasks,
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
    localhost: {
      type: "http",
      chainType: "l1",
      url: "http://127.0.0.1:8545",
      accounts: [
        configVariable("LOCALHOST_DEPLOYER_PRIVATE_KEY"),
        configVariable("LOCALHOST_OWNER_PRIVATE_KEY"),
        configVariable("LOCALHOST_NEW_OWNER_PRIVATE_KEY"),
        configVariable("LOCALHOST_USER_PRIVATE_KEY"),
        configVariable("LOCALHOST_OTHER_1_PRIVATE_KEY"),
      ],
      chainId: 1337,
    },
  },
});
