import mongoose from "mongoose";

const QuestionSchema = new mongoose.Schema(
  {
    content: { type: String, required: true, trim: true },
    subject: { type: String, required: true, trim: true },
    topic:   { type: String, required: true, trim: true },
    level:   { type: Number, required: true, min: 0, max: 10 },
    userId:  { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },

    // All answers to this question
    answers: [{ type: mongoose.Schema.Types.ObjectId, ref: "Answer" }],
  },
  { timestamps: true }
);

export default mongoose.model("question", QuestionSchema);
