import express from "express";
import { getSubjects } from "../controller/subjectcontroller.js";

const router = express.Router();

router.get("/", getSubjects);

export default router;
