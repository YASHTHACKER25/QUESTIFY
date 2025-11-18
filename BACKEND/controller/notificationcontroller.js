    // BACKEND/controllers/notificationcontroller.js
    import { getNotificationsByUser, markNotificationAsRead } from "../../DATABASE/functions/notificationservices.js";

    /**
     * 📬 Get all notifications for the logged-in user
     */
    export const getUserNotifications = async (req, res) => {
    try {
        const userId = req.user.id;
        const notifications = await getNotificationsByUser(userId);

        res.status(200).json({
        message: "Notifications fetched successfully",
        notifications,
        });
    } catch (error) {
        console.error("❌ Error fetching notifications:", error);
        res.status(500).json({ message: "Server error" });
    }
    };

    /**
     * ✅ Mark notification as read
     */
    export const markAsRead = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await markNotificationAsRead(id);

        if (!notification) {
        return res.status(404).json({ message: "Notification not found" });
        }

        res.status(200).json({ message: "Notification marked as read", notification });
    } catch (error) {
        console.error("❌ Error marking as read:", error);
        res.status(500).json({ message: "Server error" });
    }
    };
