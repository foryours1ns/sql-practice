-- Задача 1. Вывести все модели самолётов и их дальность полёта,
-- от самой дальнобойной к самой короткой.
SELECT
    model,
    range
FROM bookings.aircrafts
ORDER BY range DESC;


-- Задача 2. Вывести города, в которых есть аэропорты, без повторов и по алфавиту.
SELECT DISTINCT
    city
FROM bookings.airports
ORDER BY city ASC;


-- Задача 3. Вывести отменённые или задержанные рейсы:
-- номер рейса, аэропорт вылета и статус.
SELECT
    flight_no,
    departure_airport,
    status
FROM bookings.flights
WHERE status IN ('Cancelled', 'Delayed');


-- Задача 4. Найти пассажиров с фамилией IVANOV: вывести имя пассажира и номер билета.
SELECT
    passenger_name,
    ticket_no
FROM bookings.tickets
WHERE passenger_name LIKE '% IVANOV';


-- Задача 5. Вывести бронирования на сумму от 50 000 до 100 000 рублей включительно,
-- от самых дорогих к более дешёвым.
SELECT
    book_ref,
    book_date,
    total_amount
FROM bookings.bookings
WHERE total_amount BETWEEN 50000 AND 100000
ORDER BY total_amount DESC;


-- Задача 6. Посчитать количество рейсов в каждом статусе,
-- от самого частого статуса к самому редкому.
SELECT
    status,
    COUNT(*) AS flights_count
FROM bookings.flights
GROUP BY status
ORDER BY flights_count DESC;


-- Задача 7. Найти коды моделей самолётов, в салоне которых более 100 мест.
SELECT
    aircraft_code
FROM bookings.seats
GROUP BY aircraft_code
HAVING COUNT(seat_no) > 100;


-- Задача 8. Для каждого класса обслуживания рассчитать минимальную,
-- максимальную и среднюю (округлённую до целых рублей) стоимость перелёта.
SELECT
    fare_conditions,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount,
    ROUND(AVG(amount)) AS avg_amount_rounded
FROM bookings.ticket_flights
GROUP BY fare_conditions;


-- Задача 9. Рассчитать среднюю задержку вылета в минутах
-- по рейсам, которые уже вылетели.
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (actual_departure - scheduled_departure)) / 60),
        2
    ) AS avg_delay_mins
FROM bookings.flights
WHERE actual_departure IS NOT NULL;


-- Задача 10. Посчитать количество оформленных бронирований по дням недели
-- в хронологическом порядке с понедельника (1) по воскресенье (7).
SELECT
    EXTRACT(ISODOW FROM book_date) AS weekday_num,
    COUNT(book_ref) AS bookings_count
FROM bookings.bookings
GROUP BY weekday_num
ORDER BY weekday_num ASC;
