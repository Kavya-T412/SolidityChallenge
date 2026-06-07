import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ReferralSystem", (m) => {
  const referralSystem = m.contract("ReferralSystem");

  return { referralSystem };
});
