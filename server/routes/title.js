const router = require("express").Router();
const pool = require("../db");

router.get("/rating/movie/top/:year", async (req, res) => {
  const queryString =
    "select title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='MOVIE' ORDER BY imdb_score DESC NULLS LAST LIMIT 10;";
  const year = req.params.year;
  try {
    const { rows } = await pool.query(queryString, [year]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

router.get("/rating/movie/bottom/:year", async (req, res) => {
  const queryString =
    "select title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='MOVIE' ORDER BY imdb_score ASC NULLS LAST LIMIT 10;";
  const year = req.params.year;
  try {
    const { rows } = await pool.query(queryString, [year]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

router.get("/rating/show/top/:year", async (req, res) => {
  const queryString =
    "select title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='SHOW' ORDER BY imdb_score DESC NULLS LAST LIMIT 10;";
  const year = req.params.year;
  try {
    const { rows } = await pool.query(queryString, [year]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

router.get("/rating/show/bottom/:year", async (req, res) => {
  const queryString =
    "select title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='SHOW' ORDER BY imdb_score ASC NULLS LAST LIMIT 10;";
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
