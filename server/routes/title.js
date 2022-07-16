const router = require("express").Router();
const pool = require("../db");

router.get("/score/:year", async (req, res) => {
  const queryString =
    "select title, release_year,imdb_score FROM titles WHERE release_year=$1 ORDER BY imdb_score DESC NULLS LAST LIMIT 10;";
  const year = req.params.year;
  try {
    const { rows } = await pool.query(queryString, [year]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

router.get("/years", async (req, res) => {
  const queryString =
    "SELECT COUNT(title) AS count, release_year, type FROM titles GROUP BY release_year, type ORDER BY release_year DESC LIMIT 20;";
  try {
    const { rows } = await pool.query(queryString);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

module.exports = router;
