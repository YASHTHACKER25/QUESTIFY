import dotenv from "dotenv"
dotenv.config();
import express from "express"
import router from "./routes/authroutes.js"
import mongoose from "mongoose"

const app=express();
app.use("/api",router);

app.listen(process.env.PORT);
