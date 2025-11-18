import {finduserbyemail,finduserbyusername,createuser} from "../../DATABASE/functions/userservice.js"
import { ValidateRegister,ValidateLogin } from "../validation/authvalidation.js"
import {generateotp} from "./otpcontroller.js"
import {subjectscheckandupdate}from "../controller/subjectcontroller.js"
import bcrypt from "bcryptjs";
//register code:
export async function register(req,res){
    try{
    const validregister=ValidateRegister(req.body);
    if(!validregister.valid){
        return res.status(404).json({message:validregister.message})
    }
    const {Username,Email,Password,Faviouratesubjects,State}=req.body;
    const existinguser=await finduserbyemail(Email);
    if(existinguser){
        return res.status(400).json({message:"user already registered"});
    }
    const usernamecheck=await finduserbyusername(Username)
     if(usernamecheck)
    {
        return res.status(400).json({message:"user name does not avalible"});
    }
    const hashpassword=await bcrypt.hash(Password,10);

    const newUser=await createuser({
        Username,
        Email,
        Password:hashpassword,
        Faviouratesubjects,
        State
     })
     await subjectscheckandupdate(Faviouratesubjects);
     await generateotp(newUser.id);
     res.json({
    message: "OTP sent to your email.",
    userid: newUser.id,
    email: newUser.Email
  });
}
catch(err){
    console.log(err);
}
}

//login code :
export async function login(req,res){
    const validlogin=ValidateLogin(req.body);
    if(!validlogin.valid){
        return res.status(404).json({message:validlogin.message})
    }
    const {Email,Password}=req.body
    const users=await finduserbyemail(Email);
    if(!users){
        return res.status(404).json({message:"USER NOT FOUND BY THIS EMAIL"});
    }
    const passcheck=await bcrypt.compare(Password,users.Password);//(HAMNANOPASSWORDNAME,SCHEMA NA ANDER HOY E PASSWORD NAME )
    if(!passcheck){
        return res.status(404).json({message:"INVALID PASSWORD"})
    }
   await generateotp(users.id);

   return res.status(200).json({
    message: "OTP sent to your email. Please verify to complete login.",
    userid: users.id,
    email: users.Email,
  });

}
