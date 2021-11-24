CREATE TABLE books
    ("book_id" int, "title" varchar(11), "author" varchar(12), "publisher" varchar(1), "publ_year" int, "publ_city" varchar(14), "pages_num" int)
;
    
INSERT INTO books
    ("book_id", "title", "author", "publisher", "publ_year", "publ_city", "pages_num")
VALUES
    (1, 'Война и мир', 'Л.Н. Толстой', 'a', 2000, 'Moscow', 100),
    (2, 'Война и мир', 'Л.Н. Толстой', 'b', 2016, 'Moscow', 200),
    (3, 'ccc', 'cc', 'c', 2016, 'Moscow', 300),
    (4, 'ddd', 'dd', 'd', 2016, 'St. Petersburg', 101),
    (5, 'eee', 'ee', 'e', 2016, 'St. Petersburg', 202),
    (6, 'fff', 'ff', 'f', 2001, 'St. Petersburg', 303)
;


CREATE TABLE books_copies
    ("copy_id" int, "book_id" int)
;
    
INSERT INTO books_copies
    ("copy_id", "book_id")
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (1, 2),
    (2, 2),
    (3, 2),
    (4, 2),
    (5, 2),
    (1, 3),
    (1, 4),
    (2, 4),
    (3, 4),
    (4, 4),
    (5, 4),
    (6, 4),
    (1, 5),
    (2, 5),
    (3, 5),
    (4, 5),
    (1, 6),
    (2, 6)
;


CREATE TABLE books_issuance
    ("copy_id" int, "book_id" int, "issue_date" timestamp, "return_date" timestamp, "reader_ticket_id" int, "employee_id" int)
;
    
INSERT INTO books_issuance
    ("copy_id", "book_id", "issue_date", "return_date", "reader_ticket_id", "employee_id")
VALUES
    (1, 3, '2016-02-01 00:00:00', '2021-02-15 00:00:00', 1, 3),
    (2, 1, '2016-02-01 00:00:00', NULL, 2, 2),
    (3, 4, '2016-02-03 00:00:00', '2021-02-20 00:00:00', 3, 1),
    (1, 1, '2020-01-03 00:00:00', NULL, 1, 2),
    (2, 5, '2020-01-04 00:00:00', NULL, 2, 2),
    (3, 1, '2020-01-04 00:00:00', '2021-01-15 00:00:00', 3, 2),
    (1, 2, '2020-01-05 00:00:00', '2021-01-15 00:00:00', 1, 3),
    (2, 2, '2021-02-05 00:00:00', NULL, 2, 3),
    (3, 2, '2021-02-06 00:00:00', '2021-02-15 00:00:00', 3, 1)
;


CREATE TABLE readers
    ("reader_ticket_id" int, "Фамилия" varchar(6), "Имя" varchar(6), "Отчество" varchar(11), "Дата рождения" date, "Пол" varchar(1), "Адрес" varchar(20), "Телефон" int)
;
    
INSERT INTO readers
    ("reader_ticket_id", "Фамилия", "Имя", "Отчество", "Дата рождения", "Пол", "Адрес", "Телефон")
VALUES
    (1, 'Козлов', 'Данила', 'Дмитриевич', '1996-01-17', 'м', '"111111, Москва"', 12345),
    (2, 'Иванов', 'Петр', 'Васильевич', '1998-01-01', 'м', '"222222, Москва"', 54321),
    (3, 'Петров', 'Иван', 'Никифорович', '1963-03-03', 'м', '"222222, Москва"', 13579)
;


CREATE TABLE employees
    ("employee_id" int, "Фамилия" varchar(10), "Имя" varchar(10), "Отчество" varchar(10))
;
    
INSERT INTO employees
    ("employee_id", "Фамилия", "Имя", "Отчество")
VALUES
    (1, 'Иванов', 'Сергей', 'Львовович'),
    (2, 'Петров', 'Николай', 'Викторович'),
    (3, 'Сидоров', 'Иван', 'Сергеевич')
;

select * from books;
select * from books_copies
limit 5;
select * from books_issuance;
select * from readers;
-- select * from employees;

-- Задание 1.1
-- Найти город (или города), в котором в 2016 году было издано больше всего книг.

with city_2016 as (
    select t.publ_city, count(*) as cnt
    from books t
    where publ_year = 2016
    group by t.publ_city
    )

select t.publ_city from city_2016 t
where cnt in (select max(cnt) from city_2016);

-- Задание 1.2
-- Вывести количество экземпляров книг «Война и мир» Л.Н.Толстого, 
-- которые сейчас находятся в библиотеке (не на руках у читателей).

with 
  war_book_ids as (
  select t.book_id from books t
  where title like 'Война и мир' and author like 'Л.Н. Толстой'),

  total_war_books as 
  (select t.book_id, count(*) as cnt from books_copies t
  where t.book_id in (select * from war_book_ids)
  group by t.book_id
  order by t.book_id),

  absent_books as
  (select t.book_id, count(*) as absent_books_cnt from books_issuance t
  where return_date is null
  group by t.book_id)

select t.book_id, tw.cnt as total, (tw.cnt - t.absent_books_cnt) as in_lib_cnt from absent_books t
join total_war_books tw on tw.book_id = t.book_id;

-- Задание 1.3
-- Найти читателя, который за последний месяц брал больше всего книг в библиотеке. 
-- Если читателей с максимальным количество несколько - вывести только тех, у кого самый маленький возраст.


with last_month_readers as
(
  select date_trunc('month', issue_date) as issue_month,reader_ticket_id, count(*) as cnt
  from books_issuance
  where date_trunc('month', issue_date) = date_trunc('month', (select max(issue_date) from books_issuance))
  group by date_trunc('month', issue_date), reader_ticket_id
),

lm_best_readers as -- (lm = last_month)
(
  select t.*, "Дата рождения" from last_month_readers t
  join readers r on r.reader_ticket_id = t.reader_ticket_id
  where t.cnt = (select max(cnt) from last_month_readers)
  order by "Дата рождения" desc
  limit 1
)

select * from lm_best_readers;

-- В целом такой запрос работает неплохо и выведет нам первого читателя, 
-- который брал больше всего книг за последний месяц, и если таких несколько, то выберет первого самого юного.

-- Но если вдруг таких читателей несколько и даты дней рождений, так уж вышло, у них совпали? 
-- Тогда мы потеряем в таком случае записи, что не есть хорошо. 
-- Перепишу запрос чтобы учесть ещё и эту вероятность.

with last_month_readers as
(
  select date_trunc('month', issue_date) as issue_month,reader_ticket_id, count(*) as cnt
  from books_issuance
  where date_trunc('month', issue_date) = date_trunc('month', (select max(issue_date) from books_issuance))
  group by date_trunc('month', issue_date), reader_ticket_id
),

lm_best_readers as 
(
  select t.*, "Дата рождения" from last_month_readers t
  join readers r on r.reader_ticket_id = t.reader_ticket_id
  where t.cnt = (select max(cnt) from last_month_readers)
  order by "Дата рождения" desc
)

select * from lm_best_readers
where "Дата рождения" = (select max("Дата рождения") from lm_best_readers);

-- Ну вроде как запрос работает хорошо, но есть момент, который меня напрягает немного...
-- Если последняя запись в базе будет 1 число месяца, тогда мы будем смотреть результат только за 1 день, 
-- а не за месяц. Попробую исправить эту ситуацию и добавить условие, учитывающий целый месяц от последней даты в базе.

with last_month_readers as
(
  select reader_ticket_id, count(*) as cnt
  from books_issuance
  where issue_date > (select max(issue_date) from books_issuance) - '1 month'::interval
  group by reader_ticket_id
),

lm_best_readers as 
(
  select t.*, "Дата рождения" from last_month_readers t
  join readers r on r.reader_ticket_id = t.reader_ticket_id
  where t.cnt = (select max(cnt) from last_month_readers)
  order by "Дата рождения" desc
)

select * from lm_best_readers
where "Дата рождения" = (select max("Дата рождения") from lm_best_readers);

-- Теперь все нюансы учтены =)

-- Задание 2.1
-- Найти сотрудника, который выдал больше всего книг в 2020 году.

with issuance_cnt as
(
  select employee_id, count(*) as cnt from books_issuance
  where extract(year from issue_date) = 2020
  group by employee_id
)

select employee_id from issuance_cnt
where cnt = (select max(cnt) from issuance_cnt);

-- По нашим игрушечным данным в 2020 году больше всех книг выдал 2 сотрудник

-- Задание 2.3
-- Найти сотрудника, который выдал книги самому большому и самому маленькому количеству различных читателей.

with issuance_cnt as
(
  select employee_id, count(distinct reader_ticket_id) as cnt from books_issuance
  group by employee_id
)

select employee_id, cnt as max_cnt, null as min_cnt from issuance_cnt
where cnt = (select max(cnt) from issuance_cnt)
union
select employee_id, null as max_cnt, cnt as min_cnt from issuance_cnt
where cnt = (select min(cnt) from issuance_cnt);

-- Вот и нашли, кто и сколько выдал книг уникальным пользователям.