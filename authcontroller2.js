import express from "express"
import {finduserbyemail} from "../database/authdatabase"
import {generateToken,generateRefreshToken} from "../utils.js/generatetoken2"
import { validateRegister, validateLogin } from "../validation/authvalidation2"
import bcrypt from "bcryptjs";

//login code :
export async function login(req,res){
    const validlogin=ValidateLogin(req.body);
    if(!validlogin.valid){
        return res.status(400).json({message:valid.message})
    }
    const {email,password}=req.body
    const users=finduserbyemail(email);
    if(!users){
        return res.status(400).json({message:"USER NOT FOUND BY THIS EMAIL"});
    }
    const passcheck=await bcrypt.compare(password,users.password);
    if(!passcheck){
        return res.status(400).json({message:"INVALID PASSWORD"})
    }
  const accessToken = generateToken(users.id);
  const refreshToken = generateRefreshToken(users.id); 
  users.refreshToken = refreshToken;
  await users.save();
  res.json({
    message: "Login successful",
    accessToken,
    refreshToken
  });

}
