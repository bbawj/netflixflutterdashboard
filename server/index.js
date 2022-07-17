const pg = require("pg");
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(
  cors({
    origin: "*", // allow to server to accept request from different origin
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  })
);

const titleRoute = require("./routes/title");
const creditRoute = require("./routes/credits");
app.use("/api/title", titleRoute);
app.use("/api", creditRoute);

app.listen(PORT, () => {
  console.log("Server running on port:", PORT);
});
