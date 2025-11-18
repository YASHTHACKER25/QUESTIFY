import multer from "multer";
const upload = multer({ dest: "uploads/" }); // Temporary local storage
export default upload;
