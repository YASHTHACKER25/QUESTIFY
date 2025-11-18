import jwt from "jsonwebtoken";
import { finduserbyid } from "../../DATABASE/functions/userservice.js";

export async function adminmiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader) {
    return res.status(401).json({ error: "LOGIN REQUIRED", message: "LOGIN REQUIRED" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.ACSESS_TOKEN);
    req.user = { id: decoded.id };
    const user = await finduserbyid(req.user.id);

    if (!user || !user.isAdmin) {
      return res.status(403).json({ error: "Access denied: Admins only" });
    }

    next();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
}
