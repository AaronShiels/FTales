import { dirname, resolve as resolvePath } from "path";
import { fileURLToPath } from "url";
import webpack from "webpack";
import HtmlWebpackPlugin from "html-webpack-plugin";
import CopyPlugin from "copy-webpack-plugin";
import ResolveTypeScriptPlugin from "resolve-typescript-plugin";

const config = (env, { mode }) => {
	if (!mode) throw new Error("Mode not provided");
	const developmentBuild = mode !== "production";
	const src = "./src/client";
	const dist = "./dist/client";
	var absRoot = dirname(fileURLToPath(import.meta.url));

	console.log(`Mode: ${developmentBuild ? "Development" : "Release"}`);
	console.log(
		`Environment Variables: ${Object.entries(env)
			.map(([k, v]) => `${k}=${v}`)
			.join(", ")}`
	);
	console.log(`Root: ${absRoot}\nSource: ${src}\nDistributables: ${dist}`);

	const entry = `${src}/index.tsx`;

	const devtool = developmentBuild ? "inline-source-map" : false;
	const devServer = {
		static: {
			directory: dist
		},
		port: 8080
	};

	const resolveTypeScriptPlugin = new ResolveTypeScriptPlugin.default();
	const resolve = {
		extensions: [".ts", ".tsx", ".js", ".jsx", ".json"],
		plugins: [resolveTypeScriptPlugin]
	};

	const tsLoaderRule = {
		test: /\.ts(x?)$/,
		exclude: /node_modules/,
		use: [
			{
				loader: "ts-loader",
				options: {
					transpileOnly: !developmentBuild,
					configFile: "tsconfig.client.json"
				}
			}
		]
	};

	const module = { rules: [tsLoaderRule] };

	var absDist = resolvePath(absRoot, dist);
	const output = { filename: "app.[contenthash].js", path: absDist, clean: true };

	const htmlPlugin = new HtmlWebpackPlugin({ title: "FTales", template: `${src}/index.html` });
	const copyPlugin = new CopyPlugin({ patterns: [{ from: "assets/*/*", context: src }] });
	const definePlugin = new webpack.DefinePlugin({
		API_BASE_URL: JSON.stringify(env.API_BASE_URL)
	});
	const plugins = [htmlPlugin /*, copyPlugin*/, definePlugin];

	return {
		entry,
		mode,
		devtool,
		devServer,
		resolve,
		module,
		output,
		plugins
	};
};

export default config;
