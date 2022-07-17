const router = require("express").Router();
const pool = require("../db");

router.get("/credits/:titleId", async (req, res) => {
  const queryString =
    "select title, name, role FROM titles t JOIN credits c ON t.id=c.id WHERE t.id=$1;";
  const titleId = req.params.titleId;
  try {
    const { rows } = await pool.query(queryString, [titleId]);
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err);
  }
});

module.exports = router;
