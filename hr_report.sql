create database human_resources;
use human_resources;
select * from hr;
describe hr;

select birthdate from hr;
update hr
set birthdate = case
	when birthdate like '%/%' then  date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then  date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

alter table hr
modify column birthdate date;

update hr
set hire_date=case
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
	else null
end;

alter table hr
modify column hire_date date;

select termdate from hr;
update hr
set termdate=date(str_to_date(termdate,'%Y-%m-%d%H:%i:%s UTC'))
where termdate is not null and termdate!='';

alter table hr
modify column termdate date;

alter table hr
add column age int;

update hr
set age= timestampdiff(year,birthdate,curdate());

select birthdate,age from hr;

select 
min(age) as youngest,
max(age) as oldest
from hr;

select age from hr
order by age;

#qustions

#Q-Gender breakdown of the company

select gender,count(*) as count from hr
where termdate=''
group by gender;

#Q-race breakdown of the company

select race,count(*) as count from hr
where termdate=''
group by race
order by count(*) desc;

#Q-what is the age distribution of the employees in the company

select
	case
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
	end as age_group
    ,count(*) as count from hr
	where termdate=''
    group by age_group
	order by age_group;

#Q- age-group by gender

select 
	case
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
	end as age_group
    ,gender as gender,count(*) as count from hr
    where termdate=''
    group by age_group,gender
    order by age_group,gender;

#Q-workers at headquarters and at remote areas

select location,count(*) as count from hr
where termdate=''
group by location;

#Q-what is the average length of employment of the workers who have been terminated

select round(avg(datediff(termdate,hire_date))/365,0) as avg_employment_time
from hr
where termdate <= curdate();

#Q-gender distribution vary across departments and job titles

select
	department,gender,count(*) as count from hr
    where termdate=''
    group by department,gender
    order by department;

#Q-what is the distribution of job titles across the company

select jobtitle,count(*) as count from hr
where termdate=''
group by jobtitle
order by jobtitle desc;

#Q-which department has the highest turnover rate

select department,
	total_count,
    terminated_count,
    terminated_count/total_count as termination_rate
from(
	select department,
    count(*) as total_count,
    sum(case when termdate <= curdate() then 1 else 0 end) as terminated_count
    from hr
    where age>=18
    group by department
    )as subquery
order by termination_rate desc;

#Q-what is the distribution of employees across locations by ciry and state?

select location_city,location_state,count(*) as count
from hr
where termdate=''
group by location_city,location_state;

#Q-how has the company's employee count changed over time based on hire and term rates

select 
	year,
    hirings,
    terminations,
    hirings-terminations as net_hiring,
    round((hirings-terminations)/hirings*100,2) as net_hiring_percentage
from(
	select 
		year(hire_date) as year,
        count(*) as hirings,
        sum(case when termdate <> '' and termdate <= curdate() then 1 else 0 end) as terminations
        from hr
        where age>=18
        group by year(hire_date)
	)as subquery
order by year asc;
        
select * from hr;



