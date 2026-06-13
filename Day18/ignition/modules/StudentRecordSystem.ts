import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("StudentRecordSystemModule", (m) => {
  const studentRecordSystem = m.contract("StudentRecordSystem");

  m.call(studentRecordSystem, "activateContract", []);

  return { studentRecordSystem };
});
