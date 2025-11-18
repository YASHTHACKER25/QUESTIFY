import mongoose from "mongoose";

const otp = new mongoose.Schema(
  {
    userid: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    otp: {
      type: String,
      required: true,
    },
    expiresat: {
      type: Date,
      required: true,
    },
  },
  { timestamps: true }
);

const OTP = mongoose.model("Otp", otp);

export default OTP;