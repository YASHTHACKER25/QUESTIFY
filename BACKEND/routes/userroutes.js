import express, { Router } from "express";
import {question,answer,userdetails,logout,editdetails,updateemail} from "../controller/usercontroller.js"
import {  verifyotpforemailupdate } from "../validation/otpvalidation.js";
import { authmiddleware } from "../middleware/authmiddleware.js";
import upload from "../middleware/uploadmiddleware.js";
import { updateProfileImage } from "../controller/profileimagecontroller.js";
const router = express.Router();

router.post("/details",authmiddleware,userdetails);
router.post("/questions",authmiddleware,question);
router.post("/answers",authmiddleware,answer);
router.post("/logout",authmiddleware,logout);
router.put("/editdetails",authmiddleware,editdetails);
router.put("/updateemail", authmiddleware, updateemail);
router.post("/updateemail/verifyotp",authmiddleware,verifyotpforemailupdate);
router.post("/profile/avatar",authmiddleware,upload.single("avatar"),updateProfileImage);
export default router;
