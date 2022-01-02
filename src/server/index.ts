import express from "express";
import cors, { CorsOptions } from "cors";
import * as foo from "./handlers/foo.js";

const app = express();

const corsConfig: CorsOptions = {
	origin: process.env.ORIGIN
};
app.use(cors(corsConfig));

app.get("/foo", foo.handler);

const port = 9090;
app.listen(port);
