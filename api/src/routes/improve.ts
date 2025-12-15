import { Router } from "express";
import { z } from "zod";
import { openai } from "../lib/openai.js";
import { ImproveResultSchema } from "../lib/schema.js";
import { buildImproveInstructions } from "../lib/prompt.js";

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

improveRouter.post("/", async (req, res) => {
  try {
    const parsed = ImproveRequestSchema.parse(req.body);
    
    // Log the transcript being processed
    console.log("=== IMPROVE REQUEST ===");
    console.log("Transcript received:", parsed.transcript);
    console.log("Transcript length:", parsed.transcript.length);
    console.log("Language:", parsed.language);
    console.log("Learner mode:", parsed.learnerMode);
    
    const instructions = buildImproveInstructions({
      language: parsed.language,
      learnerMode: parsed.learnerMode,
      topicTitle: parsed.topic?.title,
      topicPrompt: parsed.topic?.prompt,
      transcript: parsed.transcript,
      tone: parsed.preferences?.tone,
      length: parsed.preferences?.length,
    });

    // Using Chat Completions API with structured outputs (JSON mode)
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: instructions },
        { role: "user", content: `Transcript to improve: "${parsed.transcript}"` },
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
    return res.json(validated);
  } catch (err: any) {
    console.error("Improve error:", err);
    console.error("Error details:", {
      message: err?.message,
      status: err?.status,
      response: err?.response?.data,
      stack: err?.stack,
    });
    const msg = err?.message ?? "Improve failed";
    return res.status(400).json({ 
      error: msg,
      details: err?.response?.data ?? err?.error?.message,
    });
  }
});

