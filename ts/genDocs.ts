import fs from "node:fs/promises";

const baseInputDocsPath = "docsTemp/src/src";
const interfacesBasePath = `${baseInputDocsPath}/interfaces`;

const baseOutputDocsPath = "docs";

const contents = await fs.readdir(baseInputDocsPath);

await handleInterfaces();
await Promise.all(
  contents
    .filter((c) => c !== "README.md")
    .filter((c) => c !== "interfaces")
    .map(handleContractFolder),
);

async function handleInterfaces() {
  const files = await fs.readdir(interfacesBasePath);
  await Promise.all(files.filter((f) => f !== "README.md").map(handleInterfaceFolder));
}

async function handleInterfaceFolder(fileName: string) {
  const base = `${interfacesBasePath}/${fileName}`;
  const innerFiles = await fs.readdir(base);
  // Read all the inner file contents:
  const innerFileContents = await Promise.all(
    innerFiles.map((innerFile) => fs.readFile(`${base}/${innerFile}`, "utf-8")),
  );
  // Concat all the inner file contents into one long string.
  const contents = innerFileContents.join("\n");
  // Clean
  const cleanedContents = rmBrokenLinks(contents);
  // Write the file.
  await fs.writeFile(`${baseOutputDocsPath}/interfaces/${fileName}.md`, cleanedContents);
}

async function handleContractFolder(dirName: string) {
  const path = `${baseInputDocsPath}/${dirName}`;
  // Concat all files in the directory into one long string.
  const files = await fs.readdir(path);
  const fileContents = await Promise.all(files.map((file) => fs.readFile(`${path}/${file}`, "utf-8")));
  const contents = rmBrokenLinks(fileContents.join("\n"));
  // Write the file.
  await fs.writeFile(`${baseOutputDocsPath}/${dirName}.md`, contents);
}

function rmBrokenLinks(fileContents: string) {
  // Remove crosslinks as the URL structure doesn't match the folder structure.
  // Here's an example:
  // Source string: [RootUpdated](/src/IWitness.sol/interface.IWitness.md#rootupdated)
  // Replacement string: RootUpdated
  const regex = /\[([^\]]+)\]\(\/src\/([^\)]+)\)/g;
  const updatedContents = fileContents.replace(regex, "$1");
  return updatedContents;
}
