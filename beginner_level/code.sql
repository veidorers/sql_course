CREATE DATABASE company_repository;

CREATE SCHEMA company_storage;

DROP SCHEMA company_storage;

CREATE TABLE company_storage.company
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
       (3, 'Facebook', '2004-02-01');

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
       ('Alexey', 'Alexeev', 1500, NULL),
       ('Boris', 'Denisov', NULL, 2);