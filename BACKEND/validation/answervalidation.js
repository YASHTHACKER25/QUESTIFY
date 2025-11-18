import { callGemini } from "../config/geminiconnection.js";
import { axiosInstance, URL } from "../config/perspectiveconnection.js";
import {findquestionbyid,getquestioncontentbyid} from "../../DATABASE/functions/questionservices.js"

async function anschecking(question,answer){
    const prompt=
  `is the answer ${answer} releated with question ${question}do not check answer do not give response according to answer .if subject is maths and answer is in number whatever it is you should give yes it is just example consider accordingly for different subjects .answer just in yes or no only dont any other one word`
  const result=await callGemini(prompt);
  console.log(result)
if(result==="yes"||result==="Yes"){
    return true;
  }
  return false;
}

export async function answervalidation(answerdata){
    const {content,questionid}=answerdata;
    const question=await findquestionbyid(questionid);
    if(!question)
    {
      console.log(questionid);
       return {questionfind:false}
    }
    const questioncontent=await getquestioncontentbyid(questionid);
    const response = await axiosInstance.post(URL, {
      comment: { text: content },
      languages: ["en"],
      requestedAttributes: {TOXICITY: {},
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
      return {abusive: true,questionfind:true};
    }
    const anscheck=await anschecking(questioncontent,content);
    if(!anscheck){
      return {answernotmatch:true,questionfind:true}
    }
    return {absuive:false,answernotmatch:false,questionfind:true}
}