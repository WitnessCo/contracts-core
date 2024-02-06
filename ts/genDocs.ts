import fs from "node:fs/promises";

const baseInputDocsPath = "docs/src/src";
const baseOutputDocsPath = "../../apps/docs/src/pages/api-reference/solidity";

const contents = await fs.readdir(baseInputDocsPath);

await Promise.all(contents.map(handleDocDir));

async function handleDocDir(dirName: string) {
	const path = `${baseInputDocsPath}/${dirName}`;
	// If the dirName isn't for a directory, return early.
	const stat = await fs.stat(path);
	if (!stat.isDirectory()) return;
	// Concat all files in the directory into one long string.
	const files = await fs.readdir(path);
	const fileContents = await Promise.all(
		files.map((file) => fs.readFile(`${path}/${file}`, "utf-8")),
	);
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
	let updatedContents = fileContents.replace(regex, "$1");

	// Remove Git source links too. Here's an example:
	// Source string: [Git Source](https://github.com/sinasab/chronicle/blob/e1248aab69f37f18a6edef11fa8a709f9e92e6c9/packages/contracts/src/Witness.sol)
	// Replacement string: <empty>
	// TODO(sina) add these back once we're open sourcing the contracts.
	updatedContents = updatedContents.replace(/\[Git Source\]\([^\)]+\)/g, "");
	return updatedContents;
}
