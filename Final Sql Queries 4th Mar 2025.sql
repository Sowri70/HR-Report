SELECT * FROM humanresource.hrdata;
-- 1. What is the gender breakdown of employees in the company?
            SELECT gender, COUNT(*) as COUNT
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY gender;
            
-- 2. What is the race/ethnicity breakdown of employees in the company?
            SELECT race, COUNT(*) as COUNT
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY race;

-- 3. What is the age distribution of employees in the company?
            SELECT
                CASE 
                    WHEN age between 18 AND 24 then '18-24'
                    WHEN age between 25 AND 34 then '25-34'
                    WHEN age between 35 AND 44 then '35-44'
                    WHEN age between 45 AND 54 then '45-54'
                    WHEN age between 55 AND 64 then '55-64'
                    WHEN age >= 65 then '65+'
                END as age_group,
                gender, 
                COUNT(*) as count
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY age_group, gender
            ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?

            SELECT location, COUNT(*) as count
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY location;


-- 5. What is the average length of employment for employees who have been terminated?
           
            SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) as avg_length_of_employment
            FROM hrdata
            WHERE termdate <=curdate() and termdate is NOT NULL and age >=10;

-- 6. How does the gender distribution vary across departments and job titles?

            SELECT department, jobtitle, gender, COUNT(*) as count
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY gender, department, jobtitle
            ORDER BY department;

-- 7. What is the distribution of job titles across the company?

            SELECT jobtitle, COUNT(*) as count
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY jobtitle
            ORDER BY count DESC;

-- 8. Which department has the highest turnover rate?
    
            SELECT department, 
            total_count, 
            terminated_count,
            ROUND(terminated_count/total_count*100, 2) as turnover_rate
            FROM (
            SELECT department, 
                   COUNT(*) AS total_count,
                   SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated_count    
                   FROM hrdata
            WHERE age >= 18 
            GROUP BY department
            ) AS subquery
            ORDER BY terminated_count;

-- 9. What is the distribution of employees across locations by city and state?

            SELECT location_city, location_state, 
            COUNT(*) as count
            FROM hrdata
            WHERE age >=18 and termdate is NULL
            GROUP BY location_city, location_state
            ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations)/hires*100,2) AS net_change_percent
FROM(
	SELECT
    YEAR(hire_date) AS year,
    COUNT(*) as hires,
    SUM(CASE WHEN termdate <= curdate() AND termdate IS not NULL THEN 1 ELSE 0 END) AS terminations
    FROM hrdata
    WHERE age >= 18
    GROUP BY year(hire_date)
    ) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
            SELECT department, 
                    CASE 
                        WHEN DATEDIFF(CURDATE(), hire_date) < 365 THEN '<1 year'
                        WHEN DATEDIFF(CURDATE(), hire_date) BETWEEN 365 AND 730 THEN '1-2 years'
                        WHEN DATEDIFF(CURDATE(), hire_date) BETWEEN 731 AND 1095 THEN '2-3 years'
                        WHEN DATEDIFF(CURDATE(), hire_date) BETWEEN 1096 AND 1460 THEN '3-4 years'
                        WHEN DATEDIFF(CURDATE(), hire_date) BETWEEN 1461 AND 1825 THEN '4-5 years'
                        ELSE '5+ years'
                    END as tenure_group,
                    COUNT(*) as count
                FROM hrdata
                WHERE age >=18 and termdate is NULL
                GROUP BY department, tenure_group
                ORDER BY department, tenure_group;