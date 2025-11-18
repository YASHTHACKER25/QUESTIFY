import User from "../models/user.js";

//  find user by email
export async function finduserbyemail(email) {
  return await User.findOne({ Email: email });
}
// find user by username 
export async function finduserbyusername(username) {
  return await User.findOne({ Username: username });
}


//  create new user
export async function createuser(userData) {
  const user = new User(userData);
  return await user.save();
}

//  find user by id
export async function finduserbyid(id) {
  return await User.findById(id);
}

// Get a user’s favorite subjects only
export async function getUserFavoriteSubjects(userId) {
  return User.findById(userId).select("Faviouratesubjects").lean();
}


// update refresh token
export async function updateRefreshToken(userId, token) {
  return await User.findByIdAndUpdate(
    userId,
    { refreshToken: token },
    { new: true }
  );
}
const a=getUserFavoriteSubjects();
console.log(a);

//deleteuserbyid
export async function deleteuserbyid(id) {
  return await User.findByIdAndDelete(id);
}
// Update the isVerified status of a user by ID
export async function updateUserIsVerified(userId, isVerified) {
  return await User.findByIdAndUpdate(
    userId,
    { isVerified },               // set the field to the provided value
    { new: true }                  // return the updated document
  );
}

export async function updateuserlevelandpoint(userid,points,level) {
  return await User.findByIdAndUpdate(
    userid,
    { points, level}, // update both fields
    { new: true }                             // return updated doc
  );
  
}

export async function updateUserPassword(userId, newPassword) {
  return await User.findByIdAndUpdate(
    userId,
    { Password: newPassword },
    { new: true }
  );
}

export async function deletetokrnsbyuserid(userid){
  return await User.findByIdAndUpdate(userid, { $set: { refreshToken: null } });
}
export async function getrefreshtokenbyid(userid)
{
  return User.findById(userid).select("refreshToken").lean();
}
export async function clearRefreshToken(userId) {
  return await User.findByIdAndUpdate(
    userId,
    { $set: { refreshToken: null } },
    { new: true }
  );
}

// Update user details by ID
export async function updateUserById(userId, updateData) {
  // Only allow specific fields to be updated
  const allowedUpdates = ["Username", "Faviouratesubjects", "State"];
  const filteredUpdates = {};

  for (let key of allowedUpdates) {
    if (updateData[key] !== undefined) {
      filteredUpdates[key] = updateData[key];
    }
  }

  if (Object.keys(filteredUpdates).length === 0) {
    throw new Error("No valid fields provided for update.");
  }

  return await User.findByIdAndUpdate(
    userId,
    { $set: filteredUpdates },
    { new: true } // return the updated document
  );
}

// Update user email by ID
export async function updateUserEmailById(userId, newEmail) {
  if (!newEmail) {
    throw new Error("New email must be provided.");
  }

  return await User.findByIdAndUpdate(
    userId,
    { $set: { Email: newEmail } },
    { new: true } // return the updated document
  );
}

//update image
export async function updateUserProfileAvatar(userId, avatarUrl) {
  return await User.findByIdAndUpdate(
    userId,
    { profileAvatar: avatarUrl },
    { new: true }
  );
}

