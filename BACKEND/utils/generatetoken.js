import dotenv from "dotenv"
dotenv.config()
import jwt from "jsonwebtoken"
export function generateToken(userid,isAdmin){
    return jwt.sign({id:userid,isAdmin: isAdmin},process.env.ACSESS_TOKEN,{expiresIn:"2m"})
}
export function generateRefreshToken(userid){
    return jwt.sign({id:userid},process.env.REFRESH_TOKEN,{expiresIn:"7d"})
}
