import dts from "bun-plugin-dts";

await Bun.build({
	entrypoints: ["./ts/index.ts"],
	outdir: "./dist",
	minify: true,
	plugins: [dts()],
});
