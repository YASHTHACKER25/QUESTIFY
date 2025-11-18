import mongoose from "mongoose";

const AnswerSchema = new mongoose.Schema(
  {
    content: { type: String, required: true, trim: true },
    questionid: { type: mongoose.Schema.Types.ObjectId, ref: "Question", required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    comments: [{ type: mongoose.Schema.Types.ObjectId, ref: "Comment" }],

    responses: [{ type: mongoose.Schema.Types.ObjectId, ref: "Response" }],
    
    lastHelpfulPointCount: { type: Number, default: 0 }
  },
  { timestamps: true }
);

export default mongoose.model("Answer", AnswerSchema);
