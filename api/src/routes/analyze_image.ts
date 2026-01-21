import { Router } from "express";
import multer from "multer";
import fs from "fs";
import path from "path";
import { openai } from "../lib/openai.js";
import { buildImproveInstructions } from "../lib/prompt.js";

const upload = multer({ 
  dest: path.join(process.cwd(), "uploads"),
  preservePath: true,
});

export const analyzeImageRouter = Router();

analyzeImageRouter.post("/", upload.single("image"), async (req, res) => {
  try {
    const file = req.file;
    const language = (req.body.language ?? "en") as "ko" | "en";
    const learnerMode = (req.body.learnerMode ?? "english_learner") as "korean_learner" | "english_learner";

    if (!file) {
      return res.status(400).json({ error: "Missing image file" });
    }

    console.log("Received image file:", {
      originalname: file.originalname,
      mimetype: file.mimetype,
      path: file.path,
      size: file.size,
    });

    // Read image file as base64
    const imageBuffer = fs.readFileSync(file.path);
    const base64Image = imageBuffer.toString("base64");
    const mimeType = file.mimetype || "image/jpeg";

    // Use GPT-4 Vision to analyze the image
    const visionResponse = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: language === "ko"
            ? "당신은 이미지를 분석하고 설명하는 도우미입니다. 이미지에 대해 자세하고 자연스러운 설명을 제공하세요."
            : "You are a helpful assistant that analyzes and describes images. Provide detailed and natural descriptions of images.",
        },
        {
          role: "user",
          content: [
            {
              type: "text",
              text: language === "ko"
                ? "이 이미지를 자세히 분석하고 설명해주세요. 이미지에 무엇이 있는지, 어떤 상황인지, 어떤 느낌인지 등을 포함해서 자연스러운 언어로 설명해주세요."
                : "Please analyze and describe this image in detail. Describe what's in the image, what situation it shows, what feeling it conveys, etc. Use natural language.",
            },
            {
              type: "image_url",
              image_url: {
                url: `data:${mimeType};base64,${base64Image}`,
              },
            },
          ],
        },
      ],
      max_tokens: 1000,
    });

    const imageDescription = visionResponse.choices[0]?.message?.content || "";

    if (!imageDescription) {
      return res.status(500).json({ error: "Failed to analyze image" });
    }

    // Now improve the description based on learner mode
    const improveInstructions = buildImproveInstructions(language, learnerMode);
    
    const improveResponse = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: improveInstructions,
        },
        {
          role: "user",
          content: language === "ko"
            ? `다음은 이미지에 대한 설명입니다. 이 설명을 개선하고 더 나은 표현으로 바꿔주세요:\n\n${imageDescription}`
            : `The following is a description of an image. Please improve this description and provide better expressions:\n\n${imageDescription}`,
        },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "improve_result",
          schema: {
            type: "object",
            properties: {
              improved: {
                type: "string",
                description: "Improved version of the description",
              },
              alternatives: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    style: { type: "string" },
                    text: { type: "string" },
                  },
                  required: ["style", "text"],
                },
                description: "Alternative versions with different styles",
              },
              feedback: {
                type: "object",
                properties: {
                  grammar: {
                    type: "array",
                    items: {
                      type: "object",
                      properties: {
                        original: { type: "string" },
                        improved: { type: "string" },
                        explanation: { type: "string" },
                      },
                      required: ["original", "improved", "explanation"],
                    },
                  },
                  vocabulary: {
                    type: "array",
                    items: {
                      type: "object",
                      properties: {
                        original: { type: "string" },
                        improved: { type: "string" },
                        explanation: { type: "string" },
                      },
                      required: ["original", "improved", "explanation"],
                    },
                  },
                  fillerWords: {
                    type: "array",
                    items: { type: "string" },
                  },
                },
                required: ["grammar", "vocabulary", "fillerWords"],
              },
            },
            required: ["improved", "alternatives", "feedback"],
          },
        },
      },
    });

    const improveResult = JSON.parse(improveResponse.choices[0]?.message?.content || "{}");

    // Clean up uploaded file
    try {
      fs.unlinkSync(file.path);
    } catch (e) {
      console.error("Failed to delete uploaded file:", e);
    }

    res.json({
      original: imageDescription,
      ...improveResult,
    });
  } catch (error: any) {
    console.error("Image analysis error:", error);
    res.status(500).json({
      error: error.message || "Failed to analyze image",
    });
  }
});
