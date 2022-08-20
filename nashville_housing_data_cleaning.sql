create database data_cleaning;
use data_cleaning;

create table housing (
id int not null,
property_address varchar(255),
property_city varchar(255),
sale_date varchar(10),
sale_price int,
sold_as_vacant varchar(255),
owner_address varchar(255),
owner_city varchar(255),
owner_state varchar(255),
primary key(id)
);


set global local_infile=true;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nashville.csv' INTO TABLE data_cleaning.housing
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, property_address, property_city, sale_date, sale_price, sold_as_vacant, owner_address, owner_city, owner_state);

UPDATE data_cleaning.housing SET  sale_date = STR_TO_DATE(REPLACE(sale_date,'/','.'),GET_FORMAT(DATE,'EUR'));
ALTER TABLE data_cleaning.housing MODIFY sale_date DATE; #this was somehow necessary because setting it as date from the start returned only null

select * from housing;

#remove empty property address
delete from housing
where property_address='' or property_address='0';

#note for later - get the same variable in two columns with join to compare different rows for duplicate variable
#note for later - search for keywords with substring(variable, 1, charindex('x', variable)) from table

Select Distinct(sold_as_vacant), count(sold_as_vacant)
from housing
group by sold_as_vacant;

#check for duplicates
create table clean_housing as(
select *,
	row_number() over (
    partition by property_address, sale_price, sale_date
    ) dups
from housing
);
delete from clean_housing
where dups>1;

#ready for tableau
