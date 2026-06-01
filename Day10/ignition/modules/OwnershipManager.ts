import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OwnershipManagerModule", (m) => {
  const ownershipManager = m.contract("OwnershipManager");

  return { ownershipManager };
});
