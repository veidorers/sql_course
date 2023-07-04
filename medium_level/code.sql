CREATE TABLE company
(
    id   INT,
    name VARCHAR(128) NOT NULL UNIQUE,
    date DATE         NOT NULL CHECK (date > '1975-01-01' AND date < '2023-01-01'),
    PRIMARY KEY (id),
    UNIQUE (name, date)
--PRIMARY KEY = UNIQUE NOT NULL
);

DROP TABLE company;

INSERT INTO company(id, name, date)
VALUES (1, 'Google', '2001-09-04'),
       (2, 'Apple', '1976-04-01'),
       (3, 'Facebook', '2004-02-01'),
       (4, 'Amazon', '1994-07-05');

CREATE TABLE employee
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    company_id INT REFERENCES company (id),
    salary     INT,
    UNIQUE (first_name, last_name)
);

DROP TABLE employee;

insert into employee (first_name, last_name, salary, company_id)
values ('Ivan', 'Sidorov', 500, 1),
       ('Ivan', 'Ivanov', 1000, 1),
       ('Petr', 'Petrov', 2000, 3),
       ('Alexey', 'Alexeev', 1500, 4),
       ('Boris', 'Denisov', 1700, 2);

SELECT *
FROM employee;
SELECT *
FROM company;

--

CREATE TABLE contact(
    id BIGSERIAL PRIMARY KEY,
    number VARCHAR(128) NOT NULL,
    type VARCHAR(128)
);

CREATE TABLE employee_contact(
    employee_id BIGINT REFERENCES employee (id),
    contact_id BIGINT REFERENCES contact (id)
);

INSERT INTO contact(number, type)
VALUES ('952-88-77', 'home'),
       ('267-28-92', 'home'),
       ('392-74-25', 'work'),
       ('923-46-08', 'home'),
       ('782-19-23', NULL);


INSERT INTO employee_contact (employee_id, contact_id)
VALUES (1, (SELECT id FROM contact WHERE number = '952-88-77')),
       (1, (SELECT id FROM contact WHERE type = 'work')),
       (2, (SELECT id FROM contact WHERE type = 'work')),
       (2, (SELECT id FROM contact WHERE number = '267-28-92')),
       (3, (SELECT id FROM contact WHERE number = '923-46-08')),
       (4, (SELECT id FROM contact WHERE type IS NULL));

DELETE FROM employee_contact;


SELECT * FROM employee_contact;


SELECT first_name || ' ' || last_name fio,
       company.name
FROM employee,
     company
WHERE employee.company_id = company.id;

-- INNER JOIN           ->      JOIN
-- CROSS JOIN           ->      CROSS JOIN
-- LEFT OUTER JOIN      ->      LEFT JOIN
-- RIGHT OUTER JOIN     ->      RIGHT JOIN
-- FULL OUTER JOIN      ->      FULL JOIN

SELECT employee.first_name || ' ' || employee.last_name fio,
       c.name
FROM employee
         INNER JOIN company c ON company_id = c.id;

SELECT  c.name,
        employee.id || '. ' || employee.first_name || ' ' || employee.last_name fio,
        ec.contact_id,
        concat(c2.number, ' ', c2.type)
--         c2.number
FROM employee
JOIN company c ON employee.company_id = c.id
JOIN employee_contact ec ON employee.id = ec.employee_id
JOIN contact c2 ON ec.contact_id = c2.id;

SELECT * FROM company
    CROSS JOIN (select count(*) FROM employee) t;

SELECT * FROM company, (select count(*) from employee) t;

DROP TABLE employee_contact;
DROP TABLE contact;
DROP TABLE employee;
DROP TABLE company;

--

UPDATE employee
SET company_id = NULL
WHERE company_id = 4;

SELECT * FROM employee;

SELECT
    c.name,
    e.first_name
FROM company c
LEFT JOIN employee e ON c.id = e.company_id;

SELECT
    c.name,
    e.first_name
FROM employee e
LEFT JOIN company c ON e.company_id = c.id;

SELECT
    c.name,
    e.first_name
FROM employee e
         RIGHT JOIN company c ON e.company_id = c.id;


SELECT
    c.name,
    e.first_name
FROM employee e
         FULL JOIN company c ON e.company_id = c.id;