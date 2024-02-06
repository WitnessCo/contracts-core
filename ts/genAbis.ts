import fs from "node:fs/promises";
import { desiredContracts } from "./utils";

const processContract = async (contractName: string) => {
  const inputPath = `out/${contractName}.sol/${contractName}.json`;
  const outputPath = `ts/abis/${contractName}.ts`;
  try {
    // Read the JSON file
    const data = await fs.readFile(inputPath, "utf8");
    const { abi } = JSON.parse(data);
    // Generate the TypeScript content
    const tsContent = `export const abi = ${JSON.stringify(abi)} as const;\n`;
    // Write the TypeScript file
    await fs.writeFile(outputPath, tsContent, "utf8");
    console.log(`Successfully wrote to ${outputPath}`);
  } catch (err) {
    console.error(`Failed to process file: ${contractName}`);
  }
};

await Promise.all(desiredContracts.map(processContract));
