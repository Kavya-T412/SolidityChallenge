import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BasicKYCModule", (m) => {
  const basicKYC = m.contract("BasicKYC");

  return { basicKYC };
});
