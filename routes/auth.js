const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

const router = express.Router();

function signToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
  );
}


router.post("/register", async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !password || !email || !phone) {
      return res.status(400).json({ error: "Name, email, mobile number and password are required" });
    }

    const [existingEmail] = await pool.query(
      "SELECT id FROM users WHERE email = ?",
      [email]
    );
    if (existingEmail.length > 0) {
      return res.status(409).json({ error: "An account with this email already exists" });
    }

    const [existingPhone] = await pool.query(
      "SELECT id FROM users WHERE phone = ?",
      [phone]
    );
    if (existingPhone.length > 0) {
      return res.status(409).json({ error: "An account with this mobile number already exists" });
    }

    const password_hash = await bcrypt.hash(password, 10);

    const [result] = await pool.query(
      "INSERT INTO users (name, email, phone, password_hash, role) VALUES (?, ?, ?, ?, 'customer')",
      [name, email, phone, password_hash]
    );

    const user = { id: result.insertId, role: "customer" };
    const token = signToken(user);

    res.status(201).json({
      token,
      user: { id: user.id, name, email, phone, role: "customer" },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Registration failed" });
  }
});

// ---------------------------------------------------------
// POST /api/auth/login   (used by BOTH the Flutter app and the admin panel)
// body: { email, password }
// ---------------------------------------------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const [rows] = await pool.query("SELECT * FROM users WHERE email = ?", [email]);
    if (rows.length === 0) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const token = signToken(user);
    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile_image: user.profile_image,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Login failed" });
  }
});


router.post("/register-admin", async (req, res) => {
  try {
    const { name, email, phone, password, profile_image, workshop_name } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: "Name, email and password are required" });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: "Password must be at least 6 characters" });
    }

    const [existing] = await pool.query("SELECT id FROM users WHERE email = ?", [email]);
    if (existing.length > 0) {
      return res.status(409).json({ error: "An account with this email already exists" });
    }

    const password_hash = await bcrypt.hash(password, 10);

    const [result] = await pool.query(
      "INSERT INTO users (name, email, phone, password_hash, role, profile_image) VALUES (?, ?, ?, ?, 'admin', ?)",
      [name, email, phone || null, password_hash, profile_image || null]
    );

    const workshopSets = [];
    const workshopParams = [];
    if (workshop_name && workshop_name.trim()) {
      workshopSets.push("name = ?");
      workshopParams.push(workshop_name.trim());
    }
    if (phone) {
      workshopSets.push("phone = ?");
      workshopParams.push(phone);
    }
    if (email) {
      workshopSets.push("email = ?");
      workshopParams.push(email);
    }
    if (workshopSets.length > 0) {
      workshopParams.push(1);
      await pool.query(`UPDATE workshop_profile SET ${workshopSets.join(", ")} WHERE id = ?`, workshopParams);
    }

    const user = { id: result.insertId, role: "admin" };
    const token = signToken(user);

    res.status(201).json({
      token,
      user: { id: user.id, name, email, phone: phone || null, role: "admin", profile_image: profile_image || null },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Registration failed" });
  }
});

module.exports = router;