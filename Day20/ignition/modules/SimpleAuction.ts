import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleAuctionModule", (m) => {
  const simpleAuction = m.contract("SimpleAuction");

  return { simpleAuction };
});
