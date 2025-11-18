import mongoose from "mongoose";

const UserSchema = new mongoose.Schema(
  {
    Username: { type: String, required: true, unique: true, trim: true, lowercase: true },
    Email:    { type: String, required: true, unique: true, trim: true, lowercase: true },
    Password: { type: String, required: true },
    Faviouratesubjects: { type: [String], default: [] },
    State:    { type: String, required: true },
    refreshToken: { type: String, default: null },
    isVerified: { type: Boolean, default: false },
    points: { type: Number, default: 0 },
    level:  { type: String, default: "Beginner" },
     profileAvatar: {
      type: String,
      default: null,
    },
    isAdmin: { type: Boolean, default: false },
  },
  { timestamps: true }
);

export default mongoose.model("User", UserSchema);

