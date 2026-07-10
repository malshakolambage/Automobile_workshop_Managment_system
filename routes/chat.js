const express = require("express");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth);

// GET /api/chat/:userId -> full conversation with one customer
// Customers can only fetch their own; admin can fetch anyone's by passing their id.
router.get("/:userId", async (req, res) => {
  try {
    const targetId = req.user.role === "admin" ? req.params.userId : req.user.id;
    if (req.user.role !== "admin" && String(req.user.id) !== String(req.params.userId)) {
      return res.status(403).json({ error: "Not allowed" });
    }
    const [rows] = await pool.query(
      "SELECT * FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC",
      [targetId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch messages" });
  }
});

// POST /api/chat/:userId -> send a message (chat_workshop_page.dart / future admin chat UI)
router.post("/:userId", async (req, res) => {
  try {
    const { message } = req.body;
    if (!message?.trim()) return res.status(400).json({ error: "Message required" });

    const targetId = req.user.role === "admin" ? req.params.userId : req.user.id;
    const sender = req.user.role === "admin" ? "workshop" : "customer";

    const [result] = await pool.query(
      "INSERT INTO chat_messages (user_id, sender, message) VALUES (?, ?, ?)",
      [targetId, sender, message.trim()]
    );

    if (sender === "workshop") {
      await pool.query(
        "INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'New Message', 'The workshop sent you a message.', 'info')",
        [targetId]
      );
    }

    res.status(201).json({ id: result.insertId, sender, message: message.trim() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to send message" });
  }
});

module.exports = router;
