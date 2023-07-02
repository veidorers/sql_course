CREATE DATABASE book_repository;

CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL
);

CREATE TABLE book
(
    id        BIGSERIAL PRIMARY KEY,
    name      VARCHAR(128) NOT NULL,
    year      SMALLINT     NOT NULL,
    pages     SMALLINT     NOT NULL,
    author_id INT REFERENCES author (id)
);

DROP TABLE book;
DROP TABLE author;


-- INSERT INTO author(first_name, last_name)
-- VALUES ('author1', 'authorovich1'),
--        ('author2', 'authorovich2'),
--        ('author3', 'authorovich3'),
--        ('author4', 'authorovich4'),
--        ('author5', 'authorovich5');
--
--
-- INSERT INTO book(name, year, pages, author_id)
-- VALUES ('book1', 2001, 305, (SELECT id FROM author WHERE first_name = 'author1')),
--        ('book2', 2020, 305, (SELECT id FROM author WHERE first_name = 'author2')),
--        ('book3', 1999, 305, (SELECT id FROM author WHERE first_name = 'author1')),
--        ('book4', 2005, 305, (SELECT id FROM author WHERE first_name = 'author3')),
--        ('book5', 2011, 305, (SELECT id FROM author WHERE first_name = 'author3')),
--        ('book6', 1988, 305, (SELECT id FROM author WHERE first_name = 'author2')),
--        ('book7', 2010, 305, (SELECT id FROM author WHERE first_name = 'author5')),
--        ('book8', 2007, 305, (SELECT id FROM author WHERE first_name = 'author4')),
--        ('book9', 1997, 305, (SELECT id FROM author WHERE first_name = 'author5')),
--        ('book10', 2023, 305, (SELECT id FROM author WHERE first_name = 'author4'));
--
-- DROP TABLE book;
-- DROP TABLE author;

INSERT INTO author (first_name, last_name)
VALUES ('Кей', 'Хорстманн'),
       ('Стивен', 'Кови'),
       ('Тони', 'Роббинс'),
       ('Наполеон', 'Хилл'),
       ('Роберт', 'Кийосаки'),
       ('Дейл', 'Карнеги');

INSERT INTO book (name, year, pages, author_id)
VALUES ('Java. Библиотеку профессионала. Том 1', 2010, 1102, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java. Библиотеку профессионала. Том 2', 2012, 954, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java SE 8. Вводный курс', 2015, 203, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('7 навыков высокоэффективных людей', 1989, 396, (SELECT id FROM author WHERE last_name = 'Кови')),
       ('Разбуди в себе исполина', 1991, 576, (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Думай и богатей', 1937, 336, (SELECT id FROM author WHERE last_name = 'Хилл')),
       ('Богатый папа, бедный папа', 1997, 352, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Квадрант денежного потока', 1998, 368, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Как перестать беспокоиться и начать жить', 1948, 368, (SELECT id FROM author WHERE last_name = 'Карнеги')),
       ('Как завоевывать друзей и оказывать влияние на людей', 1936, 352,
        (SELECT id FROM author WHERE last_name = 'Карнеги'));

SELECT *
FROM book;

-- 4. Написать запрос, выбирающий: название книги, год и имя автора, отсортированные по году издания книги в возрастающем порядке.
--       Написать тот же запрос, но для убывающего порядка.

SELECT name,
       year,
       (SELECT first_name FROM author WHERE author.id = book.author_id)
FROM book
ORDER BY year;

SELECT b.name,
       b.year,
       (SELECT a.first_name FROM author a WHERE a.id = b.author_id)
FROM book b
ORDER BY b.year DESC;

-- 5. Написать запрос, выбирающий количество книг у заданного автора.
SELECT count(*)
FROM book
WHERE author_id = (SELECT id FROM author WHERE last_name = 'Хорстманн');

-- 6. Написать запрос, выбирающий книги, у которых количество страниц больше среднего количества страниц по всем книгам
SELECT *
FROM book
WHERE pages > (SElECT avg(pages) FROM book);

-- 7. Написать запрос, выбирающий 5 самых старых книг
SELECT *
FROM book
ORDER BY year
LIMIT 5;


-- 8. Дополнить запрос и посчитать суммарное количество страниц среди этих книг
SELECT sum(pages)
FROM (SELECT pages
--       SELECT * тоже пойдёт
      FROM book
      ORDER BY year
      LIMIT 5) a;


-- 9. Написать запрос, изменяющий количество страниц у одной из книг
UPDATE book
SET pages = pages + 5
WHERE name = '7 навыков высокоэффективных людей'
RETURNING name, pages, (SELECT first_name || ' ' || last_name from author WHERE id = book.author_id) author;


-- 10. Написать запрос, удаляющий автора, который написал самую большую книгу

DELETE FROM book
    WHERE author_id = (SELECT author_id FROM book
                       WHERE pages = (SELECT max(pages) FROM book));

--ON DELETE CASCADE вместо этого ^. ибо это нормально не сработает, так как мы удалили, а потом пытаемся удалить, делая поиск по книгам, которых нет)

DELETE
FROM author
WHERE id = (SELECT author_id FROM book
                             WHERE pages = (SELECT max(pages) FROM book));

SELECT *
FROM author;