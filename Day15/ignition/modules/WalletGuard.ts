import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("walletGuard", (m) => {
  const wallet = m.contract("WalletGuard");

  

  return { wallet };
});
