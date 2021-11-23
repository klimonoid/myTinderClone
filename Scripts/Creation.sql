--Creation of databases
CREATE TYPE subscription_level AS ENUM ('regular', 'plus', 'gold', 'platinum');
CREATE TYPE like_type AS ENUM ('regular', 'super');
CREATE TYPE like_status AS ENUM ('unseen', 'ignored', 'match');
CREATE DOMAIN gender CHAR(1)
    CHECK (value IN ( 'F' , 'M' ) );

CREATE TABLE anthem
(
    id SERIAL PRIMARY KEY NOT NULL,
    link CHAR(300) NOT NULL
);

CREATE TABLE question
(
    id SERIAL PRIMARY KEY NOT NULL,
    text CHAR(50) NOT NULL
);

CREATE TABLE answer
(
    id SERIAL PRIMARY KEY NOT NULL,
    text CHAR(60) NOT NULL
);

CREATE TABLE vibe
(
    id SERIAL PRIMARY KEY NOT NULL,
    question_id INT NOT NULL REFERENCES question (id),
    answer_id INT NOT NULL REFERENCES answer (id)
);

CREATE TABLE "user"
(
    id SERIAL PRIMARY KEY NOT NULL,
    email CHAR(50) NOT NULL,
    password CHAR(100) NOT NULL,
    region POINT,
    phone CHAR(20) NOT NULL,
    name CHAR(30) NOT NULL,
    age INT NOT NULL,
    about CHAR(200) NOT NULL,
    gender gender NOT NULL,
    looking_for gender NOT NULL,
    position POINT NOT NULL,
    online BOOLEAN NOT NULL,
    level subscription_level NOT NULL,
    amount_of_boosts INT NOT NULL,
    amount_of_likes INT NOT NULL,
    amount_of_super_likes INT NOT NULL,
    amount_of_rewinds INT NOT NULL,
    boost_start_time TIME,
    frozen BOOLEAN NOT NULL,
    anthem_id INT REFERENCES anthem (id)
);

CREATE TABLE vibe_to_client
(
    id SERIAL PRIMARY KEY NOT NULL,
    vibe_id INT NOT NULL REFERENCES vibe (id),
    user_id INT NOT NULL REFERENCES "user" (id)
);

CREATE TABLE match
(
    id SERIAL PRIMARY KEY NOT NULL,
    first_user INT NOT NULL REFERENCES "user" (id),
    second_user INT NOT NULL REFERENCES "user" (id)
);

CREATE TABLE block
(
    id SERIAL PRIMARY KEY NOT NULL,
    blocker_user INT NOT NULL REFERENCES "user" (id),
    blocked_user INT NOT NULL REFERENCES "user" (id)
);

CREATE TABLE message
(
    id SERIAL PRIMARY KEY NOT NULL,
    from_user INT NOT NULL REFERENCES "user" (id),
    to_user INT NOT NULL REFERENCES "user" (id),
    text CHAR(200) NOT NULL,
    read BOOLEAN NOT NULL
);

CREATE TABLE photo
(
    id SERIAL PRIMARY KEY NOT NULL,
    photo_path char(200) NOT NULL,
    user_id INT NOT NULL REFERENCES "user" (id)
);

CREATE TABLE sympathy
(
    id SERIAL PRIMARY KEY NOT NULL,
    from_user INT NOT NULL REFERENCES "user" (id),
    to_user INT NOT NULL REFERENCES "user" (id),
    type like_type NOT NULL,
    status like_status NOT NULL,
    date TIME NOT NULL
);

CREATE TABLE rejection
(
    id SERIAL PRIMARY KEY NOT NULL,
    from_user INT NOT NULL REFERENCES "user" (id),
    to_user INT NOT NULL REFERENCES "user" (id),
    date TIME NOT NULL
);