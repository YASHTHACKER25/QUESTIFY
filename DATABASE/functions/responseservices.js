import Response from "../models/response.js";
import mongoose from "mongoose";
export async function checkUserResponseType(answerId, userId) {
  if (!mongoose.Types.ObjectId.isValid(answerId) || !mongoose.Types.ObjectId.isValid(userId)) {
    throw new Error("Invalid answerId or userId");
  }

  const response = await Response.findOne({ answerId, userId }).lean();

  return response ? response.type : null;
}

export async function deleteUserResponse(answerId, userId){
  const result = await Response.deleteOne({ answerId, userId });
  return result.deletedCount > 0;
};
export async function addResponse(answerId, userId, type){
  const response = new Response({ answerId, userId, type });
  await response.save();  // explicitly save to DB
  return response;
}
export async function countResponses(answerId){
  const counts = await Response.aggregate([
    { $match: { answerId: new mongoose.Types.ObjectId(answerId) } }, // convert string to ObjectId
    { $group: { _id: "$type", count: { $sum: 1 } } }
  ]);

  const result = { helpful: 0, nothelpful: 0 };
  counts.forEach(c => {
    if(c._id) result[c._id] = c.count;
  });
  return result;
}