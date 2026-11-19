-- Задача 1. Найти топ-10 самых дорогих бронирований, общая сумма которых (total_amount)
-- превышает среднюю сумму бронирования по всей базе более чем в 2 раза.
SELECT
    b.book_ref,
    b.book_date,
    b.total_amount
FROM bookings.bookings AS b
WHERE b.total_amount > 2 * (
    SELECT AVG(total_amount)
    FROM bookings.bookings
)
ORDER BY b.total_amount DESC
LIMIT 10;


-- Задача 2. Вывести идентификатор, номер рейса, аэропорт вылета и аэропорт прилёта
-- для рейсов, выполняемых на моделях самолётов с дальностью полёта (range) строго больше 5000 км.
SELECT
    f.flight_id,
    f.flight_no,
    f.departure_airport,
    f.arrival_airport
FROM bookings.flights AS f
WHERE f.aircraft_code IN (
    SELECT aircraft_code
    FROM bookings.aircrafts
    WHERE "range" > 5000
)
LIMIT 15;


-- Задача 3. Найти в справочнике все аэропорты, в которые не запланировано
-- ни одного прилёта (arrival_airport), используя NOT EXISTS.
SELECT
    a.airport_code,
    a.airport_name,
    a.city
FROM bookings.airports AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings.flights AS f
    WHERE f.arrival_airport = a.airport_code
);


-- Задача 4 (вариант А — коррелированный подзапрос). Найти сегменты перелётов,
-- стоимость которых (amount) строго выше средней стоимости перелёта в том же классе.
-- Примечание: логически корректный запрос, но на таблице >1 млн строк выполняется долго (O(N^2)).
SELECT
    tf1.ticket_no,
    tf1.flight_id,
    tf1.fare_conditions,
    tf1.amount
FROM bookings.ticket_flights AS tf1
WHERE tf1.amount > (
    SELECT AVG(tf2.amount)
    FROM bookings.ticket_flights AS tf2
    WHERE tf1.fare_conditions = tf2.fare_conditions
)
ORDER BY tf1.amount DESC
LIMIT 15;


-- Задача 4 (вариант Б — оптимизированный через JOIN с производной таблицей).
-- Предварительная группировка по классам позволяет избежать повторного сканирования таблицы.
SELECT
    tf.ticket_no,
    tf.flight_id,
    tf.fare_conditions,
    tf.amount
FROM bookings.ticket_flights AS tf
INNER JOIN (
    SELECT
        fare_conditions,
        AVG(amount) AS avg_price
    FROM bookings.ticket_flights
    GROUP BY fare_conditions
) AS fares
    ON tf.fare_conditions = fares.fare_conditions
WHERE tf.amount > fares.avg_price
ORDER BY tf.amount DESC
LIMIT 15;


-- Задача 5. Найти уникальных пассажиров (passenger_id, passenger_name),
-- у которых в истории есть хотя бы один перелёт классом 'Business'
-- и хотя бы один перелёт классом 'Economy'. Вывести первые 10 строк.
SELECT DISTINCT ON (t1.passenger_id)
    t1.passenger_id,
    t1.passenger_name
FROM bookings.tickets AS t1
WHERE EXISTS (
    SELECT 1
    FROM bookings.tickets AS t2
    INNER JOIN bookings.ticket_flights AS tf1
        ON t2.ticket_no = tf1.ticket_no
    WHERE t2.passenger_id = t1.passenger_id
      AND tf1.fare_conditions = 'Business'
)
  AND EXISTS (
    SELECT 1
    FROM bookings.tickets AS t3
    INNER JOIN bookings.ticket_flights AS tf2
        ON t3.ticket_no = tf2.ticket_no
    WHERE t3.passenger_id = t1.passenger_id
      AND tf2.fare_conditions = 'Economy'
)
ORDER BY t1.passenger_id ASC, t1.ticket_no DESC
LIMIT 10;