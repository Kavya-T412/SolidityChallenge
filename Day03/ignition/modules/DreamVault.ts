import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DreamVaultModule", (m) => {
  const dreamVault = m.contract("DreamVault");

  return { dreamVault };
});
