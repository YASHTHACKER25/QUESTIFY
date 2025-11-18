import mongoose from "mongoose";

const CommentSchema = new mongoose.Schema(
  {
    content: { type: String, required: true, trim: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    answerId: { type: mongoose.Schema.Types.ObjectId, ref: "Answer", required: true },
  },
  { timestamps: true }
);

export default mongoose.model("Comment", CommentSchema);
