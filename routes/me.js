const express = require("express");
const pool = require("../config/db");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

// All routes here are for the LOGGED-IN user acting on their own account
// (no admin role required — that's what makes this different from /api/customers)
router.use(requireAuth);

// GET /api/me -> the logged-in user's own profile
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, name, email, phone, role, profile_image FROM users WHERE id = ?",
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch profile" });
  }
});

// PUT /api/me -> update the logged-in user's own name / email / phone / photo
// body: { name, email, phone, profile_image }
router.put("/", async (req, res) => {
  try {
    const { name, email, phone, profile_image } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({ error: "Name is required" });
    }
    if (!email || !email.trim()) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Make sure another account isn't already using this email
    const [existing] = await pool.query(
      "SELECT id FROM users WHERE email = ? AND id != ?",
      [email.trim(), req.user.id]
    );
    if (existing.length > 0) {
      return res.status(409).json({ error: "This email is already in use" });
    }

    if (profile_image !== undefined) {
      await pool.query(
        "UPDATE users SET name = ?, email = ?, phone = ?, profile_image = ? WHERE id = ?",
        [name.trim(), email.trim(), phone ? phone.trim() : null, profile_image, req.user.id]
      );
    } else {
      await pool.query(
        "UPDATE users SET name = ?, email = ?, phone = ? WHERE id = ?",
        [name.trim(), email.trim(), phone ? phone.trim() : null, req.user.id]
      );
    }

    const [rows] = await pool.query(
      "SELECT id, name, email, phone, role, profile_image FROM users WHERE id = ?",
      [req.user.id]
    );

    res.json({ message: "Profile updated", user: rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update profile" });
  }
});

module.exports = router;