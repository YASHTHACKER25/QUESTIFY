import { createComment, getCommentsByAnswer, deleteComment } from "../../DATABASE/functions/commentservices.js";
import { commentvalidation } from "../validation/commentvalidation.js"; // ✅ import validation
import Comment from "../../DATABASE/models/comment.js";
import { createCommentNotification } from "../../DATABASE/functions/notificationservices.js";

export async function addComment(req, res) {
  try {
    const { answerId, content } = req.body;
    const userId = req.user.id;

    if (!content.trim()) {
      return res.status(400).json({ message: "Comment cannot be empty" });
    }

    const validation = await commentvalidation({ content });
    if (validation.abusive) {
      return res.status(400).json({ message: "Comment contains inappropriate language" });
    }

    const comment = await createComment({ answerId, content, userId });
    const fullComment = await Comment.findById(comment._id);
    await createCommentNotification(fullComment);

    res.json({ message: "Comment added", comment });
  } catch (err) {
    console.error("❌ Error adding comment:", err);
    res.status(500).json({ message: "Server error" });
  }
}
export async function getComments(req, res) {
  try {
    const { answerId } = req.params;
    const comments = await getCommentsByAnswer(answerId);
    res.json(comments);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
}

export async function deleteCommentById(req, res) {
  try {
    const { commentId } = req.params;
    const userId = req.user.id;

    const success = await deleteComment(commentId, userId);
    if (!success) {
      return res.status(403).json({ message: "Not authorized or comment not found" });
    }
    await createCommentDeletedNotification(success, userId);

    res.json({ message: "Comment deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
}
