import Comment from "../models/comment.js";
import Answer from "../models/answer.js";

export async function createComment(data) {
  const comment = new Comment(data);
  const savedComment = await comment.save();
  await Answer.findByIdAndUpdate(data.answerId, { $push: { comments: savedComment._id } });
  return savedComment;
}

export async function getCommentsByAnswer(answerId) {
  return await Comment.find({ answerId })
    .populate("userId", "Username")
    .sort({ createdAt: -1 });
}

export async function deleteComment(commentId, userId) {
  const comment = await Comment.findById(commentId);
  if (!comment) return false;

  if (comment.userId.toString() !== userId.toString()) return false;

  await Comment.findByIdAndDelete(commentId);
  await Answer.findByIdAndUpdate(comment.answerId, { $pull: { comments: commentId } });

  return true;
}
export async function getcommentbyid(userId) {
  // find all comments for the user
  const comments = await Comment.find({ userId })
    .sort({ createdAt: -1 })
    .populate({
      path: "answerId",
      select: "questionid"  // only fetch questionId from Answer
    })
    .select("_id content userId answerId createdAt");

  // format results so questionId is included in each comment
  return comments.map(comment => ({
    _id: comment._id,
    content: comment.content,
    userId: comment.userId,
    answerId: comment.answerId?._id || null,
    questionId: comment.answerId?.questionid || null,  // safely extracted
    createdAt: comment.createdAt
  }));
}
