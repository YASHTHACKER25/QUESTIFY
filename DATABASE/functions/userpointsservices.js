import User from "../models/user.js";
import Level from "../models/level.js"; // this is your fixed levels schema

export async function addpointsAndUpdateLevel(userId, addedPoints) {
  // 1. Increase points
  const user = await User.findById(userId);
  if (!user) return;

  user.Points += addedPoints;

  // 2. Find level name based on total points
  // assuming Level collection has documents like { name:"Beginner", minPoints:0, maxPoints:49 }
  const newLevel = await Level.findOne({
    minPoints: { $lte: user.Points },
    maxPoints: { $gte: user.Points }
  });

  if (newLevel && user.Level !== newLevel.name) {
    user.Level = newLevel.name;
  }

  await user.save();
}
