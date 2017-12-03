-- Your SQL goes here:

CREATE TABLE todos (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  todo_id INTEGER,

  FOREIGN KEY(todo_id) REFERENCES todo(id)
);

-- Seeds go here!

INSERT INTO
  todos (id, name)
VALUES
  (1, "Clean my house"),
  (2, "Wash my Car"),
  (3, "Make Lunch");

INSERT INTO
  comments (id, body, todo_id)
VALUES
  (1, "Remember to by cleaner at the store", 1),
  (2, "It is going to rain in 10 days, do it then", 2);

INSERT INTO
  likes (id, comment_id)
VALUES
  (1, 1),
  (2, 2);
