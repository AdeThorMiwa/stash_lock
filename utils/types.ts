import { Address, Hex } from "viem";
import { prepareLookupInterface, prepareProxyAdminInterface } from "./common.js";

export type ProxyAdmin = Awaited<ReturnType<typeof prepareProxyAdminInterface>>;
export type Lookup = Awaited<ReturnType<typeof prepareLookupInterface>>;

export enum FacetCutAction {
  ADD, // 0: Add a new facet.
  REPLACE, // 1: Replace an existing facet.
  REMOVE, // 2: Remove a facet.
}

export interface FacetCut {
  //The address of the facet.
  facetAddress: Address;
  // The action to be taken on the facet.
  action: FacetCutAction;
  // The list of function selectors for the facet.
  functionSelector: readonly Hex[];
}
