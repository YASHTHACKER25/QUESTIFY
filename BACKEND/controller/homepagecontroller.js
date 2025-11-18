import { getUserFavoriteSubjects } from "../../DATABASE/functions/userservice.js";
import { getQuestionsBySubjects, getRecentQuestions } from "../../DATABASE/functions/questionservices.js";

export async function homepage(req, res) {
  try {
    const userId = req.user?.id;
    const fav = await getUserFavoriteSubjects(userId);
    const favSubjectsArray = fav?.Faviouratesubjects || [];


    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

  
    const [favQuestions, recentQuestions] = await Promise.all([
      favSubjectsArray.length ? getQuestionsBySubjects(favSubjectsArray) : [],
      getRecentQuestions(),
    ]);

  
    const favIds = new Set(favQuestions.map(q => q._id.toString()));
    const nonFavRecent = recentQuestions.filter(q => !favIds.has(q._id.toString()));

    
    favQuestions.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    nonFavRecent.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    const combined = [...favQuestions, ...nonFavRecent];

    
    const paginated = combined.slice(skip, skip + limit);

    
    const result = paginated.map(q => ({
      questionid: q._id,
      content: q.content,
      createdByUsername: q.userId?.Username,
    }));

    res.json({
      questions: result,
      total: combined.length,
      page,
      limit,
      totalPages: Math.ceil(combined.length / limit),
    });
  } catch (err) {
    console.error("Homepage error:", err);
    res.status(500).json({ error: "Server error" });
  }
}
