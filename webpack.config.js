import { dirname } from "path";
import { fileURLToPath } from "url";
import webpack from "webpack";
import HtmlWebpackPlugin from "html-webpack-plugin";
import CopyPlugin from "copy-webpack-plugin";
import ResolveTypeScriptPlugin from "resolve-typescript-plugin";

const config = (env, { mode }) => {
	if (!mode) throw new Error("Mode not provided");
	const developmentBuild = mode !== "production";
	console.log(`Configuration: ${developmentBuild ? "Development" : "Release"}`);
	console.log(
		`Environment Variables: ${Object.entries(env)
			.map(([k, v]) => `${k}=${v}`)
			.join(", ")}`
	);

	const clientRoot = dirname(fileURLToPath(import.meta.url));

	const entry = "./src/client/index.tsx";

	const devtool = developmentBuild ? "inline-source-map" : false;
	const devServer = {
		static: {
			directory: clientRoot
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

	const output = { filename: "app.[contenthash].js", path: clientRoot, clean: true };

	const htmlPlugin = new HtmlWebpackPlugin({ title: "FTales", template: "./src/client/index.html" });
	const copyPlugin = new CopyPlugin({ patterns: [{ from: "assets/*/*", context: "./src/client" }] });
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
