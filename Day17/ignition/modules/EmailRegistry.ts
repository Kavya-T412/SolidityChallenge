import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("EmailRegistry", (m) => {
  const emailRegistry = m.contract("EmailRegistry");

  return { emailRegistry };
});
