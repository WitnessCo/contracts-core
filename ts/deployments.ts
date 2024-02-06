import { type Address, isHex } from "viem";

// First manually import the deployment artifacts for all chains and organize them.
import baseGoerliArtifact from "../broadcast/Deploy.s.sol/84531/run-latest.json";
import goerliArtifact from "../broadcast/Deploy.s.sol/5/run-latest.json";
import sepoliaArtifact from "../broadcast/Deploy.s.sol/11155111/run-latest.json";
import opSepoliaArtifact from "../broadcast/Deploy.s.sol/11155420/run-latest.json";
import baseSepoliaArtifact from "../broadcast/Deploy.s.sol/84532/run-latest.json";
import scrollSepoliaArtifact from "../broadcast/Deploy.s.sol/534351/run-latest.json";
import { desiredContracts, supportedChains } from "./utils";

const artifacts = [
  baseGoerliArtifact,
  goerliArtifact,
  sepoliaArtifact,
  opSepoliaArtifact,
  baseSepoliaArtifact,
  scrollSepoliaArtifact,
];

// Then, organize them into a single object that can be exported.
export const deployments: Record<
  (typeof desiredContracts)[number],
  Record<(typeof supportedChains)[number]["id"], Address>
> = artifacts.reduce(
  (acc, artifact) => {
    const { chain, transactions } = artifact;
    return transactions.reduce((acc, transaction) => {
      const { contractName, contractAddress } = transaction;
      if (!isHex(contractAddress)) {
        throw new Error(`Contract address ${contractAddress} is not a valid hex string`);
      }
      const refinedContractName = desiredContracts.find((c) => c === contractName);
      if (!refinedContractName) {
        throw new Error(`Contract name ${contractName} is not supported`);
      }
      acc[refinedContractName] = {
        ...acc[refinedContractName],
        [chain]: contractAddress,
      };
      return acc;
    }, acc);
  },
  {} as Record<(typeof desiredContracts)[number], Record<(typeof supportedChains)[number]["id"], Address>>,
);
