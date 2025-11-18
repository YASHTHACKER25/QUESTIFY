import express from "express"
import { authmiddleware } from "../middleware/authmiddleware.js";
import { answer,getanswers,editanswer,deleteanswer } from "../controller/answercontroller.js";

const router=express.Router();
router.post("/create",authmiddleware,answer);
router.get('/display/:answerid',authmiddleware ,getanswers);
router.put('/edit/:answerid',authmiddleware ,editanswer);
router.delete('/delete/:answerid',authmiddleware ,deleteanswer);


export default router