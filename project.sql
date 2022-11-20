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
AND e.YEAR IN
	(SELECT 
		DISTINCT tmm.entry_year
	FROM t_martin_mrazek_project_sql_primary_final tmm
	ORDER BY tmm.entry_year));

/* INDEXES */

CREATE OR REPLACE INDEX i_category_code ON t_martin_mrazek_project_SQL_primary_final(category_code);
CREATE OR REPLACE INDEX i_date_from_month ON t_martin_mrazek_project_SQL_primary_final(entry_month); 
CREATE OR REPLACE INDEX i_date_from_year ON t_martin_mrazek_project_SQL_primary_final(entry_year); 
CREATE OR REPLACE INDEX i_industry_branch_code ON t_martin_mrazek_project_SQL_primary_final(industry_branch_code); 
CREATE OR REPLACE INDEX i_payroll_year ON t_martin_mrazek_project_SQL_primary_final(payroll_year); 
CREATE OR REPLACE INDEX i_payroll_quarter ON t_martin_mrazek_project_SQL_primary_final(payroll_quarter);

/*** QUESTIONS TO BE WORKED OUT (WITH VIEWS) ***/

/* 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? */

/* Question 1 (VIEW 1) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_1 AS 
(SELECT 
	DISTINCT tmm.cpayroll_id,
	tmm.industry_branch_code,
	tmm.cpib_name,
	tmm.cpayroll_value,
	tmm.payroll_year,
	tmm.payroll_quarter
FROM t_martin_mrazek_project_sql_primary_final tmm
ORDER BY tmm.industry_branch_code, tmm.payroll_year);

/* Question 1 (FINAL QUERY) */

SELECT 
	rt3.industry_branch_code,
	rt3.cpib_name AS name,
	rt3.avg_wages_in_period_2006_2012,
	rt3.avg_wages_in_period_2012_2018,
	CASE 
		WHEN rt3.avg_wages_in_period_2006_2012 < rt3.avg_wages_in_period_2012_2018
			THEN "The wages are raising"
		ELSE "The wages are falling"
	END AS result_of_wages	
FROM 
	(SELECT 
		rt2.industry_branch_code,
		lag(rt2.industry_branch_code) 
			OVER (ORDER BY rt2.industry_branch_code, rt2.time_range) AS industry_branch_code_prev_row,
		rt2.cpib_name,
		round(avg(rt2.avg_value), 2) AS avg_wages_in_period_2012_2018,
		lag(round(avg(rt2.avg_value), 2)) 
			OVER (ORDER BY rt2.industry_branch_code, rt2.time_range) AS avg_wages_in_period_2006_2012
	FROM 
		(SELECT 
			*,
			CASE 
				WHEN rt1.industry_branch_code = rt1.industry_branch_code_prev_row
					THEN rt1.avg_value_in_year_quarter
				ELSE 0
			END AS avg_value,
			CASE 
				WHEN rt1.payroll_year < 2012 THEN "2006-2012"
				WHEN rt1.payroll_year = 2012 AND rt1.payroll_quarter IN (1,2) THEN "2006-2012"
				ELSE "2012-2018"
			END AS time_range
		FROM 
			(SELECT 
				vmmt1.industry_branch_code,
				lag(vmmt1.industry_branch_code)
					OVER (ORDER BY vmmt1.industry_branch_code, vmmt1.payroll_year, vmmt1.payroll_quarter) AS industry_branch_code_prev_row,
				vmmt1.cpib_name,
				avg(vmmt1.cpayroll_value) AS avg_value_in_year_quarter,
				lag(avg(vmmt1.cpayroll_value)) 
					OVER (ORDER BY vmmt1.industry_branch_code, vmmt1.payroll_year, vmmt1.payroll_quarter) AS avg_value_in_year_quarter_prev_row,
				vmmt1.payroll_year,
				vmmt1.payroll_quarter
			FROM v_martin_mrazek_task_1 vmmt1
		GROUP BY vmmt1.industry_branch_code, vmmt1.payroll_year, vmmt1.payroll_quarter) AS rt1) AS rt2
		GROUP BY rt2.industry_branch_code, rt2.time_range) AS rt3
	WHERE rt3.industry_branch_code = rt3.industry_branch_code_prev_row;
	
/* 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? */

/* Question 2 (VIEW 1) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_prices AS 
(SELECT 
	rt1.category_code,
	rt1.cpc_name AS name,
	round(avg(cprice_value), 2) AS avg_value_in_period,
	rt1.date_from,
	rt1.date_to,
	rt1.price_value,
	rt1.price_unit
FROM 
	(SELECT 
		DISTINCT tmm2.cprice_id,
		tmm2.category_code,
		tmm2.cpc_name,
		tmm2.cprice_value,
		tmm2.date_from,
		tmm2.date_to,
		tmm2.price_value,
		tmm2.price_unit,
		tmm2.payroll_year,
		tmm2.payroll_quarter
	FROM t_martin_mrazek_project_sql_primary_final tmm2
	WHERE tmm2.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from 
		LIMIT 1
	)
	AND tmm2.payroll_quarter = (
		SELECT 
			tmm.payroll_quarter 
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.payroll_quarter
		LIMIT 1
	)
	OR tmm2.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from DESC
		LIMIT 1 )
	AND tmm2.payroll_quarter = (
		SELECT 
			tmm.payroll_quarter 
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.payroll_quarter DESC 
		LIMIT 1)) AS rt1
	WHERE rt1.category_code IN (111301, 114201)
GROUP BY rt1.category_code, rt1.date_from);

/* Question 2 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_wages AS 
(SELECT 
	rt1.date_from AS first_last_period,
	round(avg(rt1.cpayroll_value), 2) AS avg_wage_in_period,
	rt1.payroll_year
FROM 
	(SELECT 
		DISTINCT tmm2.cpayroll_id,
		tmm2.industry_branch_code,
		tmm2.cpib_name,
		tmm2.cpayroll_value,
		tmm2.date_from,
		tmm2.payroll_year,
		tmm2.payroll_quarter
	FROM t_martin_mrazek_project_sql_primary_final tmm2
	WHERE tmm2.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from 
		LIMIT 1
	)
	AND tmm2.payroll_quarter = (
		SELECT 
			tmm.payroll_quarter 
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.payroll_quarter
		LIMIT 1
	)
	OR tmm2.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from DESC
		LIMIT 1 )
	AND tmm2.payroll_quarter = (
		SELECT 
			tmm.payroll_quarter 
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.payroll_quarter DESC 
		LIMIT 1)
	ORDER BY tmm2.industry_branch_code, tmm2.payroll_year) AS rt1
GROUP BY rt1.date_from);

/* Question 2 (FINAL QUERY) */

SELECT 
	rt1.category_code,
	rt1.name,
	rt1.avg_value_in_period,
	rt1.avg_wage_in_period,
	round((rt1.avg_wage_in_period / rt1.avg_value_in_period), 2) AS can_be_purchased,
	rt1.date_from,
	rt1.date_to,
	rt1.price_value,
	rt1.price_unit
FROM 
	(SELECT 
		*
	FROM v_martin_mrazek_task_2_avg_prices vmmt2ap
	JOIN v_martin_mrazek_task_2_avg_wages vmmt2aw 
		ON vmmt2ap.date_from = vmmt2aw.first_last_period) AS rt1;
		
/* 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? */
	
/* Question 3 (VIEW 1) */
	
CREATE OR REPLACE VIEW v_martin_mrazek_task_3 AS 
(SELECT 
	DISTINCT tmm.category_code,
	tmm.cpc_name,
	tmm.cprice_value,
	tmm.entry_month,
	tmm.entry_year
FROM t_martin_mrazek_project_SQL_primary_final tmm
ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month);

/* Question 3 (FINAL QUERY) */

SELECT 
	rt6.category_code,
	rt6.name,
	concat(rt6.year_on_year_increase, ' %') AS year_on_year_increase
FROM 
	(SELECT 
		rt5.category_code,
		rt5.name,
		round(avg(rt5.year_on_year_increase), 2) AS year_on_year_increase
	FROM 
	(SELECT 
		*,
		CASE 
			WHEN rt4.category_code = rt4.category_code_prev_row
				THEN ((rt4.avg_value_in_year - rt4.avg_value_in_year_prev_row) / rt4.avg_value_in_year_prev_row) * 100
			ELSE 0
		END year_on_year_increase
	FROM 
		(SELECT 
			rt3.category_code,
			lag(rt3.category_code) OVER
				(ORDER BY rt3.category_code, rt3.entry_year) AS category_code_prev_row,
			rt3.name,
			rt3.avg_value_in_year,
			lag(rt3.avg_value_in_year) OVER
				(ORDER BY rt3.category_code, rt3.entry_year) AS avg_value_in_year_prev_row,
			rt3.entry_year
		FROM 
			(SELECT 
				rt2.category_code,
				rt2.name,
				round(avg(rt2.avg_value_in_month), 2) AS avg_value_in_year,
				rt2.entry_year
			FROM 
				(SELECT 
					rt1.category_code,
					rt1.cpc_name AS name,
					round(avg(rt1.cprice_value), 2) AS avg_value_in_month,
					rt1.entry_month,
					rt1.entry_year
				FROM 
					(SELECT 
						*
					FROM v_martin_mrazek_task_3 vmmt3) AS rt1
				GROUP BY rt1.category_code, rt1.entry_year, rt1.entry_month
				ORDER BY rt1.category_code, rt1.entry_year, rt1.entry_month) AS rt2
		GROUP BY rt2.category_code, rt2.entry_year) AS rt3) AS rt4) AS rt5
	GROUP BY rt5.category_code) AS rt6
ORDER BY rt6.year_on_year_increase
LIMIT 1;

/* 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? */

/* Question 4 (VIEW 1) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_4 AS 
(SELECT 
	DISTINCT tmm.cprice_id,
	tmm.category_code,
	tmm.cpc_name,
	tmm.cprice_value,
	tmm.entry_month,
	tmm.entry_year 
FROM t_martin_mrazek_project_sql_primary_final tmm
ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month);

/* Question 4 (FINAL QUERY) */

SELECT 
	rt5.avg_value_in_year,
	rt5.entry_year,
	rt5.price_year_percentage,
	CASE 
		WHEN rt5.price_year_percentage_prev_row IS NULL THEN '0 %'
		ELSE concat(rt5.price_year_percentage - rt5.price_year_percentage_prev_row, ' %')
	END AS price_year_percentage_difference	
FROM 
	(SELECT 
		round((rt4.avg_value_in_year), 2) AS avg_value_in_year,
		rt4.entry_year,
		round((rt4.year_on_year_percentage), 2) AS price_year_percentage,
		lag(round((rt4.year_on_year_percentage), 2))
			OVER (ORDER BY rt4.entry_year) AS price_year_percentage_prev_row
	FROM 
		(SELECT 
			*,
			CASE 
				WHEN rt3.avg_value_in_year_prev_row IS NULL THEN 0
				ELSE ((rt3.avg_value_in_year - rt3.avg_value_in_year_prev_row) / rt3.avg_value_in_year_prev_row) * 100
			END AS year_on_year_percentage	
		FROM 
			(SELECT 
				avg(rt2.avg_value_in_year_period) AS avg_value_in_year,
				lag(avg(rt2.avg_value_in_year_period))
					OVER (ORDER BY rt2.entry_year) AS avg_value_in_year_prev_row,
				rt2.entry_year
			FROM 
				(SELECT 
					rt1.category_code,
					rt1.cpc_name AS name,
					avg(rt1.cprice_value) AS avg_value_in_year_period,
					rt1.entry_year
				FROM 
					(SELECT 
						*
					FROM v_martin_mrazek_task_4 vmmt4) AS rt1
				GROUP BY rt1.category_code, rt1.entry_year
				ORDER BY rt1.category_code, rt1.entry_year) AS rt2
			GROUP BY rt2.entry_year) AS rt3) AS rt4) AS rt5;
		
/* 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
  ve stejném nebo násdujícím roce výraznějším růstem? */
	
/* Question 5 (VIEW 1) */
	
CREATE OR REPLACE VIEW v_martin_mrazek_task_5_gdp AS 
(SELECT 
	rt4.YEAR,
	rt4.gdp_year_percentage,
	CASE 
		WHEN rt4.gdp_year_percentage_prev_row IS NULL THEN
			'0 %'
		ELSE concat(rt4.gdp_year_percentage - rt4.gdp_year_percentage_prev_row, ' %')
	END AS gdp_year_percentage_difference	
FROM 
	(SELECT 
		rt3.YEAR,
		round(avg(rt3.year_percentage), 2) AS gdp_year_percentage,
		lag(round(avg(rt3.year_percentage), 2))
			OVER (ORDER BY rt3.year) AS gdp_year_percentage_prev_row
	FROM 
		(SELECT 
			*,
			CASE 
				WHEN rt2.country = rt2.country_prev_row
					THEN ((rt2.gdp - rt2.gdp_prev_row) / rt2.gdp_prev_row) * 100
				ELSE 0
			END AS year_percentage	
		FROM 
			(SELECT 
				rt1.country,
				lag(rt1.country)
					OVER (ORDER BY rt1.country, rt1.year) AS country_prev_row,
				rt1.YEAR,
				rt1.gdp,
				lag(rt1.gdp)
					OVER (ORDER BY rt1.country, rt1.year) AS gdp_prev_row
			FROM 
				(SELECT 
					*
				FROM t_martin_mrazek_project_sql_secondary_final tmmpssf) AS rt1
			ORDER BY rt1.country, rt1.YEAR) AS rt2) AS rt3
		GROUP BY rt3.YEAR) AS rt4);
	
/* Question 5 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_prices AS 
(SELECT 
	rt5.entry_year,
	rt5.price_year_percentage,
	CASE 
		WHEN rt5.price_year_percentage_prev_row IS NULL 
			THEN concat(0, ' %')
		ELSE concat(rt5.price_year_percentage - rt5.price_year_percentage_prev_row, ' %')
	END AS price_year_percentage_difference
FROM 
	(SELECT 
		rt4.entry_year,
		round(rt4.year_percentage, 2) AS price_year_percentage,
		lag(round(rt4.year_percentage, 2))
			OVER (ORDER BY rt4.entry_year) AS price_year_percentage_prev_row
	FROM 
		(SELECT 
			*,
			CASE 
				WHEN rt3.avg_value_in_year_prev_row IS NULL THEN 0
				ELSE ((rt3.avg_value_in_year - rt3.avg_value_in_year_prev_row) / rt3.avg_value_in_year_prev_row) * 100
			END AS year_percentage	
		FROM 
			(SELECT 
				avg(rt2.avg_value_in_year_period) AS avg_value_in_year,
				lag(avg(rt2.avg_value_in_year_period))
					OVER (ORDER BY rt2.entry_year) AS avg_value_in_year_prev_row,
				rt2.entry_year
			FROM 
				(SELECT 
					rt1.category_code,
					rt1.cpc_name AS name,
					avg(rt1.cprice_value) AS avg_value_in_year_period,
					rt1.entry_year
				FROM 
					(SELECT 
						*
					FROM v_martin_mrazek_task_4 vmmt4) AS rt1
				GROUP BY rt1.category_code, rt1.entry_year
				ORDER BY rt1.category_code, rt1.entry_year) AS rt2
			GROUP BY rt2.entry_year) AS rt3) AS rt4) AS rt5);

/* Question 5 (VIEW 3) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_wages AS 
(SELECT 
	rt4.payroll_year,
	rt4.payroll_year_percentage,
	CASE 
		WHEN rt4.payroll_year_percentage_prev_row IS NULL 
			THEN '0 %'
		ELSE concat(rt4.payroll_year_percentage - rt4.payroll_year_percentage_prev_row, ' %')
	END AS payroll_year_percentage_difference	
FROM 
	(SELECT 
		rt3.payroll_year,
		round(rt3.payroll_perc_difference, 2) AS payroll_year_percentage,
		lag(round(rt3.payroll_perc_difference, 2))
			OVER (ORDER BY rt3.payroll_year) AS payroll_year_percentage_prev_row
	FROM 
		(SELECT 
			*,
			CASE 
				WHEN rt2.avg_wage_in_year_prev_row IS NULL
					THEN 0
				ELSE ((rt2.avg_wage_in_year - rt2.avg_wage_in_year_prev_row) / rt2.avg_wage_in_year_prev_row) * 100
			END AS payroll_perc_difference
		FROM 
			(SELECT 
				rt1.payroll_year,
				round(avg(rt1.cpayroll_value), 2) AS avg_wage_in_year,
				lag(round(avg(rt1.cpayroll_value), 2))
					OVER (ORDER BY rt1.payroll_year) AS avg_wage_in_year_prev_row
			FROM 
				(SELECT 
					*
				FROM v_martin_mrazek_task_1 vmmt) AS rt1
			GROUP BY rt1.payroll_year) AS rt2) AS rt3) AS rt4);

/* Question 5 (FINAL QUERY) */
		
SELECT 
	rt1.YEAR,
	rt1.gdp_year_percentage,
	rt1.gdp_year_percentage_difference,
	rt1.price_year_percentage,
	rt1.price_year_percentage_difference,
	rt1.payroll_year_percentage,
	rt1.payroll_year_percentage_difference
FROM
	(SELECT 
		*
	FROM v_martin_mrazek_task_5_gdp vmmt5g
	JOIN v_martin_mrazek_task_5_prices vmmt5p
		ON vmmt5g.YEAR = vmmt5p.entry_year
	JOIN v_martin_mrazek_task_5_wages vmmt5w
		ON vmmt5g.YEAR = vmmt5w.payroll_year) AS rt1;