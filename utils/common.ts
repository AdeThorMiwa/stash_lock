import { LOOKUP_OPS_CONTRACT_NAME, LOOKUP_PROXY_CONTRACT_NAME, PROXY_ADMIN_CONTRACT_NAME } from "./consts.js";
import path from "path";
import { NetworkConnection } from "hardhat/types/network";
import { Address, createWalletClient, EIP1193RequestFn, getContract, http, keccak256, toHex, Transport, TransportConfig } from "viem";

export const getModuleId = (ignitionModule: string) => {
  return `${ignitionModule}Module`;
};

export const getEnvOrFail = (key: string, defaultValue?: string) => {
  const val = process.env[key];
  if ((!val || val === "") && !defaultValue) {
    throw new Error(`${key} missing from environment`);
  }
  return val ?? defaultValue!;
};

export const getDeployedAddress = async (chainId: number, contractName: string): Promise<Address | undefined> => {
  const deploymentBasePath = "ignition/deployments";
  try {
    const pathToDeploymentFile = path.join(process.cwd(), deploymentBasePath, `chain-${chainId}/deployed_addresses.json`);
    const deployed_addresses = await import(pathToDeploymentFile);
    const moduleFullPath = `${contractName}Module#${contractName}`;
    return deployed_addresses.default[moduleFullPath] as Address | undefined;
  } catch (error) {
    return undefined;
  }
};

// Prepares and returns a ProxyAdmin contract instance connected to an account
export const prepareProxyAdminInterface = async (connection: NetworkConnection) => {
  const { networkName, viem, networkConfig } = connection;

  if (!networkConfig.chainId) {
    throw new Error(`Network chainId not found for network ${networkName}`);
  }

  const proxyAdminAddress = await getDeployedAddress(networkConfig.chainId, PROXY_ADMIN_CONTRACT_NAME);

  if (!proxyAdminAddress) {
    throw new Error(`Deployed ${PROXY_ADMIN_CONTRACT_NAME} address not found for network ${networkName}`);
  }

  const proxyAdmin = await viem.getContractAt(PROXY_ADMIN_CONTRACT_NAME, proxyAdminAddress);

  const ownerAddress = await proxyAdmin.read.owner();

  console.log(`${PROXY_ADMIN_CONTRACT_NAME} Owner Address::`, ownerAddress);

  const walletClient = await getWalletClient(ownerAddress, connection);

  return getContract({ abi: proxyAdmin.abi, address: proxyAdminAddress, client: walletClient });
};

export const prepareLookupInterface = async (connection: NetworkConnection) => {
  const { networkName, viem, networkConfig } = connection;

  const lookupAddress = await getDeployedAddress(networkConfig.chainId!, LOOKUP_PROXY_CONTRACT_NAME);

  if (!lookupAddress) {
    throw new Error(
      `Deployed lookup contract address not found on network:
      ${networkName}`
    );
  }

  const Lookup = await viem.getContractAt(LOOKUP_OPS_CONTRACT_NAME, lookupAddress);

  const ownerAddress = await Lookup.read.owner();
  console.log("Lookup Owner Address::", ownerAddress);

  const walletClient = await getWalletClient(ownerAddress, connection);

  return getContract({ abi: Lookup.abi, address: lookupAddress, client: walletClient });
};

export const waitForTx = async (connection: NetworkConnection, txHash: Address, confirmations?: number) => {
  const publicClient = await connection.viem.getPublicClient();
  return publicClient.waitForTransactionReceipt({
    hash: txHash,
    confirmations,
  });
};

export const getSignature = (functionDefinition: string): Address => {
  return keccak256(toHex(functionDefinition)).substring(0, 10) as Address;
};

export const compareAddress = (addr: string, addr2: string) => {
  return String(addr).toLowerCase() === String(addr2).toLowerCase();
};

export const getWalletClient = async (walletAddress: Address, connection: NetworkConnection) => {
  const wallet = await connection.viem.getWalletClient(walletAddress);

  if (!wallet) {
    throw new Error("Wallet not found");
  }

  if (["hardhatMainnet"].includes(connection.networkName)) {
    return wallet;
  }

  return createWalletClient({
    chain: wallet.chain,
    transport: toWalletClientTransport(wallet.transport),
    account: wallet.account,
  });
};

export const toWalletClientTransport = (config: TransportConfig<string, EIP1193RequestFn> & Record<string, any>): Transport => {
  return http(config.url, config);
};

export const getFunctionSelectors = (abi: any[]): Address[] => {
  return abi
    .filter((item) => item.type === "function")
    .map((func) => {
      // Build full function signature with parameter types
      const params = func.inputs?.map((input: any) => input.type).join(",") || "";
      const signature = `${func.name}(${params})`;
      return getSignature(signature);
    });
};
