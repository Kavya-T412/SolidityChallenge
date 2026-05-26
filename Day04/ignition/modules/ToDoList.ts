import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ModuleToDoList", (m) => {
  const toDoList = m.contract("ToDoList");

  return { toDoList };
});
