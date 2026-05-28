import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleBankModule", (m) => {
  const simpleBank = m.contract("SimpleBank");

  m.call(simpleBank, "depositETH", [], { value: 1000000000000000000n });

  return { simpleBank };
});