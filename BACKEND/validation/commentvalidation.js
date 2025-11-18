import { axiosInstance, URL } from "../config/perspectiveconnection.js";

export async function commentvalidation(commentdata) {
  try {
    const { content } = commentdata;

    const response = await axiosInstance.post(URL, {
      comment: { text: content },
      languages: ["en"],
      requestedAttributes: {
        TOXICITY: {},
        INSULT: {},
        IDENTITY_ATTACK: {},
        SEVERE_TOXICITY: {},
        SEXUALLY_EXPLICIT: {}
      }
    });

    const scores = response.data.attributeScores;
    const limit = 0.2; // You can adjust this if needed

    const isAbusive =
      scores.TOXICITY.summaryScore.value > limit ||
      scores.INSULT.summaryScore.value > limit ||
      scores.IDENTITY_ATTACK.summaryScore.value > limit ||
      scores.SEVERE_TOXICITY.summaryScore.value > limit ||
      scores.SEXUALLY_EXPLICIT.summaryScore.value > limit;

    if (isAbusive) {
      return { abusive: true };
    }

    return { abusive: false };
  } catch (error) {
    console.error("Perspective API Error:", error);
    return { abusive: false, error: true };
  }
}
