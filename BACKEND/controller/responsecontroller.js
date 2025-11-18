// controller/responsecontroller.js
import Answer from "../../DATABASE/models/answer.js";
import {
  checkUserResponseType,
  deleteUserResponse,
  addResponse,
  countResponses
} from "../../DATABASE/functions/responseservices.js";
import { finduserbyid, updateuserlevelandpoint } from "../../DATABASE/functions/userservice.js";
import { calculateLevel } from "../controller/levelcontroller.js";

// ✅ make sure 'export' is in front of this function
export async function response(req, res) {
  const { answerid, response: userResponse } = req.body;
  const userid = req.user.id;

  const existingType = await checkUserResponseType(answerid, userid);

  if (existingType === userResponse) {
    await deleteUserResponse(answerid, userid);
  } else if (existingType && existingType !== userResponse) {
    await deleteUserResponse(answerid, userid);
    await addResponse(answerid, userid, userResponse);
  } else {
    await addResponse(answerid, userid, userResponse);
  }

  const counts = await countResponses(answerid);

  if (userResponse === "helpful") {
    const helpfulCount = counts.helpful;
    const answer = await Answer.findById(answerid);

    if (answer) {
      const currentMilestone = Math.floor(helpfulCount / 10) * 10;

      if (currentMilestone > (answer.lastHelpfulPointCount || 0)) {
        const user = await finduserbyid(answer.userId);
        if (user) {
          const newPoints = user.points + 10;
          const newLevel = await calculateLevel(newPoints);
          await updateuserlevelandpoint(user._id, newPoints, newLevel);
          answer.lastHelpfulPointCount = currentMilestone;
          await answer.save();
        }
      }
    }
  }

  return res.json(counts);
}

// ✅ and keep your new function as well
export async function getResponsesForQuestion(req, res) {
  try {
    const { questionId } = req.params;
    const userId = req.user.id;

    const answers = await Answer.find({ questionId });

    const responses = [];
    for (const a of answers) {
      const counts = await countResponses(a._id);
      const userResponse = await checkUserResponseType(a._id, userId);

      responses.push({
        answerId: a._id,
        helpfulCount: counts.helpful || 0,
        notHelpfulCount: counts.nothelpful || 0,
        userResponse: userResponse || null,
      });
    }

    return res.json({ responses });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}
