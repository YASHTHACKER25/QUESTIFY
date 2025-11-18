import Question from "../models/question.js";
import Answer from "../models/answer.js";
import mongoose from "mongoose";
export async function createquestion(questiondata) {
  const question = new Question(questiondata);
  return await question.save();
}

// export async function findquestionbyid(id) {
//   return await Question.findById(id);
// }
export async function findquestionbyid(id) {
  const trimmedId = id;
  if (!mongoose.Types.ObjectId.isValid(trimmedId)) {
    console.log("Invalid question id:", trimmedId);
    return null;
  }
  return await Question.findById(trimmedId);
}

//displaying:
export async function displayquestionbyid(id) {
  return await Question.findById(id)
    // populate the question's author (only Username field)
    .populate('userId', 'Username')
    // populate answers, and within each answer populate the user who wrote it
    .populate({
      path: 'answers',
      select: 'content createdAt userId',   // only the fields you need from Answer
      populate: {
        path: 'userId',
        select: 'Username'                  // only the Username from User
      }
    })
    .select('_id content subject topic userId answers');
}
export async function getquestioncontentbyid(questionId)
{
  const questions = await Question.findById(questionId);
   return questions.content;
}

export async function getQuestionsBySubjects(subjectArray) {
  return Question.find(
    { subject: { $in: subjectArray } },
    "_id content createdAt userId"
  ).populate("userId", "Username");  }

  export async function findquestionsbyuserid(userId) {
  return await Question.find({ userId }).sort({ createdAt: -1 });
}

export async function findquestionlevelbyid(questionId) {
  const question = await Question.findById(questionId).select("level");
  return question ? question.level : null;   // returns the numeric level or null if not found
}

// DATABASE/functions/questionservices.js
export async function getRecentQuestions() {
  return Question.find({}, "_id content createdAt userId")
                 .sort({ createdAt: -1 })
                 .populate("userId", "Username");
}


export async function updatequestioncontent(questionId, newContent, userId) {
  return await Question.findOneAndUpdate(
    { _id: questionId, userId },
    { content: newContent },
    { new: true, runValidators: true }
  );}

  export async function  findsubjectbyquestionid(questionId)
{
  const questions = await Question.findById(questionId);
   return questions.subject;
}

export async function deletequestionbyid(questionId, userId) {
  // Delete all answers related to this question
  await Answer.deleteMany({ questionid: questionId });

  // Delete the question itself (only if it belongs to the user)
  const deleted = await Question.findOneAndDelete({ _id: questionId, userId });
  return !!deleted; // true if deleted, false otherwise
}


export async function addanswertoquestion(questionId, answerId) {
  return await Question.findByIdAndUpdate(
    questionId,
    { $push: { answers: answerId } },
    { new: true }   // returns the updated document
  );
}