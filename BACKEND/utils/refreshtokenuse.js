import jwt from "jsonwebtoken";
import { generateToken, generateRefreshToken } from "./generatetoken.js";

export async function refreshtokenuse(req, res) {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ message: "No refresh token provided" });
  }

  try {
    // Verify the refresh token
    const payload = jwt.verify(refreshToken, process.env.REFRESH_TOKEN);

    // Generate a new access token
    const newAccessToken = generateToken(payload.id);

    // Optionally, generate a new refresh token (rotate)
    const newRefreshToken = generateRefreshToken(payload.id);

    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    });
  } catch (err) {
    res.status(401).json({ message: "Invalid or expired refresh token" });
  }
}
