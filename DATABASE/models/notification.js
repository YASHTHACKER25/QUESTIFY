// DATABASE/models/notification.js
import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema({
  receiverId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  questionId: { type: mongoose.Schema.Types.ObjectId, ref: "question" },
  answerId: { type: mongoose.Schema.Types.ObjectId, ref: "Answer" },
  type: { type: String, enum: ["answer", "comment"], required: true },
  message: String,
  isRead: { type: Boolean, default: false },
}, { timestamps: true });

const Notification = mongoose.model("Notification", notificationSchema);
export default Notification;
