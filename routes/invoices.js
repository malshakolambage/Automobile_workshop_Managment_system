const express = require("express");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth);

// GET /api/invoices -> admin: all invoices, customer: their own
router.get("/", async (req, res) => {
  try {
    let rows;
    if (req.user.role === "admin") {
      [rows] = await pool.query("SELECT * FROM invoices ORDER BY created_at DESC");
    } else {
      [rows] = await pool.query(
        "SELECT * FROM invoices WHERE user_id = ? ORDER BY created_at DESC",
        [req.user.id]
      );
    }
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch invoices" });
  }
});

// POST /api/invoices -> admin creates an invoice (billing.html)
router.post("/", requireAdmin, async (req, res) => {
  try {
    const { user_id, appointment_id, customer_name, vehicle_no, items } = req.body;
    if (!customer_name || !vehicle_no || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: "customer_name, vehicle_no and items[] are required" });
    }

    const total = items.reduce((sum, i) => sum + Number(i.amount || 0), 0);

    const [result] = await pool.query(
      `INSERT INTO invoices (user_id, appointment_id, customer_name, vehicle_no, items, total)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [user_id || null, appointment_id || null, customer_name, vehicle_no, JSON.stringify(items), total]
    );

    res.status(201).json({ id: result.insertId, total });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create invoice" });
  }
});

module.exports = router;
