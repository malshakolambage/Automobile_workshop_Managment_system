require("dotenv").config();
const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth");
const meRoutes = require("./routes/me");
const customerRoutes = require("./routes/customers");
const vehicleRoutes = require("./routes/vehicles");
const appointmentRoutes = require("./routes/appointments");
const feedbackRoutes = require("./routes/feedback");
const notificationRoutes = require("./routes/notifications");
const chatRoutes = require("./routes/chat");
const invoiceRoutes = require("./routes/invoices");
const workshopRoutes = require("./routes/workshop");

const app = express();

app.use(cors()); 
// Default body-size limit is 100kb, which rejects any request carrying a
// base64-encoded photo (profile pictures, workshop logo, etc). Raised to
// 10mb to comfortably fit a phone photo.
app.use(express.json({ limit: "10mb" }));


app.get("/api/health", (req, res) => {
  res.json({ status: "ok", time: new Date().toISOString() });
});

app.use("/api/auth", authRoutes);
app.use("/api/me", meRoutes);
app.use("/api/customers", customerRoutes);
app.use("/api/vehicles", vehicleRoutes);
app.use("/api/appointments", appointmentRoutes);
app.use("/api/feedback", feedbackRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/invoices", invoiceRoutes);
app.use("/api/workshop", workshopRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Todo API is running' });
});


// Fallback 404
app.use((req, res) => res.status(404).json({ error: "Route not found" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on http://localhost:${PORT}`);
});