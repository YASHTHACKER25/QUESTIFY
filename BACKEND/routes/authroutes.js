import express from "express";
import { login, register } from "../controller/authcontroller.js";
import { verifyotp} from "../validation/otpvalidation.js";



const router = express.Router();

router.post("/login", login);
router.post("/register", register);
router.post("/verifyotp", verifyotp);





export default router;
