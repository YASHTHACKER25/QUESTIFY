import express from "express";
import { forgotPassword,setpassword,resetpassword} from "../controller/passwordcontroller.js"
import { verifyotpforpassword } from "../validation/otpvalidation.js";
import {passwordresettoken} from "../middleware/passwordmiddleware.js"


const router = express.Router();

router.post("/forgot", forgotPassword);
router.post("/forgot/verifyotp",verifyotpforpassword);
router.post("/set",passwordresettoken,setpassword);
router.post("/reset",passwordresettoken,resetpassword)

export default router;