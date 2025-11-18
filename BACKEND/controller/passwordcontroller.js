import bcrypt from "bcryptjs";
import { generateotp } from "./otpcontroller.js";
import {finduserbyid, finduserbyemail,updateUserPassword} from "../../DATABASE/functions/userservice.js";
import{checkpassword} from "../validation/authvalidation.js"

//forgotpassword
export async function forgotPassword(req, res) {
  const { email} = req.body;

  if (!email) {
    return res.status(400).json({ message: "Email is required" });
  }

  const user = await finduserbyemail(email);
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  await generateotp(user.id);

  res.json({
    message: "OTP sent to your email. Use it to reset your password.",
    userid: user.id,
    email: user.Email
  });
}

export async function setpassword(req, res) {
     const { Email,newpassword} = req.body;
     if (!Email||!newpassword) {
    return res.status(400).json({ message: "Email and password are  required" })}

    const user = await finduserbyemail(Email);
    if (!user) {
    return res.status(404).json({ message: "User not found" });}

    if(!checkpassword(newpassword)){
        return res.status(400).json({
      message:
        "Password must be at least 8 characters, include uppercase, lowercase, number, and special character",
    });}
    const userid=user.id;
    const hashpassword=await bcrypt.hash(newpassword,10);
    await updateUserPassword(userid, hashpassword);
    res.json({ message: "Password reset successfully!" });
  }
export async function resetpassword(req, res) {
    const user = await finduserbyid(req.user.id);
    const { Password: oldPassword, newpassword } = req.body;
    const passcheck = await bcrypt.compare(oldPassword, user.Password);
    if (!passcheck) {
      return res.status(400).json({ message: "INVALID PASSWORD" });
    }

    const hashpassword = await bcrypt.hash(newpassword, 10);
    await updateUserPassword(user.id, hashpassword);

    res.json({ message: "Password reset successfully!" });
}
