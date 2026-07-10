const express = require("express");
const bcrypt = require("bcryptjs");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();

// All customer-management routes are admin-only (used by customers.html)
router.use(requireAuth, requireAdmin);

// GET /api/customers  -> list all customers, with their primary vehicle plate if any
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT u.id, u.name, u.phone, u.email,
              GROUP_CONCAT(v.plate_number SEPARATOR ', ') AS vehicle
       FROM users u
       LEFT JOIN vehicles v ON v.user_id = u.id
       WHERE u.role = 'customer'
       GROUP BY u.id
       ORDER BY u.created_at DESC`
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch customers" });
  }
});

// POST /api/customers  -> add a customer (also creates a vehicle + Pending appointment,
// mirroring the old customers.html localStorage sync behaviour)
router.post("/", async (req, res) => {
  const conn = await pool.getConnection();
  try {
    const { name, mobile, email, vehicle } = req.body;
    if (!name || !mobile || !vehicle) {
      return res.status(400).json({ error: "Name, mobile and vehicle are required" });
    }

    await conn.beginTransaction();

    // Create a placeholder login for the customer (default password = mobile number)
    const password_hash = await bcrypt.hash(mobile, 10);
    const [userResult] = await conn.query(
      "INSERT INTO users (name, email, phone, password_hash, role) VALUES (?, ?, ?, ?, 'customer')",
      [name, email || null, mobile, password_hash]
    );
    const userId = userResult.insertId;

    const [vehicleResult] = await conn.query(
      "INSERT INTO vehicles (user_id, model, plate_number, status) VALUES (?, 'Unknown', ?, 'Queued')",
      [userId, vehicle]
    );

    await conn.query(
      `INSERT INTO appointments (user_id, vehicle_id, service_type, appointment_date, status, progress)
       VALUES (?, ?, 'General', CURDATE(), 'Pending', 'Awaiting Approval')`,
      [userId, vehicleResult.insertId]
    );

    await conn.commit();
    res.status(201).json({ id: userId, name, mobile, email, vehicle });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: "Failed to add customer" });
  } finally {
    conn.release();
  }
});

// PUT /api/customers/:id
router.put("/:id", async (req, res) => {
  try {
    const { name, mobile, email } = req.body;
    await pool.query(
      "UPDATE users SET name = ?, phone = ?, email = ? WHERE id = ? AND role = 'customer'",
      [name, mobile, email, req.params.id]
    );
    res.json({ message: "Customer updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update customer" });
  }
});

// DELETE /api/customers/:id
router.delete("/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM users WHERE id = ? AND role = 'customer'", [req.params.id]);
    res.json({ message: "Customer deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete customer" });
  }
});

module.exports = router;
