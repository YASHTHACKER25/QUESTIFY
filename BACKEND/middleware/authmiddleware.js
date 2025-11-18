import jwt from "jsonwebtoken";

export function authmiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader) {
    return res.status(401).json({ error: "LOGIN REQUIRED" ,message:"LOGIN REQUIRED"});
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.ACSESS_TOKEN);
    req.user = { id: decoded.id };
    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token",message: "Invalid or expired token" });
  }
}
