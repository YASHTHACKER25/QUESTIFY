import { finduserbyid } from "../../DATABASE/functions/userservice.js";
import { createotp,deleteotpbyuserid } from "../../DATABASE/functions/otpservices.js";
import sendOtp from "../utils/sendotp.js"

export const generateotp = async (userid) => {
  const user = await finduserbyid(userid);
  if (!user) throw new Error("User not found");

  // DELETEUNG OLD OTP
  await deleteotpbyuserid(userid);

  // GENERATING NEW OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresat = new Date(Date.now() + 5 * 60 * 1000);
const newotp=await createotp({userid,otp,expiresat});

  // Send OTP email
  await sendOtp(user.Email, otp);

  return otp;
};
export const generatesotp = async (userid,newEmail) => {
  const user = await finduserbyid(userid);
  if (!user) throw new Error("User not found");

  // DELETEUNG OLD OTP
  await deleteotpbyuserid(userid);

  // GENERATING NEW OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresat = new Date(Date.now() + 5 * 60 * 1000);
const newotp=await createotp({userid,otp,expiresat});

  // Send OTP email
  await sendOtp(newEmail, otp);

  return otp;
};

