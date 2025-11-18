import { createReport, getAllReports, updateReportStatus } from "../../DATABASE/functions/reportservice.js";

export async function addReport(req, res) {
  try {
    const { targetType, targetId, reason } = req.body;
    const userId = req.user.id;

    const report = await createReport({ reportedBy: userId, targetType, targetId, reason });
    res.status(201).json({ message: "Report submitted successfully", report });
  } catch (err) {
    res.status(500).json({ error: "Failed to submit report" });
  }
}

export async function viewReports(req, res) {
  try {
    const reports = await getAllReports();
    res.json(reports);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch reports" });
  }
}

export async function changeReportStatus(req, res) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const updated = await updateReportStatus(id, status);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: "Failed to update report status" });
  }
}
