require("dotenv").config();
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: "netflix",
  password: process.env.DB_SECRET,
  port: 5432,
  ssl: true,
});

module.exports = pool;
