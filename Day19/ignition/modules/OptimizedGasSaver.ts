import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OptimizedGasSaver", (m) => {
  const optimizedGasSaver = m.contract("OptimizedGasSaver");

  return { optimizedGasSaver };
});
