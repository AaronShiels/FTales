import express from "express";
import cors from "cors";
import * as health from "./handlers/health.js";
import * as tales from "./handlers/tales.js";

const app = express();
const { ORIGINS, PORT } = process.env;
if (!ORIGINS || !PORT) throw new Error("Required environment variables are undefined.");

const origins = ORIGINS.split(",").map((o) => o.trim());
const corsMiddleware = cors({ origin: origins });
app.use(corsMiddleware);

app.get("/health", health.handler);
app.get("/tales", tales.handler);

const port = parseInt(PORT);
app.listen(port);
