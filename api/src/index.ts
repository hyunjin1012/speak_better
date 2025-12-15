import "dotenv/config";
import express from "express";
import cors from "cors";
import { transcribeRouter } from "./routes/transcribe.js";
import { improveRouter } from "./routes/improve.js";

const app = express();

app.use(cors());
app.use(express.json({ limit: "2mb" }));

app.get("/health", (_req, res) => res.json({ ok: true }));

app.use("/v1/transcribe", transcribeRouter);
app.use("/v1/improve", improveRouter);

const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => console.log(`API listening on :${port}`));

