import { Report } from "../models/report.js";

export async function createReport(data) {
  const report = new Report(data);
  return await report.save();
}

export async function getAllReports() {
  return await Report.find().populate("reportedBy", "username email");
}

export async function updateReportStatus(id, status) {
  return await Report.findByIdAndUpdate(id, { status }, { new: true });
}
