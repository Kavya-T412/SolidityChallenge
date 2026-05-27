import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("WhiteListApp", (m) => {
  const whitelist = m.contract("WhiteListApp");

  return { whitelist };
});
