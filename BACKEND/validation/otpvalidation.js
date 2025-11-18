import { finduserbyid ,updateUserIsVerified,updateUserEmailById} from "../../DATABASE/functions/userservice.js";
import { findotpbyuserid,deleteotpbyid } from "../../DATABASE/functions/otpservices.js";
import {generateToken,generateRefreshToken} from "../utils/generatetoken.js"
export const verifyotp = async (req, res) => {
    const { userid, otp } = req.body;

    if (!userid || !otp) {
      return res.status(400).json({
        message: "UserId and OTP are required",
        success: false,
      });
    }
    const user = await finduserbyid(userid);
    const otptoken = await findotpbyuserid(userid);
    if (!otptoken) {
      return res.status(404).json({
        message: "OTP not found or expired",
        success: false,
      });
    }

    if (otptoken.expiresat < new Date()) {
      await deleteotpbyid(otptoken.id);
      return res.status(400).json({
        message: "OTP expired",
        success: false,
      });
    }

    if (otptoken.otp !== otp) {
      return res.status(400).json({
        message: "Invalid OTP",
        success: false,
      });
    }

    await deleteotpbyid(otptoken.id);
    await updateUserIsVerified(userid,true);
     const accessToken = generateToken(userid,user.isAdmin);
     const refreshToken = generateRefreshToken(userid);  
     user.refreshToken = refreshToken;
     await user.save();

    return res.json({
    message: "OTP verified.",
    success: true,
    accessToken,
    refreshToken,
    admin:user.isAdmin,
  });
}

//verifyotp for password
export const verifyotpforpassword = async (req, res) => {
    const { userid, otp } = req.body;

    if (!userid || !otp) {
      return res.status(400).json({
        message: "UserId and OTP are required",
        success: false,
      });
    }
    const user = await finduserbyid(userid);
    const otptoken = await findotpbyuserid(userid);
    if (!otptoken) {
      return res.status(404).json({
        message: "OTP not found or expired",
        success: false,
      });
    }

    if (otptoken.expiresat < new Date()) {
      await deleteotpbyid(otptoken.id);
      return res.status(400).json({
        message: "OTP expired",
        success: false,
      });
    }

    if (otptoken.otp !== otp) {
      return res.status(400).json({
        message: "Invalid OTP",
        success: false,
      });
    }

    await deleteotpbyid(otptoken.id);

    const resetToken = generateToken(userid, "10m"); 
  return res.status(200).json({
    message: "OTP verified.",
    success: true,
    resetToken,    
  });
}
//verifyotpforupdagtemeail
export const verifyotpforemailupdate = async (req, res) => {
  const { userid, otp ,newEmail} = req.body;

  if (!userid || !otp) {
    return res.status(400).json({ message: "UserId and OTP are required", success: false });
  }

  const user = await finduserbyid(userid);
  if (!user) {
    return res.status(400).json({ message: "No email update request found", success: false });
  }

  const otptoken = await findotpbyuserid(userid);
  if (!otptoken) {
    return res.status(404).json({ message: "OTP not found or expired", success: false });
  }

  if (otptoken.expiresat < new Date()) {
    await deleteotpbyid(otptoken.id);
    return res.status(400).json({ message: "OTP expired", success: false });
  }

  if (otptoken.otp !== otp) {
    return res.status(400).json({ message: "Invalid OTP", success: false });
  }

await updateUserEmailById(userid,newEmail);
  await deleteotpbyid(otptoken.id);
  console.log(newEmail)

  return res.status(200).json({ message: "Email updated successfully", success: true, email: newEmail});
};