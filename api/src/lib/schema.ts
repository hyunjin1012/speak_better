import { z } from "zod";

export const ImproveResultSchema = z.object({
  improved: z.string(),
  alternatives: z.object({
    formal: z.string(),
    casual: z.string(),
    concise: z.string(),
  }),
  feedback: z.object({
    summary: z.array(z.string()).min(1).max(6),
    grammar_fixes: z.array(z.object({
      from: z.string(),
      to: z.string(),
      why: z.string(),
    })).max(20),
    vocabulary_upgrades: z.array(z.object({
      from: z.string(),
      to: z.string(),
      why: z.string(),
    })).max(20),
    filler_words: z.object({
      count: z.number().int().nonnegative(),
      examples: z.array(z.string()).max(20),
    }),
  }),
});

export type ImproveResult = z.infer<typeof ImproveResultSchema>;

