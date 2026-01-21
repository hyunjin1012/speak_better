import { Router } from "express";
import { z } from "zod";
import multer from "multer";
import fs from "fs";
import path from "path";
import { openai } from "../lib/openai.js";
import { ImproveResultSchema } from "../lib/schema.js";
import { buildImproveInstructions } from "../lib/prompt.js";

// Configure multer to handle multipart/form-data
// Multer automatically parses text fields and puts them in req.body
const upload = multer({ 
  dest: path.join(process.cwd(), "uploads"),
  preservePath: true,
  // Ensure multer handles both file and text fields
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
});

export const improveRouter = Router();

const ImproveRequestSchema = z.object({
  language: z.enum(["ko", "en"]),
  learnerMode: z.enum(["korean_learner", "english_learner"]),
  topic: z
    .object({
      title: z.string().optional(),
      prompt: z.string().optional(),
    })
    .optional(),
  transcript: z.string().min(1),
  preferences: z
    .object({
      tone: z.enum(["neutral", "formal", "casual"]).optional(),
      length: z.enum(["similar", "shorter", "longer"]).optional(),
    })
    .optional(),
});

improveRouter.post("/", upload.single("image"), async (req, res) => {
  const imageFile: Express.Multer.File | undefined = req.file;
  try {
    // Log immediately to ensure we see this in logs
    console.log("=== IMPROVE REQUEST START ===");
    console.log("Content-Type:", req.headers['content-type']);
    console.log("Method:", req.method);
    console.log("Path:", req.path);
    let body = req.body;
    
    console.log("=== IMPROVE REQUEST BODY ===");
    console.log("Has image file:", !!imageFile);
    if (imageFile) {
      console.log("Image file:", {
        fieldname: imageFile.fieldname,
        originalname: imageFile.originalname,
        mimetype: imageFile.mimetype,
        size: imageFile.size,
      });
    }
    console.log("Raw body:", JSON.stringify(body));
    console.log("Body type:", typeof body);
    console.log("Body is array:", Array.isArray(body));
    console.log("Body keys:", Object.keys(body || {}));
    console.log("Body values:", {
      language: body?.language,
      learnerMode: body?.learnerMode,
      transcript: body?.transcript ? `${body.transcript.substring(0, 50)}...` : undefined,
      topic: body?.topic,
      preferences: body?.preferences,
    });
    
    // Ensure body is an object
    if (!body || typeof body !== 'object' || Array.isArray(body)) {
      console.warn("Body is not a valid object, initializing empty object");
      body = {};
    }
    
    // If body is empty but we have an image, multer might not have parsed text fields
    if (Object.keys(body).length === 0 && imageFile) {
      console.error("ERROR: Body is empty but image file exists!");
      console.error("This suggests multer did not parse text fields from multipart/form-data");
      console.error("Request headers:", JSON.stringify(req.headers));
      return res.status(400).json({
        error: "Failed to parse form data",
        details: "Text fields were not received. Please check Content-Type header.",
        debug: {
          hasImageFile: !!imageFile,
          bodyKeys: Object.keys(body),
          contentType: req.headers['content-type'],
        },
      });
    }
    
    // Parse JSON fields if they were sent as strings (from multipart form)
    try {
      if (typeof body.topic === 'string' && body.topic.trim() !== '') {
        body.topic = JSON.parse(body.topic);
      }
      if (typeof body.preferences === 'string' && body.preferences.trim() !== '') {
        body.preferences = JSON.parse(body.preferences);
      }
    } catch (parseError: any) {
      console.error("JSON parse error:", parseError);
      // If parsing fails, set to undefined
      if (typeof body.topic === 'string') body.topic = undefined;
      if (typeof body.preferences === 'string') body.preferences = undefined;
    }
    
    console.log("Parsed body:", body);
    
    // Validate required fields before parsing
    if (!body.language || !body.learnerMode || !body.transcript) {
      console.error("Missing required fields:", {
        hasLanguage: !!body.language,
        hasLearnerMode: !!body.learnerMode,
        hasTranscript: !!body.transcript,
        allBodyKeys: Object.keys(body),
        bodyType: typeof body,
        bodyIsArray: Array.isArray(body),
      });
      return res.status(400).json({
        error: "Missing required fields",
        details: {
          language: body.language || "missing",
          learnerMode: body.learnerMode || "missing",
          transcript: body.transcript ? "present" : "missing",
          receivedFields: Object.keys(body),
        },
      });
    }
    
    // Try to parse with Zod schema
    let parsed;
    try {
      parsed = ImproveRequestSchema.parse(body);
    } catch (zodError: any) {
      console.error("Zod validation error:", zodError);
      console.error("Body that failed validation:", JSON.stringify(body, null, 2));
      return res.status(400).json({
        error: zodError.errors || zodError.message || "Validation failed",
        details: zodError.errors,
      });
    }
    
    // Log the transcript being processed
    console.log("=== IMPROVE REQUEST ===");
    console.log("Transcript received:", parsed.transcript);
    console.log("Transcript length:", parsed.transcript.length);
    console.log("Language:", parsed.language);
    console.log("Learner mode:", parsed.learnerMode);
    console.log("Has image:", !!imageFile);
    
    // Prepare image data if provided (for direct viewing by AI)
    let imageData: { base64: string; mimeType: string } | null = null;
    if (imageFile) {
      try {
        const imageBuffer = fs.readFileSync(imageFile.path);
        const base64Image = imageBuffer.toString("base64");
        const mimeType = imageFile.mimetype || "image/jpeg";
        imageData = { base64: base64Image, mimeType };
        console.log("Image prepared for AI viewing");
      } catch (e) {
        console.error("Failed to prepare image:", e);
        // Continue without image if preparation fails
      }
    }
    
    const instructions = buildImproveInstructions({
      language: parsed.language,
      learnerMode: parsed.learnerMode,
      topicTitle: parsed.topic?.title,
      topicPrompt: parsed.topic?.prompt,
      transcript: parsed.transcript,
      tone: parsed.preferences?.tone,
      length: parsed.preferences?.length,
      imageDescription: imageData ? "Image provided - AI can see the image directly" : undefined,
    });

    // Build user message content - include image if available
    const userContent: Array<
      | { type: "text"; text: string }
      | { type: "image_url"; image_url: { url: string } }
    > = [
      {
        type: "text",
        text: parsed.language === "ko"
          ? `다음은 사용자가 이미지에 대해 말한 내용입니다. 이미지를 직접 보고 정확하게 평가해주세요:\n\n"${parsed.transcript}"`
          : `The following is what the user said about the image. Please view the image directly and evaluate accurately:\n\n"${parsed.transcript}"`,
      },
    ];

    // Add image if available
    if (imageData) {
      userContent.push({
        type: "image_url",
        image_url: {
          url: `data:${imageData.mimeType};base64,${imageData.base64}`,
        },
      });
    }

    // Using Chat Completions API with structured outputs (JSON mode)
    // GPT-4o-mini can see images directly
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: instructions },
        { role: "user", content: userContent },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "ImproveResult",
          strict: true,
          schema: {
            type: "object",
            additionalProperties: false,
            required: ["improved", "alternatives", "feedback"],
            properties: {
              improved: { type: "string" },
              alternatives: {
                type: "object",
                additionalProperties: false,
                required: ["formal", "casual", "concise"],
                properties: {
                  formal: { type: "string" },
                  casual: { type: "string" },
                  concise: { type: "string" },
                },
              },
              feedback: {
                type: "object",
                additionalProperties: false,
                required: ["summary", "grammar_fixes", "vocabulary_upgrades", "filler_words"],
                properties: {
                  summary: {
                    type: "array",
                    items: { type: "string" },
                    minItems: 1,
                    maxItems: 6,
                  },
                  grammar_fixes: {
                    type: "array",
                    items: {
                      type: "object",
                      additionalProperties: false,
                      required: ["from", "to", "why"],
                      properties: {
                        from: { type: "string" },
                        to: { type: "string" },
                        why: { type: "string" },
                      },
                    },
                    maxItems: 20,
                  },
                  vocabulary_upgrades: {
                    type: "array",
                    items: {
                      type: "object",
                      additionalProperties: false,
                      required: ["from", "to", "why"],
                      properties: {
                        from: { type: "string" },
                        to: { type: "string" },
                        why: { type: "string" },
                      },
                    },
                    maxItems: 20,
                  },
                  filler_words: {
                    type: "object",
                    additionalProperties: false,
                    required: ["count", "examples"],
                    properties: {
                      count: { type: "integer", minimum: 0 },
                      examples: {
                        type: "array",
                        items: { type: "string" },
                        maxItems: 20,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    // Extract JSON text from the response
    const text = response.choices[0]?.message?.content;
    if (!text) {
      return res.status(500).json({ error: "Model did not return content." });
    }

    let json: unknown;
    try {
      json = JSON.parse(text);
    } catch {
      return res.status(500).json({ error: "Model did not return valid JSON." });
    }

    const validated = ImproveResultSchema.parse(json);
    
    // Clean up image file after processing
    if (imageFile) {
      try {
        fs.unlinkSync(imageFile.path);
      } catch (e) {
        console.error("Failed to delete image file:", e);
      }
    }
    
    return res.json(validated);
  } catch (err: any) {
    // Clean up image file on error too
    if (imageFile) {
      try {
        fs.unlinkSync(imageFile.path);
      } catch (e) {
        console.error("Failed to delete image file on error:", e);
      }
    }
    console.error("=== IMPROVE ERROR ===");
    console.error("Error:", err);
    console.error("Error name:", err?.name);
    console.error("Error message:", err?.message);
    console.error("Error stack:", err?.stack);
    
    // Handle Zod validation errors
    if (err?.name === 'ZodError') {
      console.error("Validation errors:", err.errors);
      return res.status(400).json({ 
        error: "Invalid request data",
        details: err.errors,
      });
    }
    
    // Handle OpenAI API errors
    if (err?.response) {
      console.error("OpenAI API error:", err.response.data);
      return res.status(500).json({ 
        error: "AI service error",
        details: err.response.data?.error?.message || err.message,
      });
    }
    
    const msg = err?.message ?? "Improve failed";
    return res.status(500).json({ 
      error: msg,
      details: err?.details || err?.error?.message,
    });
  }
});

