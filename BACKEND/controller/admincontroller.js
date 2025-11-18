import User from "../../DATABASE/models/user.js";
import Question from "../../DATABASE/models/question.js";
import Answer from "../../DATABASE/models/answer.js";
import Comment from "../../DATABASE/models/comment.js";
import { Report } from "../../DATABASE/models/report.js";

// get all users
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({}, "-Password").sort({ createdAt: -1 });
    res.status(200).json(users);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// get reports
export const getAllReports = async (req, res) => {
  try {
    // Fetch all reports with reporter and target details
    const reports = await Report.find()
      .populate('reportedBy', 'Username Email')
      .lean();

    // Fetch detailed target info for each report
    const detailedReports = await Promise.all(
      reports.map(async (report) => {
        let details = null;
        if (report.targetType === 'question') {
          details = await Question.findById(report.targetId)
            .populate('userId', 'Username Email')
            .lean();
        } else if (report.targetType === 'answer') {
          details = await Answer.findById(report.targetId)
            .populate('userId', 'Username Email')
            .lean();
        } else if (report.targetType === 'comment') {
          details = await Comment.findById(report.targetId)
            .populate('userId', 'Username Email')
            .lean();
        }
        return { ...report, details };
      })
    );

    res.status(200).json(detailedReports);
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

//get all questions
export const getUserQuestions = async (req, res) => {
  try {
    const { userid } = req.params;
    const user = await User.findById(userid, "-Password");
    if (!user) return res.status(404).json({ message: "User not found" });

    const questions = await Question.find({ userId: userid })
      .sort({ createdAt: -1 })
      .lean();
    res.status(200).json(questions);
  } catch (error) {
    console.error("Error fetching user questions:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// get all answers
export const getUserAnswers = async (req, res) => {
  try {
    const { userid } = req.params;
    const user = await User.findById(userid, "-Password");
    if (!user) return res.status(404).json({ message: "User not found" });

    const answers = await Answer.find({ userId: userid })
      .populate("questionid", "content")
      .sort({ createdAt: -1 })
      .lean();
    res.status(200).json(answers);
  } catch (error) {
    console.error("Error fetching user answers:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//get all comments
export const getUserComments = async (req, res) => {
  try {
    const { userid } = req.params;
    const user = await User.findById(userid, "-Password");
    if (!user) return res.status(404).json({ message: "User not found" });

    const comments = await Comment.find({ userId: userid })
  .populate({
    path: 'answerId',
    select: 'content questionid',
    populate: { path: 'questionid', select: '_id' }
  })
  .sort({ createdAt: -1 })
  .lean();

    res.status(200).json(comments);
  } catch (error) {
    console.error("Error fetching user comments:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// delete question
export const deleteQuestionByAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Question.findByIdAndDelete(id);
    if (!deleted) return res.status(404).json({ message: "Question not found" });
    res.status(200).json({ message: "Question deleted successfully" });
  } catch (error) {
    console.error("Error deleting question:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// delete answer
export const deleteAnswerByAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Answer.findByIdAndDelete(id);
    if (!deleted) return res.status(404).json({ message: "Answer not found" });
    res.status(200).json({ message: "Answer deleted successfully" });
  } catch (error) {
    console.error("Error deleting answer:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// delete comment
export const deleteCommentByAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Comment.findByIdAndDelete(id);
    if (!deleted) return res.status(404).json({ message: "Comment not found" });
    res.status(200).json({ message: "Comment deleted successfully" });
  } catch (error) {
    console.error("Error deleting comment:", error);
    res.status(500).json({ message: "Server error" });
  }
};
//delete user
export const deleteUserByAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedUser = await User.findByIdAndDelete(id);
    if (!deletedUser) return res.status(404).json({ message: "User not found" });
    await Question.deleteMany({ userId: id });
    await Answer.deleteMany({ userId: id });
    await Comment.deleteMany({ userId: id });

    res.status(200).json({ message: "User and related data deleted successfully" });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({ message: "Server error" });
  }
};
export const getReportById = async (req, res) => {
  try {
    const { id } = req.params;
    const report = await Report.findById(id)
      .populate("reportedBy", "Username Email")
      .lean();
    if (!report) return res.status(404).json({ message: "Report not found" });

    let targetDetails = null;
    if (report.targetType === "question") {
      targetDetails = await Question.findById(report.targetId)
        .populate("userId", "Username Email")
        .lean();
    } else if (report.targetType === "answer") {
      targetDetails = await Answer.findById(report.targetId)
        .populate("userId", "Username Email")
        .lean();
    } else if (report.targetType === "comment") {
  targetDetails = await Comment.findById(report.targetId)
    .populate("userId", "Username Email")
    .populate({
      path: "answerId",
      populate: {
        path: "questionid",
        select: "_id content",
      },
    }) // ✅ Populates comment → answer → question
    .lean();
}


    return res.json({ report, targetDetails });
  } catch (error) {
    console.error("Error fetching report by ID:", error);
    res.status(500).json({ message: "Server error" });
  }
};
export const checkAdminStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("isAdmin Username Email");
    if (!user) {
      return res.status(404).json({ isAdmin: false, message: "User not found" });
    }

    return res.status(200).json({
      isAdmin: user.isAdmin === true,
      username: user.Username,
      email: user.Email,
    });
  } catch (error) {
    console.error("Error checking admin status:", error);
    res.status(500).json({ isAdmin: false, message: "Server error" });
  }
};
