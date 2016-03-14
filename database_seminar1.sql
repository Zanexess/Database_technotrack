create database tradetest

create table if not exists seller (
	seller_id serial not null primary key,
	surname varchar(64) not null,
	status integer not null,
	city varchar(64) not null 
);

create table if not exists detail (
	detail_id serial not null primary key,
	name varchar(64) not null,
	color varchar(64) not null,
	weight integer not null,
	city varchar(64) not null 
);

create table if not exists seller_detail (
	seller_detail_id serial not null primary key,
	seller_id integer not null,
	detail_id integer not null,
	quantity integer not null default 0,
	constraint seller_detail_check check (quantity >= 0)
)

alter table seller_detail add constraint 
seller_detail_seller_id_fk foreign key (seller_id) 
references seller(seller_id) on delete cascade on update no action;

alter table seller_detail add constraint
seller_detail_detail_id_fk foreign key (detail_id)
references detail(detail_id) on delete cascade on update no action;

insert into seller (surname, status, city) values
('ИВАНОВ', 20, 'ВОРОНЕЖ'),
('ПЕТРОВ', 15, 'МОСКВА'),
('СИДОРОВ', 10, 'МОСКВА'),
('ЗАЙЦЕВ', 30, 'ВОРОНЕЖ'),
('ВОЛКОВ', 20, 'КИЕВ');

insert into detail (name, color, weight, city) values
('ГАЙКА', 'КРАСНЫЙ', 12, 'ВОРОНЕЖ'),
('БОЛТ', 'ЗЕЛЕНЫЙ', 17, 'МОСКВА'),
('ШАЙБА', 'ГОЛУБОЙ', 17, 'МИНСК'),
('ШАЙБА', 'КРАСНЫЙ', 14, 'ВОРОНЕЖ'),
('ШУРУП', 'ГОЛУБОЙ', 12, 'МОСКВА'),
('ГВОЗДЬ', 'КРАСНЫЙ', 19, 'ВОРОНЕЖ');

insert into seller_detail (seller_id, detail_id, quantity) values
(1, 1, 300),
(1, 2, 200),
(1, 3, 400),
(1, 4, 200),
(1, 5, 100),
(1, 6, 100),
(2, 1, 300),
(2, 2, 400),
(3, 3, 200),
(4, 2, 200),
(4, 4, 300),
(4, 5, 400);

1. Получить имена поставщиков, которые поставляют деталь Д2
select distinct surname from seller s inner join seller_detail sd
on (s.seller_id = sd.seller_id) where detail_id = 2;

2. Получить имена поставщиков, которые поставляют, по крайней мере, одну красную деталь
select surname from seller where not seller_id in 
(select distinct seller_id from seller_detail sd join detail d 
on (sd.detail_id = d.detail_id) where color = 'КРАСНЫЙ');

3. Получить имена поставщиков, которые поставляют все детали
select surname from seller where seller_id in 
(select seller_id from seller_detail group by seller_id having count(*) = 
(select count(distinct detail_id) from seller_detail))

4. Получить имена поставщиков, которые не поставляют деталь Д2
select surname from seller where surname not in 
(select distinct surname from seller s inner join seller_detail sd
on (s.seller_id = sd.seller_id) where detail_id = 2)

5. Получить имена поставщиков, которые поставляют детали, изготовленные в том же городе, 
что и город поставщика.
select surname from seller where surname not in 
(select surname from seller s where not exists
(select 1 from detail d where exists
(select 1 from seller_detail sd 
where s.city = d.city and s.seller_id = sd.seller_id and d.detail_id = sd.detail_id)))

6. Найти имена поставщиков, которые не поставили ни одной детали
select surname from seller where seller.seller_id not in
(select seller_id from seller_detail group by seller_id having count(*) > 0)

7. Найти имена всех красных деталей, которые поставляются поставщиками из Москвы
select name from detail where detail_id in (
select detail_id from seller_detail where seller_id in 
(select seller_id from seller where city = 'МОСКВА')) and color = 'КРАСНЫЙ'

8. Найти детали большого веса (>12), которые поставляются единственным поставщиком
select name, detail_id from detail where detail_id not in (
select detail_id from seller_detail group by detail_id having count(*) > 1) and weight > 12

9. Для каждого производителя посчитать количество экспортируемых деталей и 
их распределение по цветам
select s.surname,
sum(case when color = 'КРАСНЫЙ' THEN 1 ELSE 0 END) red,
sum(case when color = 'ЗЕЛЕНЫЙ' THEN 1 ELSE 0 END) green,
sum(case when color = 'ГОЛУБОЙ' THEN 1 ELSE 0 END) blue,
sum(case when color = 'ЖЕЛТЫЙ' THEN 1 ELSE 0 END) yellow,
count(*) as average
from seller s join seller_detail sd on (s.seller_id = sd.seller_id) 
join detail d on (sd.detail_id = d.detail_id)
group by s.seller_id