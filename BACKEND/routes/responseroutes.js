import express from "express";
import { response, getResponsesForQuestion } from "../controller/responsecontroller.js";
import { authmiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.get("/user/:questionId", authmiddleware, getResponsesForQuestion);
router.post("/", authmiddleware, response);

export default router;
