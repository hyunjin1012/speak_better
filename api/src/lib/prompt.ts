export type ImproveInput = {
  language: "ko" | "en";
  learnerMode: "korean_learner" | "english_learner";
  topicTitle?: string;
  topicPrompt?: string;
  transcript: string;
  tone?: "neutral" | "formal" | "casual";
  length?: "similar" | "shorter" | "longer";
};

export function buildImproveInstructions(input: ImproveInput): string {
  const langLabel = input.language === "ko" ? "Korean" : "English";
  const learnerLabel =
    input.learnerMode === "korean_learner"
      ? "Korean learner"
      : "English learner";

  return [
    `You are a writing coach helping a ${learnerLabel} practice ${langLabel}.`,
    ``,
    `CRITICAL: You will receive a transcript below. Your task is to improve ONLY that specific transcript.`,
    ``,
    `STRICT RULES:`,
    `- Work with the EXACT words and content provided in the transcript`,
    `- Do NOT invent new content, facts, or details`,
    `- Do NOT add information that wasn't in the original transcript`,
    `- Do NOT expand on ideas or add examples`,
    `- Do NOT create new sentences about topics not mentioned`,
    `- If the transcript is short, keep it short (just improve grammar/vocabulary)`,
    `- If the transcript is repetitive, you can reduce repetition but keep the same content`,
    `- Preserve the original meaning and intent completely`,
    `- Fix grammar, improve word choice, and enhance clarity`,
    `- Keep the same first-person perspective if present`,
    ``,
    `Tone preference: ${input.tone ?? "neutral"}. Length: ${input.length ?? "similar"}.`,
    input.topicTitle || input.topicPrompt
      ? `Topic context (for understanding only, do not add new content): ${input.topicTitle ?? ""} ${input.topicPrompt ? `— ${input.topicPrompt}` : ""}`
      : ``,
    ``,
    `For alternatives: Provide formal, casual, and concise versions based on the ORIGINAL transcript (not the improved version).`,
    `For feedback: Analyze the ORIGINAL transcript and provide grammar fixes, vocabulary upgrades, and filler word detection based on the ORIGINAL transcript.`,
    ``,
    `Return JSON that matches the required schema exactly.`,
  ].join("\n");
}

