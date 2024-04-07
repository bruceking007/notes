create database country charset utf8;
use country;
create table sanguo(
id int primary key auto_increment,
name varchar(20),
attack int,
defense int,
gender char(1),
country varchar(20)
)charset=utf8;
insert into sanguo values(null,'诸葛亮',160,60,'M','蜀国'),
(null,'司马懿',170,70,'M','魏国'),
(null,'貂蝉',180,80,'F','吴国'),
(null,'张飞',190,90,'M','蜀国'),
(null,'赵云',200,99,'M','蜀国');
