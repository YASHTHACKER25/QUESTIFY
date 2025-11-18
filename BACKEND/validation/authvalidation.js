//regex functions :
export function checkemail(email){
    const re=/^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email)
}
export function checkpassword(password)
{
    const re=/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$/;
    return re.test(password)
}
// validating loging details 
export function ValidateLogin(data){
    const {Email,Password}=data;
    if(!Email || !checkemail(Email)){
         return { valid: false, message: "Email is not  valid" };
    }
    if(!Password || Password.trim() === ""){
        return {valid:false,message:"Password is required"}
    }
    return {valid:true}

}
//validating registors details

export function ValidateRegister(data){
    const {Username,Email,Password,Faviouratesubjects,State}=data;
    if(!Username || Username.length<3)
    {
        return {valid:false,message:"Username must be atleast 3 characters"}
    }
    if(!Email || !checkemail(Email)){
        return {valid:false,message:"Email is not valid"}
    }
    if(!Password || !checkpassword(Password)){
        return {valid:false,message:"Password must be at least 8 characters, include uppercase, lowercase, number, and special character"}
    }
    if(!Array.isArray(Faviouratesubjects) || Faviouratesubjects.length < 1) {
    return { valid: false, message: "Select at least one favourite subject" };
  }

    if(!State||State.trim()==""){
        return {valid:false,message:"please select state"}
    }
    return { valid: true };
}
