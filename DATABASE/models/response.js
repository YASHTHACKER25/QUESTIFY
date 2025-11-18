import mongoose from "mongoose";

const ResponseSchema = new mongoose.Schema(
  {
    answerId: { type: mongoose.Schema.Types.ObjectId, ref: "Answer", required: true }, // link to the answer
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },    // who responded
    type: { type: String, enum: ["helpful", "nothelpful"], default: null },          // type of response
  },
  { timestamps: true }
);

export default mongoose.model("Response", ResponseSchema);
