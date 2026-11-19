-- Задача 1. Посчитать, сколько фактически выполненных (Arrived) рейсов совершила
-- каждая модель самолёта из справочника. Отсортировать по убыванию количества рейсов.
SELECT
    a.model,
    COUNT(f.flight_id) AS flights_count
FROM bookings.aircrafts AS a
LEFT JOIN bookings.flights AS f
    ON a.aircraft_code = f.aircraft_code
    AND f.status = 'Arrived'
GROUP BY a.aircraft_code, a.model
ORDER BY flights_count DESC;


-- Задача 2. Найти все аэропорты из справочника, из которых не было запланировано
-- ни одного вылета. Вывести код аэропорта, название и город.
SELECT
    a.airport_code,
    a.airport_name,
    a.city
FROM bookings.airports AS a
LEFT JOIN bookings.flights AS f
    ON a.airport_code = f.departure_airport
WHERE f.flight_id IS NULL;


-- Задача 3. Посчитать общее количество рейсов в базе, у которых аэропорт вылета
-- и аэропорт прилёта находятся в разных часовых поясах.
SELECT
    COUNT(f.flight_id) AS diff_tz_flights
FROM bookings.flights AS f
INNER JOIN bookings.airports AS dep
    ON f.departure_airport = dep.airport_code
INNER JOIN bookings.airports AS arr
    ON f.arrival_airport = arr.airport_code
WHERE dep.timezone <> arr.timezone;


-- Задача 4. Для каждой модели самолёта из справочника посчитать количество мест
-- класса Business (включая модели без бизнес-класса). Отсортировать по возрастанию.
SELECT
    a.model,
    COUNT(s.seat_no) AS business_seats_count
FROM bookings.aircrafts AS a
LEFT JOIN bookings.seats AS s
    ON a.aircraft_code = s.aircraft_code
    AND s.fare_conditions = 'Business'
GROUP BY a.aircraft_code, a.model
ORDER BY business_seats_count ASC;


-- Задача 5. Найти билеты на уже прилетевшие рейсы (Arrived), по которым пассажирам
-- не были выданы посадочные талоны. Вывести номер билета и идентификатор рейса.
SELECT
    tf.ticket_no,
    tf.flight_id
FROM bookings.flights AS f
INNER JOIN bookings.ticket_flights AS tf
    ON f.flight_id = tf.flight_id
LEFT JOIN bookings.boarding_passes AS bp
    ON tf.ticket_no = bp.ticket_no
    AND tf.flight_id = bp.flight_id
WHERE f.status = 'Arrived'
  AND bp.ticket_no IS NULL;


-- Задача 6. Вывести уникальных пассажиров с фамилией IVANOV (паспорт и ФИО),
-- летавших из Москвы в Санкт-Петербург.
SELECT DISTINCT ON (t.passenger_id)
    t.passenger_id,
    t.passenger_name
FROM bookings.tickets AS t
INNER JOIN bookings.ticket_flights AS tf
    ON t.ticket_no = tf.ticket_no
INNER JOIN bookings.flights AS f
    ON tf.flight_id = f.flight_id
INNER JOIN bookings.airports AS da
    ON f.departure_airport = da.airport_code
INNER JOIN bookings.airports AS aa
    ON f.arrival_airport = aa.airport_code
WHERE t.passenger_name LIKE '% IVANOV'
  AND da.city = 'Москва'
  AND aa.city = 'Санкт-Петербург'
ORDER BY t.passenger_id, t.ticket_no DESC;


-- Задача 7. Для каждого аэропорта из справочника посчитать количество отменённых
-- вылетов (включая аэропорты с нулём отмен).
SELECT
    a.airport_code,
    a.airport_name,
    COUNT(f.flight_id) AS count_cancelled
FROM bookings.airports AS a
LEFT JOIN bookings.flights AS f
    ON a.airport_code = f.departure_airport
    AND f.status = 'Cancelled'
GROUP BY a.airport_code, a.airport_name
ORDER BY count_cancelled DESC, a.airport_name ASC;


-- Задача 8. Рассчитать среднюю стоимость одной минуты фактического полёта
-- в разрезе классов обслуживания (для прилетевших рейсов).
SELECT
    tf.fare_conditions,
    ROUND(
        AVG(tf.amount::numeric / (EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure)) / 60)),
        2
    ) AS avg_fare_per_min
FROM bookings.ticket_flights AS tf
INNER JOIN bookings.flights AS f
    ON tf.flight_id = f.flight_id
WHERE f.status = 'Arrived'
  AND f.actual_arrival > f.actual_departure
GROUP BY tf.fare_conditions;


-- Задача 9. Найти все непроданные / незанятые места на конкретном рейсе (flight_id = 55)
-- и вывести номер места и класс обслуживания.
SELECT
    s.seat_no,
    s.fare_conditions
FROM bookings.flights AS f
INNER JOIN bookings.seats AS s
    ON f.aircraft_code = s.aircraft_code
LEFT JOIN bookings.boarding_passes AS bp
    ON s.seat_no = bp.seat_no
    AND f.flight_id = bp.flight_id
WHERE f.flight_id = 55
  AND bp.flight_id IS NULL;


-- Задача 10. Найти топ-5 самых дорогих бронирований, в которых хотя бы один сегмент
-- выполнялся на Boeing 777-300 в субботу или воскресенье по расписанию.
SELECT DISTINCT
    b.book_ref,
    b.book_date,
    b.total_amount
FROM bookings.bookings AS b
INNER JOIN bookings.tickets AS t
    ON b.book_ref = t.book_ref
INNER JOIN bookings.ticket_flights AS tf
    ON t.ticket_no = tf.ticket_no
INNER JOIN bookings.flights AS f
    ON tf.flight_id = f.flight_id
INNER JOIN bookings.aircrafts AS a
    ON f.aircraft_code = a.aircraft_code
WHERE a.model = 'Boeing 777-300'
  AND EXTRACT(ISODOW FROM f.scheduled_departure) IN (6, 7)
ORDER BY b.total_amount DESC
LIMIT 5;