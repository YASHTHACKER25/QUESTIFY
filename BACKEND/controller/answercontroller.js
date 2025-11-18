import { answervalidation } from "../validation/answervalidation.js";
import { createanswer, displayanswerbyid, findquestionidbyanswerid, updateanswercontent, deleteanswerbyid, findanswerbyid } from "../../DATABASE/functions/answerservices.js"
import { finduserbyid } from "../../DATABASE/functions/userservice.js";
import { calculateLevel } from "./levelcontroller.js";
import { findquestionlevelbyid, addanswertoquestion } from "../../DATABASE/functions/questionservices.js";
import { updateuserlevelandpoint } from "../../DATABASE/functions/userservice.js";
import { createAnswerNotification} from "../../DATABASE/functions/notificationservices.js";

export async function answer(req, res) {
  const validation = await answervalidation(req.body);
  if (!validation.questionfind) {
    return res.status(401).json({
      message: "question not found!!"
    })
  }
  if (validation.abusive) {
    return res.status(400).json({
      message: "Answer contains abusive or offensive words",
    });
  }
  if (validation.answernotmatch) {
    return res.status(400).json({
      message: "Question and answer are different ",
    });
  }
  const userid = req.user.id;
  const { content, questionid } = req.body;
  const newanswer = await createanswer({
    content,
    questionid,
    userId: userid,
  });
  await addanswertoquestion(questionid, newanswer.id);

  // notification
  await createAnswerNotification(newanswer);

  var points = 0;
  const user = await finduserbyid(userid);
  const qlevel = await findquestionlevelbyid(questionid);
  if (qlevel >= 1 && qlevel <= 3) {
    points = user.points + 10;
  }
  else if (qlevel >= 4 && qlevel <= 6) {
    points = user.points + 20;
  }
  else if (qlevel == 7 || qlevel == 8) {
    points = user.points + 40;
  }
  else if (qlevel == 9 || qlevel == 10) {
    points = user.points + 80;
  }
  const levelofuser = await calculateLevel(points);
  await updateuserlevelandpoint(userid, points, levelofuser);
  await user.save();
  res.json({
    message: "answer uploaded!!",
    answerid: { id: newanswer.id }
  })
}

export async function getanswers(req, res) {
  const { questionid } = req.params;
  try {
    const answers = await findanswersbyquestionid(questionid);
    res.json(answers);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
}

//UPDATE
export async function editanswer(req, res) {
  const { answerid } = req.params;
  const { content } = req.body;
  const userid = req.user.id;

  if (!content || content.trim() === '') {
    return res.status(400).json({ message: 'Question text is required' });
  }
  const questionid = await findquestionidbyanswerid(answerid);
  const validation = await answervalidation({ content, questionid });
  if (!validation.questionfind) {
    return res.status(401).json({
      message: "answer not found!!"
    })
  }
  if (validation.abusive) {
    return res.status(400).json({
      message: "Answer contains abusive or offensive words",
    });
  }
  if (validation.answernotmatch) {
    return res.status(400).json({
      message: "Question and answer are different ",
    });
  }

  const updated = await updateanswercontent(answerid, content.trim(), userid)

  if (!updated) {
    return res.status(404).json({ message: 'Question not found or not yours' });
  }

  res.json({
    message: 'Answer updated successfully',
    question: { id: updated._id, content: updated.content }
  });
}

//DELETE
export async function deleteanswer(req, res) {
  const { answerid } = req.params;
  const userid = req.user.id;

  const deleted = await deleteanswerbyid(answerid, userid);

  if (!deleted) {
    return res.status(404).json({ message: "Answer not found or you are not authorized to delete" });
  }

  // notification
  await createAnswerDeletedNotification(deleted, userid);

  res.json({ message: "Answer deleted successfully" });
}
