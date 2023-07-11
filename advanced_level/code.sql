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