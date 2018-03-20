CREATE TABLE obstacles (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contenstant_id INTEGER,

  FOREIGN KEY(contenstant_id) REFERENCES contenstant(id)
);

CREATE TABLE contestants (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES team(id)
);

CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  team_name VARCHAR(255) NOT NULL
);

INSERT INTO
  teams (id, team_name)
VALUES
  (1, "Silver snakes"), (2, "Blue barricudas");

INSERT INTO
  contestants (id, fname, lname, team_id)
VALUES
  (1, "Cameron", "McInnes", 1),
  (2, "Doc", "Sportello", 1),
  (3, "Burke", "Stodger", 2),
  (4, "Japonica", "Fenway", NULL),
  (5, "Cameron", "Jones", 1);

INSERT INTO
  obstacles (id, name, contenstant_id)
VALUES
  (1, "The moat", 1),
  (2, "The steps of Knowledge", 2),
  (3, "Spinning Wheel of Doom", 3),
  (4, "The haunted Shrine", 3),
  (5, "Snake Pit", NULL);
