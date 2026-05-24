import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("UserStorageModule", (m) => {
  const userStorage = m.contract("UserStorage");

  // m.call(userStorage, "store", ["Mitra",20]);
  m.call(userStorage, "store", ["Jaishree",20]);

  return { userStorage };
});
