const router = require("express").Router();
const pool = require("../db");

router.get("/rating/movie/top/:year", async (req, res) => {
  const queryString =
    "select id,title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='MOVIE' ORDER BY imdb_score DESC NULLS LAST LIMIT 10;";
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
    "select id,title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='MOVIE' ORDER BY imdb_score ASC NULLS LAST LIMIT 10;";
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
    "select id,title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='SHOW' ORDER BY imdb_score DESC NULLS LAST LIMIT 10;";
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
    "select id,title, release_year, imdb_score, type FROM titles WHERE release_year=$1 AND type='SHOW' ORDER BY imdb_score ASC NULLS LAST LIMIT 10;";
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

router.post("/", async (req, res) => {
  const queryString =
    "INSERT INTO titles (id,title,type,imdb_score,release_year) VALUES ($1,$2,$3,$4,$5) RETURNING *;";
  console.log(req.body);
  const id = req.body.id;
  const name = req.body.name;
  const type = req.body.type.toUpperCase();
  const rating = req.body.rating;
  const year = req.body.year;
  try {
    const { rows } = await pool.query(queryString, [
      id,
      name,
      type,
      rating,
      year,
    ]);
    console.log(rows);
    return res.status(200);
  } catch (err) {
    console.error(err);
    return res.status(500).send(err);
  }
});

router.put("/:id", async (req, res) => {
  const queryString = "UPDATE titles SET title=$1, imdb_score=$2 WHERE id=$3";
  const title = req.body.title;
  const rating = req.body.rating;
  const id = req.params.id;
  try {
    await pool.query(queryString, [title, rating, id]);
    return res.status(200);
  } catch (err) {
    console.error(err);
    return res.status(500).send(err);
  }
});

router.delete("/:id", async (req, res) => {
  const queryString = "DELETE FROM titles WHERE id=$1;";
  const id = req.params.id;
  try {
    await pool.query(queryString, [id]);
    return res.status(200);
  } catch (err) {
    console.error(err);
    return res.status(500).send(err);
  }
});
module.exports = router;
