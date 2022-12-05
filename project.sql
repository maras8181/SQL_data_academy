/*** TABLES ***/

/* PRIMARY TABLE */

CREATE OR REPLACE TABLE t_martin_mrazek_project_SQL_primary_final AS 
(SELECT 
	cpri.id AS cprice_id,
	cpri.value AS cprice_value,
	cpri.category_code,
	cpri.date_from,
	cpri.date_to,
	MONTH(cpri.date_from) AS entry_month,
	YEAR(cpri.date_from) AS entry_year,
	cpri.region_code,
	cpc.code AS cpc_code, 
	cpc.name AS cpc_name,
	cpc.price_value,
	cpc.price_unit,
	cpay.id AS cpayroll_id,
	cpay.value AS cpayroll_value,
	cpay.value_type_code,
	cpay.unit_code,
	cpay.calculation_code,
	cpay.industry_branch_code,
	cpay.payroll_year,
	cpay.payroll_quarter,
	cpib.code AS cpib_code,
	cpib.name AS cpib_name
FROM czechia_price cpri
JOIN czechia_price_category cpc
	ON cpri.category_code = cpc.code 
JOIN czechia_payroll cpay 
	ON YEAR(cpri.date_from) = cpay.payroll_year
JOIN czechia_payroll_industry_branch cpib 
	ON cpay.industry_branch_code = cpib.code
WHERE cpay.value_type_code = 5958);

/* SECONDARY TABLE */ 

CREATE OR REPLACE TABLE t_martin_mrazek_project_SQL_secondary_final AS 
(SELECT 
	c.country,
	c.continent,
	e.YEAR,
	e.population,
	e.GDP,
	e.gini
FROM countries c 
JOIN economies e 
	ON c.country = e.country
WHERE c.continent = 'Europe'
AND e.YEAR BETWEEN 2006 AND 2018);

/* INDEXES */

CREATE OR REPLACE INDEX i_category_code ON t_martin_mrazek_project_SQL_primary_final(category_code);
CREATE OR REPLACE INDEX i_date_from_month ON t_martin_mrazek_project_SQL_primary_final(entry_month); 
CREATE OR REPLACE INDEX i_date_from_year ON t_martin_mrazek_project_SQL_primary_final(entry_year); 
CREATE OR REPLACE INDEX i_industry_branch_code ON t_martin_mrazek_project_SQL_primary_final(industry_branch_code); 
CREATE OR REPLACE INDEX i_payroll_year ON t_martin_mrazek_project_SQL_primary_final(payroll_year); 
CREATE OR REPLACE INDEX i_payroll_quarter ON t_martin_mrazek_project_SQL_primary_final(payroll_quarter);

/*** QUESTIONS TO BE WORKED OUT (WITH VIEWS) ***/

/* 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? */

/* Question 1 (FINAL QUERY) */

SELECT 
	rt.name, 
	rt.avg_value, 
	LAG(rt.avg_value) 
		OVER (PARTITION BY rt.name 
			ORDER BY rt.name, rt.payroll_year) AS prev_year_avg_value, 
	CASE
		WHEN LAG(rt.avg_value) 
			OVER (PARTITION BY rt.name 
				ORDER BY rt.name, rt.payroll_year) <= rt.avg_value THEN 'increase'
		WHEN LAG(rt.avg_value) 
			OVER (PARTITION BY rt.name 
				ORDER BY rt.name, rt.payroll_year) > rt.avg_value THEN 'decrease' 
	END AS salary_status, 
	rt.payroll_year 
FROM 
	(SELECT 
		pf.cpib_name AS name, 
		AVG(pf.cpayroll_value) AS avg_value, 
		pf.payroll_year 
	FROM t_martin_mrazek_project_sql_primary_final pf 
	GROUP BY pf.cpib_name, pf.payroll_year) AS rt;
	
/* 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? */

/* Question 2 (VIEW 1) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_prices AS 
(SELECT
	pf.category_code,
	pf.cpc_name AS name,
	ROUND(AVG(pf.cprice_value), 2) AS avg_value_in_period,
	pf.date_from,
	pf.date_to,
	pf.price_value,
	pf.price_unit
FROM t_martin_mrazek_project_sql_primary_final pf
WHERE pf.date_from IN ('2006-01-02', '2018-12-10')
	AND pf.category_code IN (111301, 114201)
GROUP BY pf.category_code, pf.date_from);

/* Question 2 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_wages AS 
(SELECT 
	pf.cpayroll_id,
	ROUND(AVG(pf.cpayroll_value), 2) AS avg_wage_in_period,
	pf.date_from
FROM t_martin_mrazek_project_sql_primary_final pf
WHERE pf.date_from = '2006-01-02' AND pf.payroll_quarter = 1
	OR pf.date_from = '2018-12-10' AND pf.payroll_quarter = 4
GROUP BY pf.date_from);

/* Question 2 (FINAL QUERY) */

SELECT 
	vmmt2ap.category_code,
	vmmt2ap.name,
	vmmt2ap.avg_value_in_period,
	vmmt2aw.avg_wage_in_period,
	ROUND((vmmt2aw.avg_wage_in_period / vmmt2ap.avg_value_in_period), 2) AS can_be_purchased,
	vmmt2ap.date_from,
	vmmt2ap.date_to,
	vmmt2ap.price_value,
	vmmt2ap.price_unit
FROM v_martin_mrazek_task_2_avg_prices vmmt2ap
JOIN v_martin_mrazek_task_2_avg_wages vmmt2aw
	ON vmmt2ap.date_from = vmmt2aw.date_from;
		
/* 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? */
	
/* Question 3 (FINAL QUERY) */

SELECT 
	rt2.category_code,
	rt2.name,
	CONCAT(ROUND(AVG(rt2.year_on_year_increase), 2), ' %') AS year_on_year_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt1.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE ((avg_value_in_year - rt1.avg_value_in_year_prev_row) / rt1.avg_value_in_year_prev_row) * 100
		END AS year_on_year_increase	
	FROM
		(SELECT 
			pf.category_code,
			pf.cpc_name AS name,
			AVG(pf.cprice_value) AS avg_value_in_year,
			LAG(AVG(pf.cprice_value))
				OVER (PARTITION BY pf.category_code
					ORDER BY pf.category_code, pf.entry_year) AS avg_value_in_year_prev_row,
			pf.entry_month,
			pf.entry_year
		FROM t_martin_mrazek_project_SQL_primary_final pf
		GROUP BY pf.category_code, pf.entry_year) AS rt1) AS rt2
GROUP BY rt2.category_code
ORDER BY ROUND(AVG(rt2.year_on_year_increase), 2)
LIMIT 1;

/* 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? */

/* Question 4 (FINAL QUERY) */

SELECT 
	rt3.entry_year AS YEAR,
	ROUND((rt3.avg_value_in_year), 2) AS avg_price_value_in_year,
	CONCAT(ROUND((rt3.year_on_year_percentage), 2), ' %') AS price_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt2.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE ((rt2.avg_value_in_year - rt2.avg_value_in_year_prev_row) / rt2.avg_value_in_year_prev_row) * 100
		END AS year_on_year_percentage
	FROM
		(SELECT 
			rt1.entry_year,
			AVG(rt1.avg_value_in_year) AS avg_value_in_year,
			AVG(rt1.avg_value_in_year_prev_row) AS avg_value_in_year_prev_row
		FROM
			(SELECT
				pf.category_code,
				pf.cpc_name AS name,
				AVG(pf.cprice_value) AS avg_value_in_year,
				LAG(AVG(pf.cprice_value))
					OVER (PARTITION BY pf.category_code 
						ORDER BY pf.entry_year) AS avg_value_in_year_prev_row,
				pf.entry_month,
				pf.entry_year 
			FROM t_martin_mrazek_project_sql_primary_final pf
			GROUP BY pf.category_code, pf.entry_year) AS rt1
		GROUP BY rt1.entry_year) AS rt2) AS rt3;
		
/* 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
  ve stejném nebo násdujícím roce výraznějším růstem? */
	
/* Question 5 (VIEW 1) */
	
CREATE OR REPLACE VIEW v_martin_mrazek_task_5_gdp AS 
(SELECT 
	rt2.YEAR,
	rt2.avg_gdp,
	CONCAT(ROUND((rt2.gdp_year_percentage), 2), ' %') AS gdp_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt1.avg_gdp_prev_row IS NULL THEN 0
			ELSE ((rt1.avg_gdp - rt1.avg_gdp_prev_row) / rt1.avg_gdp_prev_row) * 100
		END AS gdp_year_percentage
	FROM
		(SELECT 
			sf.YEAR,
			AVG(sf.gdp) AS avg_gdp,
			LAG(AVG(sf.gdp))
				OVER (PARTITION BY sf.country 
					ORDER BY sf.country, sf.year) AS avg_gdp_prev_row
		FROM t_martin_mrazek_project_sql_secondary_final sf
		GROUP BY sf.YEAR) AS rt1) AS rt2);
	
/* Question 5 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_prices AS 
(SELECT 
	rt3.entry_year,
	ROUND((rt3.avg_value_in_year), 2) AS avg_price_value_in_year,
	CONCAT(ROUND((rt3.year_on_year_percentage), 2), ' %') AS price_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt2.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE ((rt2.avg_value_in_year - rt2.avg_value_in_year_prev_row) / rt2.avg_value_in_year_prev_row) * 100
		END AS year_on_year_percentage
	FROM
		(SELECT 
			rt1.entry_year,
			AVG(rt1.avg_value_in_year) AS avg_value_in_year,
			AVG(rt1.avg_value_in_year_prev_row) AS avg_value_in_year_prev_row
		FROM
			(SELECT
				pf.category_code,
				pf.cpc_name AS name,
				AVG(pf.cprice_value) AS avg_value_in_year,
				LAG(AVG(pf.cprice_value))
					OVER (PARTITION BY pf.category_code 
						ORDER BY pf.entry_year) AS avg_value_in_year_prev_row,
				pf.entry_month,
				pf.entry_year 
			FROM t_martin_mrazek_project_sql_primary_final pf
			GROUP BY pf.category_code, pf.entry_year) AS rt1
		GROUP BY rt1.entry_year) AS rt2) AS rt3);

/* Question 5 (VIEW 3) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_wages AS 
(SELECT 
	rt3.payroll_year,
	ROUND((rt3.avg_wage_in_year), 2) AS avg_wage_in_year,
	CONCAT(ROUND((rt3.wage_percentage_increase), 2), ' %') AS wage_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt2.avg_wage_in_year_prev_row IS NULL THEN 0
			ELSE ((rt2.avg_wage_in_year - rt2.avg_wage_in_year_prev_row) / rt2.avg_wage_in_year_prev_row) * 100
		END AS wage_percentage_increase
	FROM	
		(SELECT
			rt1.payroll_year,
			AVG(rt1.avg_wage_in_year) AS avg_wage_in_year,
			AVG(rt1.avg_wage_in_year_prev_row) AS avg_wage_in_year_prev_row
		FROM 
			(SELECT
				pf.cpib_name,
				pf.payroll_year,
				AVG(pf.cpayroll_value) AS avg_wage_in_year,
				LAG(AVG(pf.cpayroll_value))
					OVER (PARTITION BY pf.cpib_name 
						ORDER BY pf.payroll_year) AS avg_wage_in_year_prev_row
			FROM t_martin_mrazek_project_sql_primary_final pf
			GROUP BY pf.cpib_name, pf.payroll_year) AS rt1
		GROUP BY rt1.payroll_year) AS rt2) AS rt3);

/* Question 5 (FINAL QUERY) */
		
SELECT 
	vmmt5g.*,
	vmmt5p.avg_price_value_in_year,
	vmmt5p.price_year_percentage_increase,
	vmmt5w.avg_wage_in_year,
	vmmt5w.wage_year_percentage_increase 
FROM v_martin_mrazek_task_5_gdp vmmt5g
JOIN v_martin_mrazek_task_5_prices vmmt5p
	ON vmmt5g.YEAR = vmmt5p.entry_year
JOIN v_martin_mrazek_task_5_wages vmmt5w
	ON vmmt5g.YEAR = vmmt5w.payroll_year;