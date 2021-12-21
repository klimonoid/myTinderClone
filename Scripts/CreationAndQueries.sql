--Filled
CREATE TABLE anthem
(
    id SERIAL PRIMARY KEY NOT NULL,
    link CHAR(300) NOT NULL
);

--Filled
CREATE TABLE question
(
    id SERIAL PRIMARY KEY NOT NULL,
    text CHAR(100) NOT NULL
);

--Filled
CREATE TABLE answer
(
    id SERIAL PRIMARY KEY NOT NULL,
    text CHAR(100) NOT NULL,
    question_id INT NOT NULL REFERENCES question (id)
);

--Filled
CREATE TABLE vibe
(
    id SERIAL PRIMARY KEY NOT NULL,
    question_id INT NOT NULL REFERENCES question (id),
    answer_id INT NOT NULL REFERENCES answer (id)
);

--Filled
CREATE TABLE "user"
(
    id SERIAL PRIMARY KEY NOT NULL,
    email CHAR(100) NOT NULL,
    password CHAR(100) NOT NULL,
    region_attitude FLOAT,
    region_longitude FLOAT,
    phone CHAR(50) NOT NULL,
    name CHAR(50) NOT NULL,
    age INT NOT NULL,
    about CHAR(200) NOT NULL,
    gender CHAR(1) NOT NULL,
    looking_for CHAR(1) NOT NULL,
    position_attitude FLOAT NOT NULL,
    position_longitude FLOAT NOT NULL,
    online BOOLEAN NOT NULL,
    level CHAR(8) NOT NULL,
    amount_of_boosts INT,
    amount_of_likes INT,
    amount_of_super_likes INT,
    amount_of_rewinds INT,
    boost_start_time TIME,
    frozen BOOLEAN NOT NULL,
    anthem_id INT REFERENCES anthem (id)
);

--Filled
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

--Filled
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
    type CHAR(7) NOT NULL,
    status CHAR(7) NOT NULL,
    date TIMESTAMP NOT NULL
);

CREATE TABLE rejection
(
    id SERIAL PRIMARY KEY NOT NULL,
    from_user INT NOT NULL REFERENCES "user" (id),
    to_user INT NOT NULL REFERENCES "user" (id),
    date TIMESTAMP NOT NULL
);



-- вывести количество пользователей по гимнам, упорядочить по убыванию количества
SELECT a.link,
       COUNT(u.id) AS count_users
FROM "user" AS u
         JOIN anthem a ON u.anthem_id = a.id
GROUP BY a.link
ORDER BY count_users DESC;


-- вывести первые 5 вайбов, по количеству пользователей
SELECT
    q.text AS question,
    a.text AS answer_id,
    COUNT(vtc.user_id) AS count_users
FROM vibe_to_client vtc
JOIN vibe v on vtc.vibe_id = v.id
JOIN question q on v.question_id = q.id
JOIN answer a on a.id = v.answer_id
GROUP BY q.text, a.text
ORDER BY count_users DESC
LIMIT(5);

-- по каждому месяцу отобрать топ 3 самых залайканных пользователя

WITH likes_monthly AS (
    SELECT DATE_PART('month', s.date) AS month_of_like,
           s.to_user,
           COUNT(*)                       AS count_of_likes
    FROM sympathy s
    JOIN "user" u ON u.id = s.to_user
    GROUP BY month_of_like, s.to_user
    ORDER BY month_of_like, count_of_likes DESC
),
     ranked_months AS (
         SELECT likes_monthly.*,
                ROW_NUMBER() OVER count_window AS top_users
         FROM likes_monthly
             WINDOW count_window AS (PARTITION BY
                 month_of_like ORDER BY count_of_likes DESC)
     )
SELECT month_of_like, to_user, u.name, u.about, count_of_likes
FROM ranked_months
JOIN "user" u ON u.id = to_user
WHERE top_users <= 3;


-- Вывести вайбы пользователей, которые получили больше мэтчей
-- чем среднее количество отвержений у одного пользователя

WITH matches_per_user AS (
    SELECT
           u.id,
           u.name,
           u.age,
           q.text as question,
           a.text as answer,
           COUNT(*) AS matches_total
    FROM match m
        JOIN "user" u on u.id = m.first_user or u.id = m.second_user
        JOIN vibe_to_client vtc ON vtc.user_id = u.id
        JOIN vibe v on v.id = vtc.vibe_id
        JOIN question q on q.id = v.question_id
        JOIN answer a on a.id = v.answer_id
    GROUP BY u.id, question, answer
    ORDER BY u.id
),
     rejections_per_user AS (
         SELECT
                r.to_user,
                COUNT(*) AS rejections_total
         FROM rejection r
         GROUP BY r.to_user
         ORDER BY rejections_total DESC
     ),
     average_rejections AS (
         SELECT
                AVG(rpu.rejections_total) as avg_rej
         FROM rejections_per_user rpu
     )
SELECT
       mpu.question,
       mpu.answer,
       mpu.matches_total
FROM matches_per_user mpu, average_rejections
WHERE (
    mpu.matches_total > average_rejections.avg_rej
          )
ORDER BY mpu.matches_total;


--Вывести первые 3 сообщения пользователей, не имеющих гимна, один вайб
--И более 1 мэтча

WITH users_without_anthems_and_one_vibe AS (
    SELECT u.id,
           u.name,
           u.about,
           COUNT(vtc.vibe_id) as vibes_total
    FROM "user" u
    JOIN vibe_to_client vtc on u.id = vtc.user_id
    WHERE (
        u.anthem_id IS NULL
              )
    GROUP BY u.id
    ORDER BY u.id
),
     users_by_matches AS (
         SELECT u.id,
                COUNT(*) AS matches_total
         FROM match m, "user" u
         WHERE (
            u.id = m.first_user or u.id = m.second_user
         )
         GROUP BY u.id
         ORDER BY matches_total DESC
     ),
     needed_users AS (
         SELECT u.id, matches_total, u.about, u.name
         FROM users_without_anthems_and_one_vibe u
         INNER JOIN users_by_matches ubm on u.id = ubm.id
         WHERE (
             matches_total > 1
                   )
     )
SELECT nu.id, nu.name, nu.about, text  FROM message msg
JOIN needed_users nu on msg.from_user = nu.id
LIMIT(3);
