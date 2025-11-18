import { callGemini } from "../config/geminiconnection.js";
import { axiosInstance, URL } from "../config/perspectiveconnection.js";

// set difficulty level 
async function getQuestionLevel(questionText) {
  const prompt =
    `What is the difficulty of this question in 1 to 10? Reply only with a number. Question: ${questionText}`;
  const result = await callGemini(prompt);
  const level = Number(result);
  if(level >= 1 && level <= 10){
    return level;
  } 
  return 0;
}
async function subchecking(questionText,subject){
  const prompt=
  `is the question :${questionText} and the subject ${subject} is getting match.answer just in yes or no only dont any other one word`
  const result=await callGemini(prompt);
  if(result==="yes"||result==="Yes"){
    return true;
  }
  return false;
}

export async function questionvalidation(data) {
  const { content, subject, topic } = data;
    const textCheck = `Question: ${content}\nSubject: ${subject}\nTopic: ${topic}`;
    // calling perspective api
    try {
    const response = await axiosInstance.post(URL, {
      comment: { text: textCheck },
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
    const limit = 0.2; 
    const isAbusive =
      scores.TOXICITY.summaryScore.value > limit ||
      scores.INSULT.summaryScore.value > limit ||
      scores.IDENTITY_ATTACK.summaryScore.value > limit ||
      scores.SEVERE_TOXICITY.summaryScore.value > limit ||
      scores.SEXUALLY_EXPLICIT.summaryScore.value > limit;

    if (isAbusive) {
      return { abusive: true, level: null };
    }

    const subcheck=await subchecking(content,subject);
    if(!subcheck){
      return {subjectnotmatch: true}
    }
    const level = await getQuestionLevel(content);
    return { abusive: false, level ,subjectnotmatch:false};

  }
  catch (err) {
  console.error("Perspective API error:", err.message);
  return { error: "Perspective API call failed" };
}
}
