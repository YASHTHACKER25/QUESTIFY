import dotenv from "dotenv";
dotenv.config();
import express from "express";
import http from "http";
import { Server } from "socket.io";
import cors from "cors";

import router from "./routes/authroutes.js";
import { dbconnect } from "./config/dbconnect.js";
import questionrouter from "./routes/questionroutes.js";
import answerrouter from "./routes/answerroutes.js";
import { refreshtokenuse } from "./utils/refreshtokenuse.js";
import homepagerouter from "./routes/homepageroutes.js";
import userrouter from "./routes/userroutes.js";
import passwordrouter from "./routes/passwordroutes.js";
import subjectrouter from "./routes/subjectroutes.js";
import responseRoutes from "./routes/responseroutes.js";
import commentrouter from "./routes/commentroutes.js";
import notificationRoutes from "./routes/notificationroutes.js";
import reportroutes from "./routes/reportroutes.js";
import adminroutes from "./routes/adminroutes.js";


const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

import mongoose from "mongoose";
import Question from "../DATABASE/models/question.js";

dbconnect(process.env.DB_URL).then(() => {
  mongoose.model("Question", mongoose.model("question").schema);
  console.log(" Registered alias: 'Question' → 'question'");
}); 


const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // later replace with Flutter app URL
    methods: ["GET", "POST"],
  },
});

// ✅ Active users store
const activeUsers = new Map();

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("register", (userId) => {
    activeUsers.set(userId, socket.id);
    console.log(` Registered user: ${userId}`);
  });

  socket.on("join_question_room", (questionId) => {
    socket.join(questionId);
    console.log(` User joined room for question: ${questionId}`);
  });

  socket.on("disconnect", () => {
    for (const [userId, socketId] of activeUsers.entries()) {
      if (socketId === socket.id) {
        activeUsers.delete(userId);
        break;
      }
    }
    console.log(" User disconnected:", socket.id);
  });
});

// ✅ Export io & users
export { io, activeUsers };

// ✅ Routes
app.get("/", (req, res) => {
  res.send("Server is workinwg ");
});

app.use("/api", router);
app.use("/api/question", questionrouter);
app.use("/api/answer", answerrouter);
app.use("/api/refresh", refreshtokenuse);
app.use("/api/homepage", homepagerouter);
app.use("/api/user", userrouter);
app.use("/api/password", passwordrouter);
app.use("/api/subjects", subjectrouter);
app.use("/api/response", responseRoutes);
app.use("/api/comment", commentrouter);
app.use("/api/notifications", notificationRoutes);
app.use("/api/report", reportroutes);
app.use("/api/admin", adminroutes);

// Start server
const PORT = process.env.PORT || 8000;
server.listen(PORT,'0.0.0.0', (err) => {
  if (err) console.log("Error:", err);
  else console.log(` Server started at port: ${PORT}`);
});

