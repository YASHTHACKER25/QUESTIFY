import { findSubjectByName,createSubject ,getAllSubjects} from "../../DATABASE/functions/subjectservices.js";
export async function  subjectscheckandupdate(Faviouratesubjects) {
    for (let i = 0; i < Faviouratesubjects.length; i++) {
        const s=await findSubjectByName(Faviouratesubjects[i]);
            if(!s)
            {
              await createSubject(Faviouratesubjects[i]);
            }
    }
}
export async function getSubjects(req, res) {
    const subjects = await getAllSubjects();
    res.json({ subjects }); 
}

