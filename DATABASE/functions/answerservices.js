  import Answer from "../models/answer.js";
  import Question from "../models/question.js";
  export async function createanswer(answerdata) {
    const answer = new Answer(answerdata);
    return await answer.save();
  }
  export async function findanswerbyid(answerid) {
    try {
      return await Answer.findById(answerid);
    } catch (err) {
      console.error("Error in findanswerbyid:", err);
      return null;
    }
  }

  export async function findanswersbyuserid(userId) {
    return await Answer.find({ userId }).sort({ createdAt: -1 });
  }
  export async function findUserIdByAnswerId(answerid) {
      const answer = await Answer.findById(answerid).select('userId');
      if (!answer) {
        return null; // answer not found
      }
      return answer.userId;
    }
  export async function updateanswercontent(answerId, newContent, userId) {
    return await Answer.findOneAndUpdate(
      { _id: answerId, userId },
      { content: newContent },
      { new: true, runValidators: true }
    );}

    export async function findquestionidbyanswerid(answerid)
    {
      const answer = await Answer.findById(answerid).select("questionid");
    return answer ? answer.questionid : null;
    }

    export async function getLastRewardedPointCount(answerId) {
      const answer = await Answer.findById(answerId).select('lastHelpfulPointCount');
      if (!answer) {
        return null; // Answer not found
      }
      return answer.lastHelpfulPointCount;
    } 

    export async function findanswersbyquestionid(questionid) {
    return Answer.find({ questionid: questionid })
                .sort({ createdAt: -1 })
                .populate("userId", "Username");
  }

  // export async function deleteanswerbyid(answerId, userId) {
  //   const deleted = await Answer.findOneAndDelete({ _id: answerId, userId });
  //   return !!deleted;
  //}

  export async function getanswerbyid(userId) {
      // fetch answers and populate questionId (optional: to get question reference if needed)
      const answers = await Answer.find({ userId })
        .sort({ createdAt: -1 })
        .select('_id content questionid userId'); // only send necessary fields
      return answers;
    }
  //displaying:
  export async function displayanswerbyid(id) {
    return await Answer.findById(id)
      .populate('userId', 'Username') // populate username only
      .select('_id content questionid userId responses'); // pick only needed fields
  }
//deleting
  export async function deleteanswerbyid(answerId, userId) {
  try {
    // 1️⃣ Find the answer
    const answer = await Answer.findById(answerId);
    if (!answer) return false;

    // 2️⃣ Find the related question
    const questionDoc = await Question.findById(answer.questionid);
    if (!questionDoc) return false;

    // 3️⃣ Check if user is owner of answer OR question
    const isAnswerOwner = answer.userId.toString() === userId.toString();
    const isQuestionOwner = questionDoc.userId.toString() === userId.toString();

    if (!isAnswerOwner && !isQuestionOwner) {
      return false; // ❌ Not allowed
    }

    // 4️⃣ Delete the answer
    await Answer.findByIdAndDelete(answerId);

    // 5️⃣ Remove answer reference from question.answers array
    await Question.findByIdAndUpdate(answer.questionid, {
      $pull: { answers: answerId },
    });

    return true;
  } catch (err) {
    console.error("Error deleting answer:", err);
    return false;
  }
}