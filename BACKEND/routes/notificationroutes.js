// BACKEND/routes/notificationroutes.js
import express from "express";
import { getUserNotifications, markAsRead } from "../controller/notificationcontroller.js";
import { authmiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// 📬 Get all notifications for logged-in user
router.get("/", authmiddleware, getUserNotifications);

// ✅ Mark specific notification as read
router.put("/:id/read", authmiddleware, markAsRead);

export default router;
