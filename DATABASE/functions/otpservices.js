import OTP from "../models/otp.js";

export async function findotpbyuserid(userid) {
  return await OTP.findOne({ userid: userid });
}
export async function createotp(otpData) {
  const otp = new OTP(otpData);
  return await otp.save();
}
export async function deleteotpbyuserid(userId) {
  return await OTP.deleteMany({ userid: userId });
}
export async function deleteotpbyid(id) {
  return await OTP.findByIdAndDelete(id);
}