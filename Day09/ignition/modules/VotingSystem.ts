import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Voting_System", (m) => {
  const votingSystem = m.contract("VotingSystem");

  m.call(votingSystem, "createAProposal", ["Proposal 1", "Description 1", 1]);

  return { votingSystem };
});
