// perspectiveConnect.js
import axios from "axios";

const API_KEY = process.env.GOOGLE_API_KEY2;

export const URL = `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${API_KEY}`;

export const axiosInstance = axios.create({
  timeout: 10000, // 10 seconds
  headers: {
    "Content-Type": "application/json"
  }
});
