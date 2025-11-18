import Subject from "../models/subject.js";

// Get all subjects
export async function getAllSubjects() {
  return await Subject.find().sort({ name: 1 });
}

// Find subject by name
export async function findSubjectByName(name) {
  return await Subject.findOne({ name });
}

// Create a new subject if it doesn't exist
export async function createSubject(name) {
  const subject = new Subject({ name });
  return await subject.save();
}
