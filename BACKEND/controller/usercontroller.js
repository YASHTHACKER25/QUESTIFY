import {findquestionsbyuserid} from "../../DATABASE/functions/questionservices.js"
import { getanswerbyid} from "../../DATABASE/functions/answerservices.js";
import { finduserbyid ,finduserbyemail,finduserbyusername,updateUserById,clearRefreshToken } from "../../DATABASE/functions/userservice.js";
import {getcommentbyid} from "../../DATABASE/functions/commentservices.js"
import { checkemail} from "../validation/authvalidation.js"
import {generatesotp} from "./otpcontroller.js"
import {subjectscheckandupdate}from "../controller/subjectcontroller.js"

export async function userdetails(req,res)
{
  const user=await finduserbyid(req.user.id);
  res.json({
  profileAvatar:user.profileAvatar,
  Username:user.Username,
  Email:user.Email,
  Faviouratesubjects:user.Faviouratesubjects,
  State:user.State,
  points:user.points,
  level:user.level
  })

}
export async function question(req, res) {
  

  const questions = await findquestionsbyuserid(req.user.id);

  const question = questions.map(q => ({
    questionid: q._id,
    content: q.content,
  }));

  res.json({ questions: question });
}
export async function answer(req, res) {
  

  const answers = await getanswerbyid(req.user.id);
  res.json({ answers: answers });
}
export async function comment(req, res) {
  

  const comment = await getcommentbyid(req.user.id);
  res.json({ comments: comment });
}
export async function logout(req, res) {
  try {
    const userId = req.user.id;   
    await clearRefreshToken(userId);
    return res.status(200).json({ message: "Logged out successfully" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

//EDIT DETAILS:

export async function editdetails(req, res) {
  try {
    const userId = req.user.id;   
    const { Username, Faviouratesubjects, State } = req.body;
    const user = await finduserbyid(userId);
    var change=0;

    // --- Username validation ---
    if (Username && Username !== user.Username) {
      if (Username.length < 3) {
        return res.status(400).json({ message: "Username must be at least 3 characters" });
      }
      const usernamecheck = await finduserbyusername(Username);
      if (usernamecheck) {
        return res.status(400).json({ message: "Username is not available" });
      }
      change=change+1;
    }

    // --- Faviouratesubjects validation ---
    if (Faviouratesubjects && Faviouratesubjects !== user.Faviouratesubjects) {
      if (!Array.isArray(Faviouratesubjects) || Faviouratesubjects.length < 1) {
        return res.status(400).json({ message: "Select at least one favourite subject" });
      }
      change=change+1;
    }

    // --- State validation ---
    if (State && State !== user.State) {
      if (!State.trim()) {
        return res.status(400).json({ message: "Please select a state" });
      }
      change=change+1;
    }
    if(change>0)
    {
    // --- Update other fields immediately ---
    const updateData = { Username, Faviouratesubjects, State };
    const updatedUser = await updateUserById(userId, updateData);
    await subjectscheckandupdate(Faviouratesubjects);
    return res.status(200).json({ message: "Details updated successfully", user: updatedUser });
    }
    else
    {
      return res.status(400).json({ message: "No new details enter " });
    }

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updateemail(req,res)
{
  try {
    const userId = req.user.id;   
    const { Email } = req.body;
    const user = await finduserbyid(userId);

    if (Email && Email !== user.Email) {
      if (!checkemail(Email)) {
        return res.status(400).json({ message: "Email is not valid" });
      }
      const existinguser = await finduserbyemail(Email);
      if (existinguser) {
        return res.status(400).json({ message: "User already registered" });
      }
      // Generate OTP
      await generatesotp(userId, Email);

      return res.status(200).json({ message: "OTP sent to new email. Please verify." ,
            userid: userId,
            newEmail:Email
      });
    }

    return res.status(400).json({ message: "No new email provided" });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
}