import jwt from "jsonwebtoken";

export function passwordresettoken(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Reset token missing" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.ACSESS_TOKEN);
    req.user = { id: decoded.id }; // attach user ID to request
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired reset token" });
  }
}
