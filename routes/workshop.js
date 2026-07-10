const express = require("express");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth, requireAdmin);

// GET /api/workshop/profile
router.get("/profile", async (req, res) => {
  try {
    const [[profile]] = await pool.query("SELECT * FROM workshop_profile WHERE id = 1");
    res.json(profile);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch profile" });
  }
});

// PUT /api/workshop/profile  (dashboard.html "Workshop Profile" modal)
router.put("/profile", async (req, res) => {
  try {
    const { name, phone, email, location, image } = req.body;
    await pool.query(
      `UPDATE workshop_profile SET name=?, phone=?, email=?, location=?, image=? WHERE id = 1`,
      [name, phone, email, location, image]
    );
    res.json({ message: "Profile updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update profile" });
  }
});


router.get("/stats", async (req, res) => {
  try {
    const [[{ totalCustomers }]] = await pool.query(
      "SELECT COUNT(*) AS totalCustomers FROM users WHERE role = 'customer'"
    );
    const [[{ vehiclesInShop }]] = await pool.query(
      "SELECT COUNT(*) AS vehiclesInShop FROM vehicles WHERE status != 'Ready'"
    );
    const [[{ pendingTasks }]] = await pool.query(
      "SELECT COUNT(*) AS pendingTasks FROM appointments WHERE status = 'Pending'"
    );
    const [[{ todayRevenue }]] = await pool.query(
      "SELECT COALESCE(SUM(total),0) AS todayRevenue FROM invoices WHERE DATE(created_at) = CURDATE()"
    );

    const [schedule] = await pool.query(
      `SELECT a.appointment_time AS time, u.name AS customer, v.plate_number AS vehicle
       FROM appointments a
       JOIN users u ON u.id = a.user_id
       LEFT JOIN vehicles v ON v.id = a.vehicle_id
       WHERE a.appointment_date = CURDATE()
       ORDER BY a.appointment_time ASC`
    );

    const [activity] = await pool.query(
      `SELECT plate_number, status FROM vehicles ORDER BY created_at DESC LIMIT 10`
    );

    res.json({
      totalCustomers,
      vehiclesInShop,
      pendingTasks,
      todayRevenue,
      schedule,
      activity,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch stats" });
  }
});

module.exports = router;
