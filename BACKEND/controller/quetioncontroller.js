import { questionvalidation} from "../validation/quetionvalidation.js";
import {createquestion,displayquestionbyid,updatequestioncontent, findsubjectbyquestionid,deletequestionbyid} from "../../DATABASE/functions/questionservices.js"
import { finduserbyid } from "../../DATABASE/functions/userservice.js";
import { calculateLevel } from "./levelcontroller.js";
import { updateuserlevelandpoint } from "../../DATABASE/functions/userservice.js";
import {findSubjectByName,createSubject}from "../../DATABASE/functions/subjectservices.js"
import { countResponses ,checkUserResponseType} from "../../DATABASE/functions/responseservices.js";

//CREATE
export async function question(req, res) {

    const validation = await questionvalidation(req.body);
    if (validation.abusive) {
      return res.status(400).json({
        message: "Question contains abusive or offensive words",
      });
    }
    if(validation.subjectnotmatch){
        return res.status(400).json({
        message: "Question and Subject are different ",
      });
    }

    const level=validation.level;
    const userid = req.user.id;
    const {content,subject,topic}=req.body
    const newquestion = await createquestion({
      content,
      subject,
      topic,
      userId: userid,
      level,
    });
    const user=await finduserbyid(userid);
    const points=user.points+10;
    const levelofuser=await calculateLevel(points);
    await updateuserlevelandpoint(userid,points,levelofuser);
    await user.save();
    const s=await findSubjectByName(subject);
    if(!s)
    {
      await createSubject(subject);
    }


    res.json({
        message:"Question uploaded!!",
        question: { id: newquestion.id}
     })
}

// DISPLAY (final improved)
export async function displayquestion(req, res) {
  try {
    const { questionid } = req.params;
    const userId = req.user.id;

    // ✅ Fetch question + all answers populated
    const question = await displayquestionbyid(questionid);
    if (!question) {
      return res.status(404).json({ message: "Question not found" });
    }

    // ✅ Prepare all answer IDs to fetch response data in one go (faster)
    const answerIds = question.answers.map(ans => ans._id);

    // ✅ Fetch all helpful/notHelpful counts for these answers
    const responseCounts = await Promise.all(
      answerIds.map(id => countResponses(id))
    );

    // ✅ Fetch user’s existing responses for these answers
    const userResponses = await Promise.all(
      answerIds.map(id => checkUserResponseType(id, userId))
    );

    // ✅ Merge everything together
    const updatedAnswers = question.answers.map((ans, i) => ({
      ...ans.toObject(),
      helpfulCount: responseCounts[i]?.helpful || 0,
      notHelpfulCount: responseCounts[i]?.nothelpful || 0,
      userResponse: userResponses[i] || null, // "helpful" / "nothelpful" / null
    }));

    // ✅ Send final object
    res.json({
      question: {
        ...question.toObject(),
        answers: updatedAnswers,
      },
    });
  } catch (error) {
    console.error("❌ Error displaying question:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
}


//UPDATE
  export async function editquestion(req, res) {
      const { questionid } = req.params;        
      const { content } = req.body;  
      const userid=req.user.id;            

      if (!content || content.trim() === '') {
        return res.status(400).json({ message: 'Question text is required' });
      }
      const subject=await findsubjectbyquestionid(questionid);
      const validation = await questionvalidation({content,subject});
      if (validation.abusive) {
        return res.status(400).json({
          message: "Question contains abusive or offensive words",
        });
      }
      if(validation.subjectnotmatch){
          return res.status(400).json({
          message: "Question and Subject are different ",
        });
      }

      const updated = await updatequestioncontent(questionid, content.trim(), userid)

      if (!updated) {
        return res.status(404).json({ message: 'Question not found or not yours' });
      }

      res.json({
        message: 'Question updated successfully',
        question: { id: updated._id, content: updated.content }
      });
    }
  //DELETE
    export async function deletequestion(req, res) {
    const { questionid } = req.params;
    const userid = req.user.id;

    const deleted = await deletequestionbyid(questionid, userid);

    if (!deleted) {
      return res.status(404).json({ message: "Question not found or not yours" });
    }

    res.json({ message: "Question deleted successfully" });
  }
