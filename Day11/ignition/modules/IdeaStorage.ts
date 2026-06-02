import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("IdeaStorageModule", (m) => {

    const ideaStorage = m.contract("IdeaStorage");
    return { ideaStorage };

});
