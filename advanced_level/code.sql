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


-- Query execution plan: 2. Indexes
explain select *
from ticket
where id = 25;
-- Выполняется Seq Scan, так как таблица ticket содержится в 1 странице на ЖД, а индексы - это отдельный файл и потребовалось бы минимум 2 страницы


create table test1 (
    id SERIAL PRIMARY KEY,
    number1 INT NOT NULL,
    number2 INT NOT NULL,
    value VARCHAR(32) NOT NULL
);


insert into test1(number1, number2, value)
select random() * g_s,
       random() * g_s,
       g_s
from generate_series(1, 100000) g_s;


create index test1_number1_idx ON test1(number1);
create index test1_number2_idx ON test1(number2);

SELECT
    relname,
    reltuples,
    relkind,
    relpages
FROM pg_class
WHERE relname like 'test1%';

analyze test1;  --  обновить статистику в pg_class по таблице test1

explain select *
from test1
where number1 = 1000
    and value = '1234';
-- оптимизатор всё равно решает использовать индекс (Index Scan) для поиска и потом просто дополнительно фильтрует.


explain select *
        from test1
where number1 = 1000
    or value = '1234';
-- здесь фулл скан, так как ему нужно будет проверить все строки на "value = '1234'", даже те, у которых другой индекс.

explain select number1
from test1
where number1 = 1000;
-- Index Only Scan

-- 3 варианта использования индексов в запросах:
-- 1. Index Only Scan - нам не нужно обращаться к самой таблице, работаем лишь в файле индекса (так как возвращаем только сам индекс)
--      самый лучший вариант
-- 2. Index Scan - делаем поиск по индексу и дополнительно обращаемся к таблице, чтобы вернуть данные, которых нет в индексе
-- 3. Bitmap Scan - используется, когда результатов может быть очень много, но мы не хотим использовать Full Scan. Если использовать вместо BitMap Scan
-- Index Scan, то будет слишком много обращений к самой таблице.

explain select *
from test1
where number1 < 1000 and number1 > 90000;
-- 1. Создаётся BitMap, количество элементов равно количеству строк в test1 и заполняется нулями
--      0 0 0 0 0 0 0 0 ... 636 times
-- 2. Проходимся по Index Scan, откуда из каждого индекса берём страницу, на которой он находится в таблице (а не в файле индекса),
-- то есть откуда будем его считывать. При этом выполняем проверку "number1 < 1000 AND number1 > 90000"
--      0 0 1 1 0 0 1 0 ... 636 times
-- 3. Проходимся Bitmap Heap Scan по test1, берём только нужные страницы (Batch`ем, то есть все сразу) и делаем перепроверку
-- условия "number1 < 1000 AND number1 > 90000" это нужно, так как мы берём страницу, на которой находятся разные элементы
-- (но есть гарантировано нужный), и они могут не подходить условию



explain select *
        from test1
        where number1 < 1000 and number2 > 90000;
-- Добавляется BitMapAnd. Он по делает битовые операции And на двух BitMap`ах (для каждого индекса) для каждого числа (0 или 1).
-- В итоге формируется BitMap для первого индекса, для второго и BitMapAnd, который потом считывается через BitMap Heap и выполняется Recheck Cond
-- (то же самое актуально для операции OR)


explain select *
        from test1
        where number1 < 1000
          and number2 > 90000
          and value = '90000';
-- Просто добавляется дополнительный фильтр после операции BitMapAnd



-- Query Execution Plan: 3.JOIN

-- обычный explain строит план выполнения запроса. Explain analyze строит план + выполняет запрос, затем сравнивает ожидаемый исход с реальным
explain analyze
select * from test1
where number1 < 1000;
-- Heap Blocks: exact=X - размер BitMap, который пришлось создавать


create table test2(
    id SERIAL PRIMARY KEY,
    test1_id INT REFERENCES test1 (id),
    number1 INT NOT NULL ,
    number2 INT NOT NULL ,
    value VARCHAR(32) NOT NULL
);


insert into test2 (test1_id, number1, number2, value)
select
    id,
    random() * number1,
    random() * number2,
    value
from test1;

create index test2_number1_idx on test2 (number1);
create index test2_number2_idx on test2 (number2);


-- Nested Loop
explain analyze
select *
from test1 t1
join test2 t2 on t1.id = t2.test1_id
limit 100;
-- cost и actual_time отображаются для одной строки. Их нужно умножать на loops

-- 3 варианта связывания таблиц:
-- 1. Nested Loop - используется, когда записей немного. Проходится циклом по таблице, на который был выполнен Full Scan (test2) и связывает через индексы
-- вторую таблицу (индекс pkey на test1)

-- 2. Hash Join - используется, когда записей много. Он полностью сканирует 1 таблицу (даже если есть индексы), на её основе составляет HashTable,
-- затем полностью сканирует другую таблицу и выполняет сравнение (в хеш-таблице это О(1))
-- если Batches > 1, то не всё поместилось в оперативную память и придётся сохранять часть на диск

-- 3. Merge Join - круче всех. Для него необходимо, чтобы оба компонента связывания были отсортированы


-- Hash Join
explain analyze
select *
from test1 t1
         join test2 t2 on t1.id = t2.test1_id;
-- полностью сканирует test1 (хотя там индекс, но если искать по индексу, то придётся много раз переходить между индексами и таблицей),
-- загружает в оперативную память и формирует HashTable
-- полностью сканирует test2 и проверяет Hash Cond (t2.test1_id = t1.id), в хеш-таблице это делается быстро


--без order by t1.id выполняет Hash Join. Планировщик решил, что так оптимизированнее
explain analyze
select *
from test1 t1
    join (select * from test2 order by test1_id) t2
        on t1.id = t2.test1_id
order by t1.id;
-- выполняет Index Scan по test1.id (primary key)
-- выполняет Seq Scan по test2.test1_id и сортирует его
-- берёт два получившихся отсортированных множества и при помощи 1 цикла проходится сразу по обоим, связывая одинаковые


create index test2_test1_id_idx on test2 (test1_id);

analyze test2;

--дешевле будет создать индекс на внешний ключ, чтобы не приходилось вручную  сортировать
explain analyze
select *
from test1 t1
         join test2 t2
              on t1.id = t2.test1_id
order by t1.id;
-- но здесь планировщик решил, что будет дешевле использовать HashJoin (если добавить order by t1.id, то он использует merge join)

-- важно помнить, что планировщик решает как выполнять запрос на основе его статистике, закэшированных данных и не всегда он делает так, как мы ожидаем



-- Triggers

create table audit(
    id INT,
    table_name TEXT,
    date timestamp
);


create or replace function audit_function() returns trigger
language plpgsql
AS $$
    begin
        insert into audit(id, table_name, date)
        values (new.id, tg_table_name, now());
        return null;
    end;
    $$;


create trigger audit_aircraft_trigger
    AFTER update or insert or delete
    ON aircraft
    for each row
    EXECUTE function audit_function();

insert into aircraft (model)
values ('new boeing');

select * from audit;

create trigger update_ticket_trigger AFTER UPDATE
    ON ticket
    FOR EACH ROW
    EXECUTE FUNCTION audit_function();

UPDATE ticket
SET cost = cost - 1
WHERE id = 1;

insert into ticket(passenger_no, passenger_name, flight_id, seat_no, cost)  --не обновило, так как триггер на update
values('test', 'test', 1, 'test', 100.1);

delete from ticket
where passenger_no = 'test';        -- тоже не обновило