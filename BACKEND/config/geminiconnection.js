import "dotenv/config";
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: process.env.GOOGLE_API_KEY,
});

/**
 * Generic Gemini API call
 * @param {string} prompt - What you want Gemini to do
 * @returns {string|null} response text
 */
export async function callGemini(prompt) {
  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
    });

    const text = response.candidates[0].content.parts[0].text.trim();
    return text;
  } catch (err) {
    console.error("Gemini API error:", err);
    return null;
  }
}
