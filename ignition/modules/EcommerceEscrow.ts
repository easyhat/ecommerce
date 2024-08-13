import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";

const EcomModule = buildModule("EcomModule", (m) => {
  const Ecom = m.contract("EcommerceEscrow");

  return { Ecom };
});

export default EcomModule;
