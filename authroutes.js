import express from "express"
import {login} from "../contoller/authcontroller2.js"
const router=express.Router();

router.post("/login",login);

export default router