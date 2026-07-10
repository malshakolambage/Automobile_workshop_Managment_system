const express = require("express");
const pool = require("../config/db");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth);

// GET /api/feedback -> admin sees all, customer sees their own
router.get("/", async (req, res) => {
  try {
    let rows;
    if (req.user.role === "admin") {
      [rows] = await pool.query(
        `SELECT f.*, u.name AS customer_name FROM feedback f
         JOIN users u ON u.id = f.user_id
         ORDER BY f.created_at DESC`
      );
    } else {
      [rows] = await pool.query(
        "SELECT * FROM feedback WHERE user_id = ? ORDER BY created_at DESC",
        [req.user.id]
      );
    }
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch feedback" });
  }
});

// POST /api/feedback -> feedback_page.dart submit
router.post("/", async (req, res) => {
  try {
    const { vehicle_id, appointment_id, rating, comment } = req.body;
    if (!rating) return res.status(400).json({ error: "Rating is required" });

    const [result] = await pool.query(
      "INSERT INTO feedback (user_id, vehicle_id, appointment_id, rating, comment) VALUES (?, ?, ?, ?, ?)",
      [req.user.id, vehicle_id || null, appointment_id || null, rating, comment || null]
    );
    res.status(201).json({ id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to submit feedback" });
  }
});

module.exports = router;
