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