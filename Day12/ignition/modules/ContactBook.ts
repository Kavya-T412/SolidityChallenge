import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ContactBookModule", (m) => {
  const contactBook = m.contract("ContactBook");

  return { contactBook };
});
