// Creates (or resets) the workshop admin login.
// Run:  node seedAdmin.js "admin@autonex.lk" "admin123" "Workshop Admin"
require("dotenv").config();
const bcrypt = require("bcryptjs");
const pool = require("./config/db");

async function run() {
  const [, , email, password, name] = process.argv;
  if (!email || !password) {
    console.log('Usage: node seedAdmin.js "admin@autonex.lk" "yourpassword" "Admin Name"');
    process.exit(1);
  }

  const password_hash = await bcrypt.hash(password, 10);

  const [existing] = await pool.query("SELECT id FROM users WHERE email = ?", [email]);
  if (existing.length > 0) {
    await pool.query("UPDATE users SET password_hash = ?, role = 'admin' WHERE email = ?", [
      password_hash,
      email,
    ]);
    console.log(`Updated existing user ${email} to admin with new password.`);
  } else {
    await pool.query(
      "INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, 'admin')",
      [name || "Workshop Admin", email, password_hash]
    );
    console.log(`Created admin account: ${email}`);
  }

  process.exit(0);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
