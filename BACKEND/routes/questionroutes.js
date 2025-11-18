import express from "express"
import { question,displayquestion,editquestion,deletequestion } from "../controller/quetioncontroller.js";
import { authmiddleware } from "../middleware/authmiddleware.js";

const router=express.Router();
router.post("/create",authmiddleware,question);
router.get('/display/:questionid',authmiddleware ,displayquestion);
router.put('/edit/:questionid',authmiddleware ,editquestion);
router.delete('/delete/:questionid',authmiddleware ,deletequestion);

export default router

