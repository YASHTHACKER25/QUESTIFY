import express from "express";
import { authmiddleware } from "../middleware/authmiddleware.js";
import { addComment, getComments, deleteCommentById } from "../controller/commentcontroller.js";

const router = express.Router();

router.post("/create", authmiddleware, addComment);
router.get("/list/:answerId", authmiddleware, getComments);
router.delete("/delete/:commentId", authmiddleware, deleteCommentById);

export default router;
