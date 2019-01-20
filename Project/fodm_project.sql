create database fodm_project
use fodm_project


drop table Inspection;
drop table components_in_software_products;
drop table Components;
drop table Employees;
drop table software_products;
drop table programming_language;
drop table employeeLeftInformation;


create table programming_language
(
language_name varchar(20) primary key,
language_status ENUM('current', 'future') not null
);

create table software_products
(
name varchar(40),
version varchar(10),
software_status ENUM('Ready', 'not-ready', 'usable') not null default 'not-ready',
primary key(name,version)
);


create table Employees
(
id int primary key,
name varchar(30),
hire_date timestamp,
mgr_id int,
seniority varchar(10),
FOREIGN KEY (mgr_id) REFERENCES Employees(id) on delete set null
);

create table Components
(
comp_id int auto_increment,
component_name varchar(40),
version varchar(10),
component_size int,
prog_language varchar(20),
comp_owner int,
component_status ENUM('Ready', 'not-ready', 'usable') not null default 'not-ready',
primary key(component_name, version),
FOREIGN KEY (prog_language) REFERENCES programming_language(language_name),
-- FOREIGN KEY (comp_owner) REFERENCES Employees(id) on delete set null,
key (comp_id)
);

create table components_in_software_products
(
name varchar(40),
version varchar(10),
comp_id int,
primary key(name,version, comp_id),
FOREIGN KEY (name, version) REFERENCES software_products(name, version),
FOREIGN KEY (comp_id) REFERENCES Components(comp_id)
);


create table Inspection
(
inspection_id int primary key auto_increment,
component_name varchar(40),
version varchar(10),
inspection_date timestamp not null,
by_who int,
score int not null,
description varchar(4000),
status ENUM('Ready', 'not-ready', 'usable') not null default 'not-ready',
-- FOREIGN KEY (by_who) REFERENCES Employees(id) on delete set null,
FOREIGN KEY (component_name, version) REFERENCES Components(component_name, version),
key (inspection_id)
);

-- Table for Question 11 --
create table employeeLeftInformation
(
id int primary key,
name varchar(30),
leftDate timestamp
);



-- Triggers

-- Trigger on Mgr Id --
-- INSERT
/*
insert into employees(id, name, hire_date, mgr_id) 
values(10100, 'Employee-1', STR_TO_DATE( '08/11/1984', '%m/%d/%Y'), 101000);
*/


-- select * from employees;
-- delete from employees;

/*
insert into employees(id, name, hire_date, mgr_id) values(10100, 'Employee-1', STR_TO_DATE( '08/11/1984', '%m/%d/%Y'),10100);
insert into employees(id, name, hire_date, mgr_id) values(10200, 'Employee-2', STR_TO_DATE( '08/11/1994', '%m/%d/%Y'),10100);
insert into employees(id, name, hire_date, mgr_id) values(10300, 'Employee-3', STR_TO_DATE( '08/11/2004', '%m/%d/%Y'),10200);
insert into employees(id, name, hire_date, mgr_id) values(10400, 'Employee-4', STR_TO_DATE( '01/11/2008', '%m/%d/%Y'),10200);
insert into employees(id, name, hire_date, mgr_id) values(10500, 'Employee-5', STR_TO_DATE( '01/11/2015', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10600, 'Employee-6', STR_TO_DATE( '01/11/2015', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10700, 'Employee-7', STR_TO_DATE( '01/11/2016', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10800, 'Employee-8', STR_TO_DATE( '01/11/2017', '%m/%d/%Y'),10200);
insert into employees(id, name, hire_date, mgr_id) values(10020, 'Employee-8', STR_TO_DATE( '01/11/2017', '%m/%d/%Y'),11000);
select * from employees;
delete from employees;
*/

-- drop trigger empolyee_manager_validate_insert;
delimiter $$
create trigger empolyee_manager_validate_insert 
before insert on Employees
for each row
begin
	DECLARE `count_occ_emp` INT default 0;
	(select count(*) into `count_occ_emp` from Employees where Employees.id = new.mgr_id group by Employees.id);
	
    if (new.id = 10100) then -- 10100 is the CEO as per the requirement
		if (new.mgr_id = 10100 or new.mgr_id = null) then
			set new.mgr_id = new.mgr_id;
        else
			signal sqlstate '45000'
			set message_text = 'The CEO can not have a subordinate as a manager or enter his own id or null as his manager.';
        end if;
	else
			if (`count_occ_emp` = 0) then
				signal sqlstate '45000'
				set message_text = 'Manager should be an existing employee';
            else if (new.id = new.mgr_id) then
				signal sqlstate '45000'
				set message_text = 'An employee cannot be his own manager';
            end if;
            end if;
    end if;
end;
$$
delimiter ;


-- UPDATE
-- drop trigger empolyee_manager_validate_update;
delimiter $$
create trigger empolyee_manager_validate_update
before update on Employees
for each row
begin
	DECLARE `count_occ_emp` INT default 0;
	(select count(*) into `count_occ_emp` from Employees where Employees.id = new.mgr_id group by Employees.id);
	
    if (new.id = 10100) then -- 10100 is the CEO as per the requirement
		if (new.mgr_id = 10100 or new.mgr_id = null) then
			set new.mgr_id = new.mgr_id;
        else
			signal sqlstate '45000'
			set message_text = 'The CEO can not have a subordinate as a manager or enter his own id or null as his manager.';
        end if;
	else if (new.mgr_id = null) then
		begin
			set	new.mgr_id = null;
        end;
    else
			if (`count_occ_emp` = 0) then
				signal sqlstate '45000'
				set message_text = 'Manager should be an existing employee';
            else if (new.id = new.mgr_id) then
				signal sqlstate '45000'
				set message_text = 'An employee cannot be his own manager';
            end if;
            end if;
            
    end if;
    end if;
end;
$$
delimiter ;


-- drop trigger empolyee_delete
delimiter $$
create trigger empolyee_delete
after delete on Employees
for each row
begin
	insert into employeeLeftInformation values(old.id, old.name, current_date());
end;
$$
delimiter ;

/*
-- delete from employees where id = 10400;

drop procedure updateEmployeesDataAfterDelete
Delimiter $$
CREATE PROCEDURE updateEmployeesDataAfterDelete (IN id INT)
BEGIN
	update Employees set `Employees`.mgr_id = null where `Employees`.mgr_id = id;
END $$
Delimiter ;
*/

-- drop trigger component_validate_insert
delimiter $$
create trigger component_validate_insert
before insert on components
for each row
begin
	DECLARE `count_occ_emp` INT default 0;
	(select count(*) into `count_occ_emp` from Employees where Employees.id = new.comp_owner group by Employees.id);
			if (`count_occ_emp` = 0) then
				signal sqlstate '45000'
				set message_text = 'Manager should be an existing employee';
            end if;
end;
$$
delimiter ;


-- Tiggers and Stored Procedure for Update in Components
-- Procedure to change the status of the component
drop procedure updateComponentsStatus;
Delimiter $$
CREATE PROCEDURE updateComponentsStatus (IN component_name varchar(40), IN version varchar(10), IN status varchar(10))
BEGIN
	Declare id INT;
	update Components set Components.component_status = status where Components.component_name = component_name and Components.version = version;
   set id = (select comp_id from Components where Components.component_name = component_name and Components.version = version);
   CALL updateSoftwareProductStatus(id);
END $$
Delimiter ;





drop procedure updateSoftwareProductStatus;
Delimiter $$
CREATE PROCEDURE updateSoftwareProductStatus (IN id int)
BEGIN
	
	DECLARE current_streak int;
    DECLARE rowcount int;
	DECLARE Name VARCHAR(40);
    DECLARE Version VARCHAR(10);
    DECLARE updateDone INT DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT components_in_software_products.name,components_in_software_products.version  FROM components_in_software_products where components_in_software_products.comp_id = id;
	-- DECLARE EXIT HANDLER FOR NOT FOUND    
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET updateDone = 1;
    
	set current_streak=0;
    open cur;
	select FOUND_ROWS() into rowcount ;

	start_loop: loop
        IF updateDone =1 THEN
            LEAVE start_loop;
        END IF;
        
        fetch cur into Name,Version;
        
		set current_streak = current_streak +1;
		if ((select count(*) from Components where Components.component_status like 'not-ready' and Components.comp_id in (SELECT components_in_software_products.comp_ID  FROM components_in_software_products where components_in_software_products.name = Name and components_in_software_products.version = Version)) >0 ) then
			update software_products set software_products.software_status = 'not-ready' where software_products.name = name and software_products.version = version;
		
		else if ((select count(*) from Components where Components.component_status like 'usable' and Components.comp_id in (SELECT components_in_software_products.comp_ID  FROM components_in_software_products where components_in_software_products.name = Name and components_in_software_products.version = Version)) >0 ) then
			update software_products set software_products.software_status = 'usable' where software_products.name = name and software_products.version = version;
       
		else 
			update software_products set software_products.software_status = 'ready' where software_products.name = name and software_products.version = version;
		end if;
        end if;
        
        if (current_streak<=rowcount) then
			leave start_loop;
		end if;
     
    end loop;
    close cur;
	
END $$
Delimiter ;



-- select * from employees;
/*
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(15, "Dynamic Table Interface", "D01", 11/20/2017, 11400, 80, "minor fixes needed");
delete from Inspection where inspection_id = 15;
*/
-- Triggers on Status (Inspection)
-- INSERT
-- drop trigger inspection_status_insert;
delimiter $$
create trigger inspection_status_insert 
before insert on Inspection
for each row
begin
	DECLARE `count_occ` INT default 0;
	(select count(*) into `count_occ` from Employees where Employees.id = new.by_who group by Employees.id);
    if (`count_occ` = 0) then
		signal sqlstate '45000'
		set message_text = 'Employee not present';
	end if;
    
	if (new.score > 90 ) then
		set new.status = 'ready';
	else if (new.score < 75) then
		set new.status = 'not-ready';
	else
		set new.status = 'usable';
	end if;
    end if;
    CALL updateComponentsStatus(new.component_name, new.version, new.status);
end;
$$
delimiter ;





-- Triggers on Status (Inspection)
-- UPDATE
delimiter $$
create trigger inspection_status_update 
before update on Inspection
for each row
begin
	DECLARE score_value INT;
    DECLARE by_who INT;
	SET score_value = (select score from Inspection where Inspection.inspection_id = new.inspection_id);
	SET by_who = (select by_who from Inspection where Inspection.inspection_id = new.inspection_id);
    
    if (by_who != new.by_who) then
		signal sqlstate '45000'
		set message_text = 'Cannot update the Inspection owner';
    end if;
    
    if (score_value != new.score) then
		signal sqlstate '45000'
		set message_text = 'Cannot update score';
    end if;
end;
$$
delimiter ;

-- Triggers for Employees
-- Seniority
drop event seniority_update;
SET GLOBAL event_scheduler = ON;
delimiter $$
CREATE EVENT seniority_update
ON SCHEDULE
EVERY 1 day
DO
BEGIN
	
	DECLARE current_streak int;
    DECLARE rowcount int;
    Declare hire_date timestamp;
    Declare id int;
    Declare date_diff int;
	DECLARE seniority_temp VARCHAR(10);
    DECLARE updateDone INT DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT id, hire_date from employees;
	-- DECLARE EXIT HANDLER FOR NOT FOUND    
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET updateDone = 1;
    
	set current_streak=0;
    open cur;
	select FOUND_ROWS() into rowcount ;

	start_loop: loop
        IF updateDone =1 THEN
            LEAVE start_loop;
        END IF;
        
        fetch cur into id, hire_date;
        
		set current_streak = current_streak +1;
		set date_diff = ((UNIX_TIMESTAMP(current_date()) - UNIX_TIMESTAMP(hire_date))/60/60/24);
		
        if (day_diff < 365) then
			update Employees set seniority = 'newbie' where Employees.id = id;
		else if (day_diff > 365 and day_diff < 1825) then
			update Employees set seniority = 'junior' where Employees.id = id;
		else if (day_diff > 1825) then
			update Employees set seniority = 'senior' where Employees.id = id;
		end if;
		end if;
		end if;
    
        
        if (current_streak<=rowcount) then
			leave start_loop;
		end if;
     
    end loop;
    close cur;
            
END 
$$
delimiter ;


-- Triggers on Employee Seniority  --> WORKING
-- Insert

delimiter $$
create trigger employee_seniority_update 
before insert on employees
for each row
begin
	DECLARE day_diff INT;
    set day_diff = ((UNIX_TIMESTAMP(current_date()) - UNIX_TIMESTAMP(new.hire_date))/60/60/24);
    if (day_diff < 365) then
		set new.seniority = 'newbie';
    else if (day_diff > 365 and day_diff < 1825) then
		set new.seniority = 'junior';
	else if (day_diff > 1825) then
		set new.seniority = 'senior';
    end if;
    end if;
    end if;
end;
$$
delimiter ;





-- Insert Programming languages
insert into programming_language values('C','current');
insert into programming_language values('C++','current');
insert into programming_language values('C#','current');
insert into programming_language values('Java','current');
insert into programming_language values('PHP','current');
insert into programming_language values('Python','Future');
insert into programming_language values('assembly','Future');

/*
insert into employees(id, name, hire_date, mgr_id) values(10100, 'Employee-1', STR_TO_DATE( '08/11/1984', '%m/%d/%Y'), 101000);
select * from employees;
*/

-- insert into employees(id, name, hire_date, mgr_id) values(10900, 'Employee-2', STR_TO_DATE( '08/11/1994', '%m/%d/%Y'),1010000);



-- Insert Into Employees
insert into employees(id, name, hire_date, mgr_id) values(10100, 'Employee-1', STR_TO_DATE( '08/11/1984', '%m/%d/%Y'),10100);
insert into employees(id, name, hire_date, mgr_id) values(10200, 'Employee-2', STR_TO_DATE( '08/11/1994', '%m/%d/%Y'),10100);
insert into employees(id, name, hire_date, mgr_id) values(10300, 'Employee-3', STR_TO_DATE( '08/11/2004', '%m/%d/%Y'),10200);
insert into employees(id, name, hire_date, mgr_id) values(10400, 'Employee-4', STR_TO_DATE( '01/11/2008', '%m/%d/%Y'),10200);
insert into employees(id, name, hire_date, mgr_id) values(10500, 'Employee-5', STR_TO_DATE( '01/11/2015', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10600, 'Employee-6', STR_TO_DATE( '01/11/2015', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10700, 'Employee-7', STR_TO_DATE( '01/11/2016', '%m/%d/%Y'),10400);
insert into employees(id, name, hire_date, mgr_id) values(10800, 'Employee-8', STR_TO_DATE( '01/11/2017', '%m/%d/%Y'),10200);



-- Insert into Components
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(1, 'Keyboard Driver', 'K11', 1200, 'C', 10100);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(2, 'Touch Screen Driver', 'T00', 4000, 'C++', 10100);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(3, 'Dbase Interface', 'D00', 2500, 'C++', 10200);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(4, 'Dbase Interface', 'D01', 2500,'C++', 10300);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(5, 'Chart generator', 'C11', 6500, 'java', 10200);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(6, 'Pen Driver', 'P01', 3575, 'C', 10700);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(7, 'Math unit', 'A01', 5000, 'C', 10200);
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(8, 'Math unit', 'A02', 3500, 'Java', 10200);


-- Insert into Software Products
insert into software_products(name, version) values('Excel', '2010');
insert into software_products(name, version) values('Excel', '2015');
insert into software_products(name, version) values('Excel', '2018beta');
insert into software_products(name, version) values('Excel', 'secret');

-- Insert into Components in Software
insert into components_in_software_products values('Excel', '2010', 1);
insert into components_in_software_products values('Excel', '2010', 3);
insert into components_in_software_products values('Excel', '2015', 1);
insert into components_in_software_products values('Excel', '2015', 4);
insert into components_in_software_products values('Excel', '2015', 6);
insert into components_in_software_products values('Excel', '2018beta', 1);
insert into components_in_software_products values('Excel', '2018beta', 2);
insert into components_in_software_products values('Excel', '2018beta', 5);
insert into components_in_software_products values('Excel', 'secret', 1);
insert into components_in_software_products values('Excel', 'secret', 2);
insert into components_in_software_products values('Excel', 'secret', 5);
insert into components_in_software_products values('Excel', 'secret', 8);


-- insert into Inspection
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(1, 'Keyboard Driver', 'K11', STR_TO_DATE('02/14/2010', '%m/%d/%Y'), 10100, 100, 'legacy code which is already approved');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(2, 'Touch Screen Driver', 'T00', STR_TO_DATE('06/01/2017', '%m/%d/%Y'), 10200, 95, 'initial release ready for usage');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(3, 'Dbase Interface', 'D00', STR_TO_DATE('02/22/2010', '%m/%d/%Y'), 10100, 55, 'too many hard coded parameters, the software must be more maintainable and configurable because we want to use this in other products.');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(4, 'Dbase Interface', 'D00', STR_TO_DATE('02/24/2010', '%m/%d/%Y'), 10100, 78, 'improved, but only handles DB2 format');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(5, 'Dbase Interface', 'D00', STR_TO_DATE('02/26/2010', '%m/%d/%Y'), 10100, 95, 'Okay, handles DB3 format.');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(6, 'Dbase Interface', 'D00', STR_TO_DATE('02/28/2010', '%m/%d/%Y'), 10100, 100, 'satisfied');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(7, 'Dbase Interface', 'D01', STR_TO_DATE('05/01/2011', '%m/%d/%Y'), 10200, 100, 'Okay ready for use');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(8, 'Pen Driver', 'P01', STR_TO_DATE('07/15/2017', '%m/%d/%Y'), 10300, 80, 'Okay ready for beta testing');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(9, 'Math unit', 'A01', STR_TO_DATE('06/10/2014', '%m/%d/%Y'), 10100, 90, 'almost ready');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(10, 'Math unit', 'A02', STR_TO_DATE('06/15/2014', '%m/%d/%Y'), 10100, 70, 'Accuracy problems!');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(11, 'Math unit', 'A02', STR_TO_DATE('06/30/2014', '%m/%d/%Y'), 10100, 100, 'Okay problems fixed');
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(12, 'Math unit', 'A02', STR_TO_DATE('11/02/2016', '%m/%d/%Y'), 10700, 100, 're-review for new employee to gain experience in the process.');

-- insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(20, 'Math unit', 'A02', STR_TO_DATE('11/02/2016', '%m/%d/%Y'), -100, 100, 're-review for new employee to gain experience in the process.');





-- 1
select * from software_products;


-- 2
select Employees.name,Components.component_name,Components.version
from Employees, Components
where components.component_status like 'not-ready' and components.comp_owner = employees.id;

-- 3
select Components.component_name,Components.version 
from components 
left outer join inspection on Components.component_name = inspection.component_name and components.version = inspection.version
where inspection.component_name is null;

-- 4
select avg(tableTemp.componentsCount) 
from ( select count(components.comp_id) as componentsCount
from components
group by components.comp_owner) as tableTemp;

-- 5
select avg(inspection.score)
from inspection
where (component_name,version) in (select component_name,version
					from components
					where comp_id in (select comp_id 
									from components_in_software_products
									where components_in_software_products.name like 'Excel' and components_in_software_products.version like 'secret'));

-- 6

select e.name, e.seniority, count(distinct c.comp_id) as Assigned_Components, count(distinct i.inspection_id)
as Inspection_Performed, avg(i.score) as Average_Score
from components c right join employees e on e.id = c.comp_owner
left join inspection i on e.id = i.by_who
group by e.id;





create view component_view 
as 
select comp_owner,count(comp_id) as 'compCount'
from components
group by comp_owner;


create view inspection_view 
as 
select by_who, count(inspection_id) as 'inspectionCount' ,avg(score) as 'averageScore'
from inspection
group by by_who;

select employees.name, employees.seniority, component_view.compCount, inspection_view.inspectionCount, inspection_view.averageScore
from employees
left join component_view on employees.id = component_view.comp_owner
left join inspection_view on employees.id = inspection_view.by_who
group by employees.id
order by employees.name, employees.seniority, component_view.compCount, inspection_view.inspectionCount, inspection_view.averageScore;









-- 7
select employees.seniority ,
CASE status
	when 'ready' then count(status)*200
	when 'not-ready' then count(status)*100
	when 'usable' then count(status)*100
end as cost
from employees
join inspection on employees.id = inspection.by_who
where DATE_FORMAT( inspection.inspection_date,  "%Y" ) = "2010"
group by employees.seniority;


-- 8 --
-- Demonstrate the adding of a new inspection by employee 10400 on Pen driver - P01 held on 8/15/2017 with the score of 60 and description of “needs rework, introduced new errors”. --
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(13, "Pen Driver", "P01", 08/15/2017, 10400, 60, "needs rework, introduced new errors");


-- 9 A --
-- Demonstrate adding a new component to Excel 2018beta. This new component is named “Dynamic Table Interface”, version D01, and was written in javascript by person 10400, size = 775 --
insert into programming_language values('JavaScript','Current');
insert into Components(comp_id, component_name, version, component_size, prog_language, comp_owner) values(9, 'Dynamic Table Interface', 'D01', 775, 'JavaScript', 10400);


-- 9B --
select * from software_products where software_products.name like 'Excel' and software_products.version like '2018beta';


-- 10 A --
-- Demonstrate the adding of an inspection on the component you just added. This inspection occurred on 11/20/2017 by inspector 10500, with a score of 80, and note of “minor fixes needed”.  --
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(14, "Dynamic Table Interface", "D01", 11/20/2017, 10500, 80, "minor fixes needed");
/*
insert into inspection(inspection_id, component_name, version, inspection_date, by_who, score, description) values(15, "Dynamic Table Interface", "D01", 11/20/2017, 11000, 80, "minor fixes needed");
delete from Inspection where by_who = 11000;
*/
-- 10 B --
select * from software_products where software_products.name like 'Excel' and software_products.version like '2018beta';


-- 11 --

delete from employees where id = 10700;
-- delete from employees where id = 10400;




select * from inspection;
select * from components_in_software_products;
select * from components;
select * from employees;
select * from software_products;
select * from programming_language;
select * from employeeLeftInformation;



