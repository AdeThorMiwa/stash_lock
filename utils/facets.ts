import { NetworkConnection } from "hardhat/types/network";
import { FacetCut, FacetCutAction, Lookup } from "./types.js";
import { compareAddress, getDeployedAddress, getFunctionSelectors, getSignature, waitForTx } from "./common.js";
import { Address, encodeFunctionData, zeroAddress, getContract } from "viem";
import { artifacts } from "hardhat";

const sortSelectors = async (lookup: Lookup, selectors: Address[], facet?: string, lockKey?: Address): Promise<[toAdd: Address[], toReplace: Address[]]> => {
  const _add: Address[] = [];
  const _replace: Address[] = [];

  for (const _funcSig of selectors) {
    let registered;
    try {
      registered = await (lockKey?.length ? lookup.read.getImplementation([_funcSig, lockKey]) : lookup.read.getImplementation([_funcSig]));
    } catch (error) {}

    if (registered && !compareAddress(registered, zeroAddress) && !compareAddress(registered, facet ?? "")) {
      _replace.push(_funcSig);
    }
    if (!registered || compareAddress(registered, zeroAddress)) {
      _add.push(_funcSig);
    }
  }

  return [_add, _replace];
};

export const getCalldata = (abi: any[], functionName: string, args: any[]) => {
  return encodeFunctionData({
    abi,
    functionName,
    args,
  });
};

export const sortAndRegisterFacet = async (connection: NetworkConnection, lookup: Lookup, contractName: string, lockKey?: Address) => {
  const {
    networkName,
    networkConfig: { chainId },
  } = connection;

  const operations: FacetCut[] = [];

  const _address = await getDeployedAddress(chainId!, contractName);

  const _callData = lockKey ? getCalldata(lookup.abi, "lockImplementation", [_address, lockKey]) : getCalldata(lookup.abi, "setGlobalUse", [_address, true]);

  if (!_address) {
    console.log(`${contractName} deployed address record not found on network: ${networkName}`);
    return;
  }

  const contractArtifact = await artifacts.readArtifact(contractName);

  const selectors = contractArtifact.abi.filter((item) => item.type === "function").map((func) => getSignature(func.name));

  // Sort signatures
  const [_add, _replace] = await sortSelectors(lookup, selectors, _address, lockKey);

  if (!_add.length && !_replace.length) {
    console.log(`${contractName} >>> no change required  on: ${networkName}`);
    return;
  }

  if (_add.length) {
    operations.push({
      facetAddress: _address,
      functionSelector: _add,
      action: FacetCutAction.ADD,
    });
  }

  if (_replace.length) {
    operations.push({
      facetAddress: _address,
      functionSelector: _replace,
      action: FacetCutAction.REPLACE,
    });
  }

  console.log(`${contractName} >>> Preparing to register facet on: ${networkName}`);

  // Set and lock liquidity facet signatures
  const txHash = await lookup.write.diamondCut([operations, lookup.address, _callData]);

  await waitForTx(connection, txHash, 1);

  console.log(`${contractName} facet registered and locked to implementation key on network: ${networkName}`);
  console.log(`>>>>> Transaction hash: ${txHash}`);
};

export const buildAddFacet = (contract: any) => {
  const selectors = getFunctionSelectors(contract.abi);
  return {
    facetAddress: contract.address,
    functionSelector: selectors,
    action: FacetCutAction.ADD,
  };
};
