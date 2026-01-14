import assert from "node:assert/strict";
import { BaseError, ContractFunctionRevertedError, getContract } from "viem";

export const revertWithCustomError = async (promise: Promise<any>, contract: ReturnType<typeof getContract>, expectedErrorName: string) => {
  try {
    await promise;
    assert.fail("Expected transaction to revert but it succeeded");
  } catch (error: any) {
    if (error instanceof BaseError) {
      const revertError = error.walk((err) => err instanceof ContractFunctionRevertedError);
      if (revertError instanceof ContractFunctionRevertedError) {
        const errorName = revertError.data?.errorName;
        if (errorName !== expectedErrorName) {
          assert.fail(`Expected error name ${expectedErrorName} but got ${errorName}`);
        }
        return;
      }
    }

    assert.fail(`Expected transaction to revert with a custom error but got: ${error}`);
  }
};
