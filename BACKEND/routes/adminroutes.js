  import express from "express";
  import {
    getAllUsers,
    getAllReports,
    getUserQuestions,
    getUserAnswers,
    getUserComments,
    deleteQuestionByAdmin,
    deleteAnswerByAdmin,
    deleteCommentByAdmin,
    deleteUserByAdmin,
    getReportById,
    checkAdminStatus,
  } from "../controller/admincontroller.js";
  import { authmiddleware } from "../middleware/authmiddleware.js";
  import { adminmiddleware } from "../middleware/adminmiddleware.js";

  const router = express.Router();

  router.get("/users", authmiddleware, adminmiddleware, getAllUsers);

  router.get("/reports", authmiddleware, adminmiddleware, getAllReports);
  router.get('/report/:id', authmiddleware, adminmiddleware, getReportById);


  router.get("/user/:userid/question", authmiddleware, adminmiddleware, getUserQuestions);
  router.get("/user/:userid/answer", authmiddleware, adminmiddleware, getUserAnswers);
  router.get("/user/:userid/comment", authmiddleware, adminmiddleware, getUserComments);

  router.delete("/question/:id", authmiddleware, adminmiddleware, deleteQuestionByAdmin);
  router.delete("/answer/:id", authmiddleware, adminmiddleware, deleteAnswerByAdmin);
  router.delete("/comment/:id", authmiddleware, adminmiddleware, deleteCommentByAdmin);
  router.delete("/user/:id", authmiddleware, adminmiddleware, deleteUserByAdmin);
  router.get("/isAdmin", authmiddleware, checkAdminStatus);

  export default router;
