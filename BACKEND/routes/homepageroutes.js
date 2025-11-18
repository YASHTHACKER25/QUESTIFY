import express from "express"
import { authmiddleware } from "../middleware/authmiddleware.js";
import { homepage } from "../controller/homepagecontroller.js";

const router=express.Router();
router.get("/",authmiddleware,homepage);

export default router;