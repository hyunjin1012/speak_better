import "dotenv/config";
import express from "express";
import cors from "cors";
import { transcribeRouter } from "./routes/transcribe.js";
import { improveRouter } from "./routes/improve.js";
import { analyzeImageRouter } from "./routes/analyze_image.js";
import { verifyToken } from "./middleware/auth.js";

const app = express();

app.use(cors());
// IMPORTANT: Do NOT use express.json() or express.urlencoded() globally
// Multer handles multipart/form-data and automatically populates req.body with text fields
// Only parse JSON for specific routes that don't use multer

// Routes that don't use multer - parse JSON
app.get("/", express.json({ limit: "10mb" }), (_req, res) =>
  res.json({
    name: "Speak Better API",
    status: "running",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      transcribe: "/v1/transcribe",
      improve: "/v1/improve",
      analyzeImage: "/v1/analyze-image",
    },
    auth: "Bearer token required for /v1/* endpoints",
  })
);

app.get("/health", express.json({ limit: "10mb" }), (_req, res) => res.json({ ok: true }));

// Protect API routes with authentication
// Note: verifyToken runs before multer, but multer will still parse multipart/form-data correctly
app.use("/v1/transcribe", verifyToken, transcribeRouter);
app.use("/v1/improve", verifyToken, improveRouter);
app.use("/v1/analyze-image", verifyToken, analyzeImageRouter);

const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => console.log(`API listening on :${port}`));

