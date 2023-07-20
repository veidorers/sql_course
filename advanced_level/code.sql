values (1,2), (3,4), (5,6), (7,8), (8,9)
UNION   -- объедени, оставь уникальными
values (1,2), (3,4), (5,6), (7,8), (8,9);

values (1,2), (3,4), (5,6), (7,8), (8,9)
UNION ALL   --объедени, отдай всё
values (1,2), (3,4), (5,6), (7,8), (8,9);

values (1,2), (3,4), (11, 23), (7,8), (3,9)
INTERSECT   --отдай пересекающиеся
values (1,2), (3,4), (5,6), (7,8), (8,9);

values (1,2), (9,9), (5,6), (7,111), (8,9)
except      --отдай те, что есть в первой выборке, но нет во второй
values (1,2), (3,4), (5,6), (7,8), (8,9);





--2 variant

SELECT seat_no FROM seat s
WHERE aircraft_id = 1
AND not exists(SELECT t.seat_no
               FROM ticket t
                        JOIN flight f on f.id = t.flight_id
               WHERE f.flight_no = 'MN3002'
                 AND f.departure_date::DATE = '2020-06-14'
                AND s.seat_no = t.seat_no);             --  без этого условия он бы всегда возвращал какие-то строки, а теперь это зависит от seat_no

-- 3 variant

SELECT seat_no FROM seat s
WHERE aircraft_id = 1
EXCEPT
SELECT t.seat_no
FROM ticket t
         JOIN flight f on f.id = t.flight_id
WHERE f.flight_no = 'MN3002'
  AND f.departure_date::DATE = '2020-06-14';



  -- Indexes
SELECT * FROM ticket
WHERE id = 5;

CREATE UNIQUE INDEX unique_flight_id_seat_no_idx ON ticket (flight_id, seat_no);

SELECT *
FROM ticket
WHERE flight_id = 5;        --  скорее-всего будет искать при помощи индекса. Это зависит от оптимизатора, количество записей и селективности

SELECT *
FROM ticket
WHERE seat_no = 'B1';       -- будет full scan, так как индекс начинается не с seat_no


SELECT *
FROM ticket
WHERE flight_id = 5
    and seat_no = 'B1';     --будет использоваться индекс. Здесь seat_no может идти в начале условия



select count(distinct flight_id) from ticket;   --9
select count(*) from ticket;        --55
--Селективностью flight_id будет 9/55. Это плохая селективность
--Селективность - отношение количества строк, содержащих уникальную запись к общему количеству строк
--При комбинированном flight_id + seat_no индекс будет уникальным. Это значит селективность = 55/55. Это хорошая селективность

-- Много индексов на одну таблицу - плохо. При обновлении таблицы каждый раз будут обновляться индексы. А это другие файлы.


-- Query execution plan
explain SELECT * FROM ticket;


-- оптимизаторы бывают двух видов:
-- синтаксический (rule-based) - устаревший
-- стоимостной (cost-based)

-- стоимость запроса состоит из:
-- 1. page_cost (input-output) - стоимость считать информацию (страницы, куски) с жёсткого диска для выполнения запроса. 1 стр = 1.0
--          (информация берётся из pg_catalog.pg_class)
-- 2. cpu_cost количество операций, которые нужно выполнить процессору. 1 операция = 0.01


SELECT *
FROM pg_class
WHERE relname = 'ticket';

SELECT
    reltuples,
    relkind,
    relpages
FROM pg_class
WHERE relname = 'ticket';

explain SELECT * FROM ticket;
-- page_cost = 1 * 1.0 =  1.0
-- cpu_cost = 55 * 0.01 = 0.55
-- cost =                 1.55


SELECT
    avg(bit_length(passenger_no) / 8) pass_no,
    avg(bit_length(passenger_name) / 8) pass_name,
    avg(bit_length(seat_no) / 8) s_no
FROM ticket;
-- width (byte):
-- bigint - 8, varchar(32) - 6, varchar(128) - 28, bigint - 8, varchar(4) - 2, numeric - 8
-- 8 + 6 + 28 + 8 + 2 + 8 = 60


explain select *
from ticket
WHERE passenger_name LIKE 'Иван%'
    AND seat_no = 'B1';

explain select
            flight_id,
            count(*)
from ticket
group by flight_id;
--план запроса читается снизу вверх!