import { describe, it, expect } from "vitest";
import { Cl } from "@stacks/transactions";

describe("clicker-v2", () => {
  it("should return initial total clicks as zero", () => {
    const result = simnet.callReadOnlyFn("clicker-v2", "get-total-clicks", [], simnet.deployer);
    expect(result.result).toBeOk(Cl.uint(0));
  });

  it("should return default user clicks", () => {
    const result = simnet.callReadOnlyFn(
      "clicker-v2", "get-user-clicks",
      [Cl.standardPrincipal(simnet.deployer)], simnet.deployer
    );
    expect(result.result).toBeOk(Cl.tuple({
      clicks: Cl.uint(0), "last-click": Cl.uint(0), streak: Cl.uint(0), "best-streak": Cl.uint(0),
    }));
  });

  it("should confirm game is active", () => {
    const result = simnet.callReadOnlyFn("clicker-v2", "is-active", [], simnet.deployer);
    expect(result.result).toBeOk(Cl.bool(true));
  });

  it("should allow a click", () => {
    const result = simnet.callPublicFn("clicker-v2", "click", [], simnet.deployer);
    expect(result.result.type).toBe(7);
  });

  it("should increment total clicks", () => {
    simnet.callPublicFn("clicker-v2", "click", [], simnet.deployer);
    simnet.mineEmptyBlocks(2);
    simnet.callPublicFn("clicker-v2", "click", [], simnet.deployer);
    const result = simnet.callReadOnlyFn("clicker-v2", "get-total-clicks", [], simnet.deployer);
    expect(result.result).toBeOk(Cl.uint(2));
  });

  it("should reject click during cooldown", () => {
    simnet.callPublicFn("clicker-v2", "click", [], simnet.deployer);
    const result = simnet.callPublicFn("clicker-v2", "click", [], simnet.deployer);
    expect(result.result).toBeErr(Cl.uint(101));
  });

  it("should allow owner to deactivate", () => {
    const result = simnet.callPublicFn("clicker-v2", "set-active", [Cl.bool(false)], simnet.deployer);
    expect(result.result).toBeOk(Cl.bool(true));
  });
});
