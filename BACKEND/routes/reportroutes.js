import express from "express";
import { addReport, viewReports, changeReportStatus } from "../controller/reportcontroller.js";
import { authmiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.post("/", authmiddleware, addReport);
router.get("/", authmiddleware, viewReports);
router.put("/:id", authmiddleware, changeReportStatus);

export default router;
