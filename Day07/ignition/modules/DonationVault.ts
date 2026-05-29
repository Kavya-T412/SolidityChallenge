import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DonationVaultModule", (m) => {
  const donationVault = m.contract("DonationVault");

  return { donationVault };
});
