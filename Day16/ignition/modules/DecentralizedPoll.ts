import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DecentralizedPollModule", (m) => {
  const decentralizedPoll = m.contract("DecentralizedPoll");

  return { decentralizedPoll };
});
