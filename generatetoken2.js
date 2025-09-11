import dotenv from "dotenv"
dotenv.config()
import jwt from "jsonwebtoken"
export function generateToken(userid){
    return jwt.sign({id:userid},process.env.ACSESS_TOKEN,{expiresIn:"1h"})
}
export function generateRefreshToken(userid){
    return jwt.sign({id:userid},process.env.REFRESH_TOKEN,{expiresIn:"7d"})
}
