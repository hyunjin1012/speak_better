import { Router } from "express";
import multer from "multer";
import fs from "fs";
import path from "path";
import { openai } from "../lib/openai.js";

const upload = multer({ 
  dest: path.join(process.cwd(), "uploads"),
  preservePath: true,
});

export const transcribeRouter = Router();

transcribeRouter.post("/", upload.single("audio"), async (req, res) => {
  try {
    const file = req.file;
    const language = (req.body.language ?? "auto") as "ko" | "en" | "auto";

    if (!file) return res.status(400).json({ error: "Missing audio file" });

    // Log file info for debugging
    console.log("Received file:", {
      originalname: file.originalname,
      mimetype: file.mimetype,
      path: file.path,
      size: file.size,
    });

    // Read file as buffer and create File object for OpenAI SDK
    const fileBuffer = fs.readFileSync(file.path);
    
    // Extract extension from original filename or use m4a as default
    let fileName = file.originalname || "audio.m4a";
    // Ensure filename has proper extension
    if (!fileName.includes('.')) {
      fileName = `${fileName}.m4a`;
    }
    
    // Create a File object that OpenAI SDK can use
    // Node.js 18+ supports File constructor
    const fileForOpenAI = new File([fileBuffer], fileName, {
      type: file.mimetype || "audio/m4a",
    });
    
    console.log("File for OpenAI:", {
      name: fileForOpenAI.name,
      type: fileForOpenAI.type,
      size: fileForOpenAI.size,
    });

    const result = await openai.audio.transcriptions.create({
      file: fileForOpenAI,
      model: "whisper-1",
      // If you know the language, pass it; if auto, omit.
      ...(language === "auto" ? {} : { language }),
      response_format: "json",
    });

    // Cleanup temp file
    fs.unlinkSync(file.path);

    return res.json({
      transcript: result.text ?? "",
      language: language === "auto" ? undefined : language,
    });
  } catch (err: any) {
    console.error("Transcription error:", err);
    console.error("Error details:", {
      message: err?.message,
      status: err?.status,
      response: err?.response?.data,
      stack: err?.stack,
    });
    return res.status(500).json({ 
      error: err?.message ?? "Transcription failed",
      details: err?.response?.data ?? err?.error?.message,
    });
  }
});

