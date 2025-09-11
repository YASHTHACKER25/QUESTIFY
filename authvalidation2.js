function checkemail(email){
    const re=/^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email)
}
function ValidateLogin(data){
    const {email,password}=data;
    if(!email || checkemail(email)){
         return { valid: false, message: "Email is not  valid" };
    }
    if(!password || password.trim() === ""){
        return {valid:false,message:"Password is required"}
    }
    return {valid:true}

}
