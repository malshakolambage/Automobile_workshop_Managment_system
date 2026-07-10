const express = require("express");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth);


router.get("/", async (req, res) => {
  try {
    let rows;
    if (req.user.role === "admin") {
      [rows] = await pool.query(
        `SELECT a.*, u.name AS customer_name, v.plate_number
         FROM appointments a
         JOIN users u ON u.id = a.user_id
         LEFT JOIN vehicles v ON v.id = a.vehicle_id
         ORDER BY a.created_at DESC`
      );
    } else {
      [rows] = await pool.query(
        `SELECT a.*, v.model, v.plate_number
         FROM appointments a
         LEFT JOIN vehicles v ON v.id = a.vehicle_id
         WHERE a.user_id = ?
         ORDER BY a.created_at DESC`,
        [req.user.id]
      );
    }
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch appointments" });
  }
});

// POST /api/appointments  -> customer creates a booking (booking_page.dart)
router.post("/", async (req, res) => {
  try {
    const { vehicle_id, service_type, appointment_date, appointment_time, notes } = req.body;
    if (!vehicle_id || !service_type || !appointment_date) {
      return res.status(400).json({ error: "Vehicle, service type and date are required" });
    }

    const [result] = await pool.query(
      `INSERT INTO appointments (user_id, vehicle_id, service_type, appointment_date, appointment_time, notes)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [req.user.id, vehicle_id, service_type, appointment_date, appointment_time || null, notes || null]
    );

    await pool.query(
      "INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'Booking Requested', ?, 'info')",
      [req.user.id, `Your booking for ${service_type} has been submitted and is awaiting approval.`]
    );

    res.status(201).json({ id: result.insertId, message: "Booking submitted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create booking" });
  }
});

// PUT /api/appointments/:id/status  -> admin approves/rejects (appointments.html)
router.put("/:id/status", requireAdmin, async (req, res) => {
  try {
    const { status } = req.body; // Approved | Rejected | Completed | Cancelled
    await pool.query("UPDATE appointments SET status = ? WHERE id = ?", [status, req.params.id]);

    const [[appt]] = await pool.query("SELECT user_id, service_type FROM appointments WHERE id = ?", [req.params.id]);
    if (appt) {
      await pool.query(
        "INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)",
        [
          appt.user_id,
          status === "Approved" ? "Booking Confirmed" : `Booking ${status}`,
          `Your booking for ${appt.service_type} has been ${status.toLowerCase()}.`,
          status === "Approved" ? "success" : status === "Rejected" ? "danger" : "info",
        ]
      );
    }

    res.json({ message: "Status updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update status" });
  }
});

// PUT /api/appointments/:id/progress  -> admin updates progress dropdown (appointments.html)
router.put("/:id/progress", requireAdmin, async (req, res) => {
  try {
    const { progress } = req.body;
    await pool.query("UPDATE appointments SET progress = ? WHERE id = ?", [progress, req.params.id]);
    res.json({ message: "Progress updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update progress" });
  }
});

module.exports = router;
