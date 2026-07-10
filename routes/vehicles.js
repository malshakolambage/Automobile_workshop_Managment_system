const express = require("express");
const pool = require("../config/db");
const { requireAuth, requireAdmin } = require("../middleware/auth");

const router = express.Router();
router.use(requireAuth);

// GET /api/vehicles
// - Admin: all vehicles (vehicles.html)
// - Customer: only their own vehicles (profile_page.dart "My Vehicles")
router.get("/", async (req, res) => {
  try {
    let rows;
    if (req.user.role === "admin") {
      [rows] = await pool.query(
        `SELECT v.*, u.name AS owner FROM vehicles v
         JOIN users u ON u.id = v.user_id
         ORDER BY v.created_at DESC`
      );
    } else {
      [rows] = await pool.query(
        "SELECT * FROM vehicles WHERE user_id = ? ORDER BY created_at DESC",
        [req.user.id]
      );
    }
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch vehicles" });
  }
});

// POST /api/vehicles  -> customer adds their own vehicle (max 3, matches profile_page.dart UI)
router.post("/", async (req, res) => {
  try {
    const { model, plate_number } = req.body;
    if (!model || !plate_number) {
      return res.status(400).json({ error: "Model and plate number are required" });
    }

    const [[{ count }]] = await pool.query(
      "SELECT COUNT(*) AS count FROM vehicles WHERE user_id = ?",
      [req.user.id]
    );
    if (req.user.role !== "admin" && count >= 3) {
      return res.status(400).json({ error: "Maximum 3 vehicles allowed" });
    }

    const [result] = await pool.query(
      "INSERT INTO vehicles (user_id, model, plate_number) VALUES (?, ?, ?)",
      [req.user.role === "admin" ? req.body.user_id : req.user.id, model, plate_number]
    );
    res.status(201).json({ id: result.insertId, model, plate_number });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add vehicle" });
  }
});

// PUT /api/vehicles/:id/service  -> admin updates service status + notes (vehicles.html modal)
router.put("/:id/service", requireAdmin, async (req, res) => {
  try {
    const { status, description } = req.body;
    await pool.query(
      "UPDATE vehicles SET status = ?, description = ? WHERE id = ?",
      [status, description, req.params.id]
    );

    // Also notify the owning customer
    const [[vehicle]] = await pool.query("SELECT user_id, plate_number FROM vehicles WHERE id = ?", [req.params.id]);
    if (vehicle) {
      await pool.query(
        "INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'info')",
        [vehicle.user_id, "Vehicle Status Updated", `Your vehicle ${vehicle.plate_number} status is now "${status}".`]
      );
    }

    res.json({ message: "Service updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update service" });
  }
});

// DELETE /api/vehicles/:id
router.delete("/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM vehicles WHERE id = ?", [req.params.id]);
    res.json({ message: "Vehicle deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete vehicle" });
  }
});

module.exports = router;
