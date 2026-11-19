# SQL Practice (PostgreSQL)

Репозиторий с практическими задачами по SQL (диалект PostgreSQL).

## База данных
Запросы выполнены на учебной базе авиаперевозок **PostgresPro Demo** (схема `bookings`: рейсы, бронирования, билеты, посадочные талоны, парк самолётов и аэропорты).

## Структура
* `bookings_demo/01_aggregations_and_dates.sql` — фильтрация, группировки (`GROUP BY`, `HAVING`), работа с `NULL`, датами и интервалами (`EXTRACT`, `EPOCH`, `ISODOW`).
* `bookings_demo/02_joins_and_anti_joins.sql` — многотабличные соединения (`INNER JOIN`, `LEFT JOIN`), поиск отсутствующих связей (`Anti-Join`), дедупликация (`DISTINCT`, `DISTINCT ON`).
* `bookings_demo/03_subqueries_and_exists.sql` — скалярные и многострочные подзапросы (`IN`), проверка наличия связей (`EXISTS` / `NOT EXISTS`), оптимизация коррелированных подзапросов через производные таблицы.
