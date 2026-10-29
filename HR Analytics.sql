create database hr_analytics;
use hr_analytics;
select database();
use hr_analytics;
select count(*) as total_rows from hr_employee_raw;
select*from hr_employee_raw limit 10;
select count(*) as total_rows,count(distinct Age,attrition,businesstravel,dailyrate,department,distancefromhome,education,educationfield) as distinct_rows from hr_employee_raw;
describe hr_employee_raw;
alter table hr_employee_raw change column `ï»¿Age` Age int;
describe hr_employee_raw;
select sum(Age is null)as missing_age,sum(Attrition is null)as missing_attrition,sum(Department is null)as missing_department,sum(DailyRate is null)as missing_daily_rate from hr_employee_raw;
use hr_analytics;
create table hr_employee_clean as select*from hr_employee_raw;
select count(*) as total_employees from hr_employee_clean;
select count(*) as total_rows,count(distinct Age,Attrition,BusinessTravel,DailyRate,Department,DistanceFromHome,Education,EducationField)as distinct_combinations from hr_employee_clean;
select sum(Age is null) as missing_age,sum(Attrition is null) as missing_attrition,sum(Department is null) as missing_department,sum(DailyRate is null) as missing_daily_rate from hr_employee_clean;
describe hr_employee_clean;
select count(*)as total_rows,count(*)-count(distinct MD5(concat_ws('|',Age,Attrition,BusinessTravel,DailyRate,Department,DistanceFromHome,Education,EducationField)))as possible_duplicates from hr_employee_clean;
select attrition,count(*)as employee_count from hr_employee_clean group by attrition;
select department,count(*)as total_employees from hr_employee_clean group by department order by total_employees desc;
select count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left,round(sum(case when attrition='Yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean;
select department,count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left,round(sum(case when attrition='Yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean group by department order by attrition_rate desc;
select attrition,count(*)as employee_count,round(avg(monthlyincome),2)as avg_monthly_income from hr_employee_clean group by attrition;
select case when age<25 then 'Below 25' when age between 25 and 34 then '25-34' when age between 35 and 44 then '35-44' when age between 45 and 54 then '45-54' else '55 and above' end as age_group,count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left,round(sum(case when attrition='Yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean group by age_group order by attrition_rate desc;
select overtime,count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left,round(sum(case when attrition='Yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean group by overtime order by attrition_rate desc;
select jobsatisfaction,count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left from hr_employee_clean group by jobsatisfaction order by jobsatisfaction;
select jobrole,count(*)as total_employees,sum(case when attrition='Yes' then 1 else 0 end)as employees_left,round(100.0*sum(case when attrition='Yes' then 1 else 0 end)/count(*),2)as attrition_rate_pct from hr_employee_clean group by jobrole order by attrition_rate_pct desc;
select count(*)as final_employee_count from hr_employee_clean;
select attrition,count(*) as employee_count from hr_employee_clean group by attrition;
use hr_analytics;
create table department_details(Department varchar(100)primary key,DepartmentHead varchar(100),Location varchar(100));
insert into department_details values('Sales','Manager A','Chennai'),('Research & Development','Manager B','Bengaluru'),('Human Resources','Manager C','Chennai');
select e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome,d.DepartmentHead,d.Location from hr_employee_clean as e inner join department_details as d on e.Department=d.Department;
select e.EmployeeNumber,e.Department,d.DepartmentHead,d.Location from hr_employee_clean as e left join department_details as d on e.Department=d.Department;
select e.EmployeeNumber,e.Department,e.JobRole,d.DepartmentHead,d.Location from hr_employee_clean as e right join department_details as d on e.Department=d.Department;
select e1.EmployeeNumber as employee_1,e1.Department,e2.EmployeeNumber as employee_2 from hr_employee_clean as e1 inner join hr_employee_clean as e2 on e1.Department=e2.Department and e1.EmployeeNumber<e2.EmployeeNumber limit 20;
select EmployeeNumber,Department,JobRole,MonthlyIncome from hr_employee_clean where MonthlyIncome>(select avg(MonthlyIncome) from hr_employee_clean);
select e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome from hr_employee_clean as e where e.MonthlyIncome>(select avg(e2.MonthlyIncome)from hr_employee_clean as e2 where e2.Department=e.Department);
select EmployeeNumber,Department,JobRole,MonthlyIncome from hr_employee_clean where MonthlyIncome=(select max(MonthlyIncome)from hr_employee_clean);
with department_salary as(select Department,avg(MonthlyIncome)as avg_salary from hr_employee_clean group by Department)select Department,Round(avg_salary,2)as average_salary from department_salary order by avg_salary desc;
select EmployeeNumber,Department,JobRole,MonthlyIncome,row_number()over(partition by Department order by MonthlyIncome desc)as salary_row_number from hr_employee_clean;
select EmployeeNumber,Department,JobRole,MonthlyIncome,rank()over(partition by Department order by MonthlyIncome desc)as salary_rank from hr_employee_clean;
select EmployeeNumber,Department,JobRole,MonthlyIncome,dense_rank()over(partition by Department order by MonthlyIncome desc)as salary_rank from hr_employee_clean;
select EmployeeNumber,Department,MonthlyIncome,lag(MonthlyIncome)over(partition by department order by EmployeeNumber)as previous_salary,MonthlyIncome-lag(MonthlyIncome)over(partition by department order by EmployeeNumber)as salary_difference from hr_employee_clean;
create or replace view vw_department_attrition as select department,count(*)as total_employees,sum(attrition='Yes')as employees_left,round(100.0*sum(attrition='Yes')/count(*),2)as attrition_rate from hr_employee_clean group by department;
select*from vw_department_attrition order by attrition_rate desc;
show index from hr_employee_clean;
describe hr_employee_clean;
alter table hr_employee_clean modify department varchar(100);
create index idx_hr_department on hr_employee_clean(department);
show index from hr_employee_clean;
select EmployeeNumber,Department,MonthlyIncome,case when MonthlyIncome>=10000 then 'High Salary' when MonthlyIncome>=5000 then 'Medium Salary' else 'Low Salary' end as salary_category from hr_employee_clean;
select EmployeeNumber,Department,MonthlyIncome,if(MonthlyIncome>=5000,'above 5000','below 5000')as salary_status from hr_employee_clean;
select e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome from hr_employee_clean e where exists(select 1 from hr_employee_clean x where x.Department=e.Department and x.MonthlyIncome>10000);
select EmployeeNumber,Department,'High salary' as salary_category from hr_employee_clean where MonthlyIncome>=10000 union select EmployeeNumber,Department,'Low Salary' as salary_category from hr_employee_clean where MonthlyIncome<5000;
select Department,count(*)as total_employees,round(avg(MonthlyIncome),2)as avg_salary from hr_employee_clean group by Department having count(*)>50 order by total_employees desc;
select distinct department from hr_employee_clean;
select distinct JobRole from hr_employee_clean;
select distinct department,JobRole from hr_employee_clean order by Department,JobRole;
DELIMITER //
create procedure GetDepartmentSummary()
begin 
   select Department,count(*) as total_employees,round(avg(MonthlyIncome),2)as avg_salary from hr_employee_clean group by Department order by total_employees desc; 
END //
DELIMITER ;
call GetDepartmentSummary();
DELIMITER //
create procedure GetEmployeesByDepartment(in dept_name varchar(100))
begin
    select employeeNumber,Department,JobRole,MonthlyIncome,Attrition from hr_employee_clean where department=dept_name;
END //
DELIMITER ;
call GetEmployeesByDepartment('Sales');
DELIMITER //
create function GetSalaryCategory(salary decimal(10,2)) returns varchar(20) deterministic
begin
   if salary>=10000 then return 'High Salary';
   elseif salary>=5000 then return 'Medium Salary';
   else return 'Low Salary';
   end if;
END //
DELIMITER ;
select GetSalaryCategory(12000)as salary_category;
select EmployeeNumber,Department,MonthlyIncome,GetSalaryCategory(MonthlyIncome)as salary_category from hr_employee_clean limit 10;
use hr_analytics;
create table if not exists hr_employee_audit(audit_id int auto_increment primary key,employee_id int,action_type varchar(20),action_time timestamp default current_timestamp);
DELIMITER //
create trigger trg_employee_update after update on hr_employee_clean for each row
begin
    insert into hr_employee_audit(employee_id,action_type)values(new.EmployeeNumber,'update');
END //
DELIMITER ;
select EmployeeNumber,Department from hr_employee_clean limit 5;
show triggers from hr_analytics;
DELIMITER //
create trigger trg_validate_salary before update on hr_employee_clean for each row
begin
    if new.MonthlyIncome<0 then signal sqlstate '45000' set message_text='Monthly income cannot be negative';
    end if;
END //
DELIMITER ;
use hr_analytics;
DELIMITER //
create trigger trg_employee_insert after insert on hr_employee_clean for each row
begin
   insert into hr_employee_audit(employee_id,action_type)values(new.EmployeeNumber,'Insert');
END //
DELIMITER ;
select*from hr_employee_audit;
DELIMITER //
create trigger trg_employee_delete after delete on hr_employee_clean for each row
begin
   insert into hr_employee_audit(employee_id,action_type)values(old.EmployeeNumber,'delete');
END //
DELIMITER ;
select*from hr_employee_audit order by audit_id desc;
DELIMITER //
create trigger trg_before_employee_insert before insert on hr_employee_clean for each row
begin
    if new.MonthlyIncome<0 then signal sqlstate '45000' set message_text='Monthly income cannot be negative';
    end if;
END //
DELIMITER ;
DELIMITER //
create trigger trg_before_employee_delete before delete on hr_employee_clean for each row
begin
   insert into hr_employee_audit(employee_id,action_type)values(old.EmployeeNumber,'before delete');
END //
DELIMITER ;
create table if not exists transaction_practice(id int primary key,employee_name varchar(50),salary decimal(10,2));
insert ignore into transaction_practice values(1,'Test Employee',5000);
select*from transaction_practice;
start transaction;
update transaction_practice set salary=6000 where id=1;
select*from transaction_practice;
rollback;
select*from transaction_practice;
update transaction_practice set salary=7000 where id=1;
commit;
select*from transaction_practice;
DELIMITER //
create procedure TestErrorHandling()
begin
   declare continue handler for sqlexception select 'An error occured' as error_message;
   select 10/2 as result;
END //
DELIMITER ;
call TestErrorHandling();
DELIMITER //
create procedure TestErrorHandling()
begin
   declare continue handler for sqlexception select 'Error handled successfully' as message;
   insert into transaction_practice(id,employee_name,salary)values(1,'Duplicate Test',9000);
   select 'Procedure continued' as status;
END //
DELIMITER ;
call TestErrorHandler();
DELIMITER //
create procedure TestExitHandler()
begin
   select 'Error handled;procedure stopped' as message;
   END;
   insert into transaction_practice(id,employee_name,salary)values(1,'Duplicate Test',9000);
   select 'This statement will not run' as status;
END //
DELIMITER ;
call TestExitHandler();
use hr_analytics;
show tables;
select count(*)as total_employees from hr_employee_clean;
select*from hr_employee_clean limit 10;
select Department,count(*)as total_employees,round(avg(MonthlyIncome),2)as avg_salary,sum(case when attrition='Yes' then 1 else 0 end)as employee_left from hr_employee_clean group by Department order by employee_left desc;
explain select*from hr_employee_clean where Department='Sales';