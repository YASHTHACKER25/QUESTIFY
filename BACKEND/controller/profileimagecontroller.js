import cloudinary from "../config/cloudinary.js";
import { updateUserProfileAvatar } from "../../DATABASE/functions/userservice.js";

export const updateProfileImage = async (req, res) => {
  try {
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "profile_avatars",
    });

    const updatedUser = await updateUserProfileAvatar(req.user.id, result.secure_url);

    res.json({
      success: true,
      avatarUrl: result.secure_url,
      message: "Profile photo updated!",
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Image upload failed." });
  }
};
