import mongoose from "mongoose";

const LevelSchema = new mongoose.Schema({
  name:      { type: String, required: true, unique: true },
  minPoints: { type: Number, required: true }, // inclusive lower bound
  maxPoints: { type: Number, required: true }, // inclusive upper bound
});

export default mongoose.model("Level", LevelSchema);
