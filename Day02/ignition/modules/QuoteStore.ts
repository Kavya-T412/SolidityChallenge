import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("QuoteStoreModule", (m) => {
  const quoteStore = m.contract("QuoteStore");

  m.call(quoteStore, "storeQuote", ["Oscar Wilde","Be yourself; everyone else is already taken."]);
  m.call(quoteStore, "myQuote");

  return { quoteStore };
});
