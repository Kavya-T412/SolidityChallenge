import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NFTVaultModule", (m) => {
  const nftVault = m.contract("NFTVault");

  return { nftVault };
});
