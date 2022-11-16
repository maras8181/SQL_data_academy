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
	AND e.YEAR IN (
		SELECT 
			DISTINCT tmm.entry_year
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.entry_year)
	);

/* INDEXES */

CREATE OR REPLACE INDEX i_category_code ON t_martin_mrazek_project_SQL_primary_final(category_code);
CREATE OR REPLACE INDEX i_date_from_month ON t_martin_mrazek_project_SQL_primary_final(entry_month); 
CREATE OR REPLACE INDEX i_date_from_year ON t_martin_mrazek_project_SQL_primary_final(entry_year); 
CREATE OR REPLACE INDEX i_industry_branch_code ON t_martin_mrazek_project_SQL_primary_final(industry_branch_code); 
CREATE OR REPLACE INDEX i_payroll_year ON t_martin_mrazek_project_SQL_primary_final(payroll_year); 
CREATE OR REPLACE INDEX i_payroll_quarter ON t_martin_mrazek_project_SQL_primary_final(payroll_quarter);

/*
 * VIEWS AND ADDITIONALS TABLES
 */

/* Question (VIEW) 1 */

CREATE OR REPLACE VIEW v_martin_mrazek_task_1 AS (
SELECT 
	DISTINCT tmm.cpayroll_id,
	tmm.industry_branch_code,
	tmm.cpib_name,
	tmm.cpayroll_value,
	tmm.payroll_year,
	tmm.payroll_quarter
FROM t_martin_mrazek_project_sql_primary_final tmm
ORDER BY tmm.industry_branch_code, tmm.payroll_year);

/* Question (VIEW) 2 */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2 AS 
	(SELECT 
		DISTINCT tmm.cprice_id,
		tmm.category_code,
		tmm.cpc_name,
		tmm.cprice_value,
		tmm.date_from,
		tmm.date_to,
		tmm.price_value,
		tmm.price_unit,
		taw.first_last_period,
		taw.avg_wage_in_period,
		taw.payroll_year
	FROM t_martin_mrazek_project_sql_primary_final tmm
	JOIN t_avg_wages_in_first_last_period taw
		ON tmm.date_from = taw.first_last_period
	WHERE tmm.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from 
		LIMIT 1
	)
	OR tmm.date_from = (
		SELECT 
			tmm.date_from
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.date_from DESC
		LIMIT 1
	));

-- Additional table

CREATE OR REPLACE TABLE t_avg_wages_in_first_last_period AS 
	(SELECT 
		rt1.date_from AS first_last_period,
		round(avg(rt1.cpayroll_value), 2) AS avg_wage_in_period,
		rt1.payroll_year
	FROM 
		(SELECT 
			DISTINCT tmm2.cpayroll_id,
			tmm2.cpib_name,
			tmm2.cpayroll_value,
			tmm2.date_from,
			tmm2.payroll_year
		FROM t_martin_mrazek_project_sql_primary_final tmm2
		WHERE tmm2.date_from = (
			SELECT 
				tmm.date_from
			FROM t_martin_mrazek_project_sql_primary_final tmm
			ORDER BY tmm.date_from 
			LIMIT 1
		)
		OR tmm2.date_from = (
			SELECT 
				tmm.date_from
			FROM t_martin_mrazek_project_sql_primary_final tmm
			ORDER BY tmm.date_from DESC
			LIMIT 1 )) AS rt1
		GROUP BY rt1.date_from);

/* Question (VIEW) 3 */

CREATE OR REPLACE VIEW v_martin_mrazek_task_3 AS 
	(SELECT 
		DISTINCT tmm.category_code,
		lag(tmm.category_code) 
			OVER (ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month) AS category_code_prev_row,
		tmm.cpc_name,
		avg(tmm.cprice_value) AS avg_value_in_month,
		lag(avg(tmm.cprice_value)) 
			OVER (ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month) AS avg_value_in_month_prev_row,
		tmm.entry_month,
		tmm.entry_year
	FROM t_martin_mrazek_project_SQL_primary_final tmm
	GROUP BY tmm.category_code, tmm.entry_year, tmm.entry_month
	ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month);

/* Question (VIEW) 4 */

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

/* Question (VIEW) 5 */

-- VIEW 5.1

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_prices AS 
	(SELECT 
		avg(pr.cprice_value) AS avg_price_in_year,
		lag(avg(pr.cprice_value))
			OVER (ORDER BY pr.entry_year) AS avg_price_in_year_prev_row,
		pr.entry_year
	FROM 
		(SELECT 
			DISTINCT tmm.cprice_id,
			tmm.cprice_value,
			tmm.entry_year 
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.entry_year) AS pr
	GROUP BY pr.entry_year);

-- VIEW 5.2

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_wages AS 
	(SELECT 
		avg(wg.cpayroll_value) AS avg_wage_in_year,
		lag(avg(wg.cpayroll_value))
			OVER (ORDER BY wg.payroll_year) AS avg_wage_in_year_prev_row,
		wg.payroll_year
	FROM 
		(SELECT 
			DISTINCT tmm.cpayroll_id,
			tmm.cpayroll_value,
			tmm.payroll_year
		FROM t_martin_mrazek_project_sql_primary_final tmm
		ORDER BY tmm.payroll_year) AS wg
	GROUP BY wg.payroll_year);


/* QUESTIONS TO BE WORKED OUT */ 

/*
 * 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
 */

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

/*
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? 
 */

SELECT 
	rt2.category_code,
	rt2.name,
	rt2.avg_wage_in_period,
	rt2.avg_value,
	round(rt2.avg_wage_in_period / rt2.avg_value) can_be_purchased,
	rt2.date_from,
	rt2.date_to
FROM 
	(SELECT 
		rt1.category_code,
		rt1.name,
		round(avg(rt1.value), 2) AS avg_value,
		rt1.price_value,
		rt1.price_unit,
		rt1.date_from,
		rt1.date_to,
		rt1.avg_wage_in_period
	FROM 
		(SELECT 
			vmmt2.category_code,
			vmmt2.cpc_name AS name,
			vmmt2.cprice_value AS value,
			vmmt2.price_value,
			vmmt2.price_unit,
			vmmt2.date_from,
			vmmt2.date_to,
			vmmt2.payroll_year,
			vmmt2.avg_wage_in_period
		FROM v_martin_mrazek_task_2 vmmt2
		WHERE vmmt2.category_code IN (111301, 114201)) AS rt1
	GROUP BY rt1.category_code, rt1.date_from, rt1.avg_wage_in_period) AS rt2;

/*
 * 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

SELECT 
	rt3.category_code,
	rt3.cpc_name,
	rt3.avg_year_increasing
FROM 
	(SELECT 
		rt2.category_code,
		rt2.cpc_name,
		round(avg(rt2.sum_of_year_percentage), 2) AS avg_year_increasing
	FROM 
		(SELECT 
			rt1.category_code,
			rt1.cpc_name,
			sum(rt1.percentage) AS sum_of_year_percentage,
			rt1.entry_year
		FROM 
		(SELECT 
			*,
			CASE 
				WHEN vmmt3.category_code = vmmt3.category_code_prev_row THEN
					(100 - (vmmt3.avg_value_in_month_prev_row / vmmt3.avg_value_in_month * 100))
				ELSE 0
			END AS percentage
		FROM v_martin_mrazek_task_3 vmmt3) AS rt1
	GROUP BY rt1.category_code, rt1.entry_year) AS rt2
GROUP BY rt2.category_code) AS rt3
ORDER BY rt3.avg_year_increasing
LIMIT 1;

/*
 * 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */

SELECT 
	round(rt4.avg_value_in_year, 2) AS avg_value_in_year,
	rt4.entry_year,
	round(rt4.year_percentage, 2) AS year_percentage
FROM 
	(SELECT 
		*,
		CASE 
			WHEN rt3.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE (100 - (rt3.avg_value_in_year_prev_row / rt3.avg_value_in_year * 100))
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
		GROUP BY rt2.entry_year) AS rt3) AS rt4;

/*
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */

SELECT 
	rt5.YEAR,
	rt5.increasing_of_next_year,
	rt5.increasing_of_second_year
FROM 
	(SELECT 
		*,
		CASE 
			WHEN rt4.gdp_percentage IS NULL AND rt4.gdp_percentage_prev_row IS NULL THEN 
				'HDP: 0.00 (0 %) - PRICE: 0.00 (0 %) - WAGE: 0.00 (0 %)'
			WHEN rt4.gdp_percentage IS NOT NULL AND rt4.gdp_percentage_prev_row IS NULL THEN 
				concat('HDP: ', round((rt4.gdp_percentage), 2), ' (100 %) - PRICE: ', round((rt4.price_percentage), 2), ' (100 %) - WAGE: ', round((rt4.wage_percentage), 2), ' (100 %)')
			ELSE concat('HDP: ', round((rt4.gdp_percentage), 2), ' (', round((rt4.gdp_percentage - rt4.gdp_percentage_prev_row), 2),  ' %) - PRICE: ', round((rt4.price_percentage), 2), ' (', round((rt4.price_percentage - rt4.price_percentage_prev_row), 2),  ' %) - WAGE: ', round((rt4.wage_percentage), 2), ' (', round((rt4.wage_percentage - rt4.wage_percentage_prev_row), 2),  ' %)')
		END AS increasing_of_next_year,
		CASE 
			WHEN rt4.gdp_percentage IS NULL AND rt4.gdp_percentage_prev_row IS NULL THEN 
				'HDP: 0.00 (0 %) - PRICE: 0.00 (0 %) - WAGE: 0.00 (0 %)'
			WHEN rt4.gdp_percentage IS NOT NULL AND rt4.gdp_percentage_prev_row IS NULL THEN 
				concat('HDP: ', round((rt4.gdp_percentage), 2), ' (100 %) - PRICE: ', round((rt4.price_percentage), 2), ' (100 %) - WAGE: ', round((rt4.wage_percentage), 2), ' (100 %)')
			ELSE concat('HDP: ', round((rt4.gdp_percentage), 2), ' (', round((rt4.gdp_percentage - rt4.gdp_percentage_prev_row), 2),  ' %) - PRICE: ', round((rt4.price_percentage_foll_row), 2), ' (', round((rt4.price_percentage_foll_row - rt4.price_percentage_prev_row), 2),  ' %) - WAGE: ', round((rt4.wage_percentage_foll_row), 2), ' (', round((rt4.wage_percentage_foll_row - rt4.wage_percentage_prev_row), 2),  ' %)')
		END AS increasing_of_second_year
	FROM 
		(SELECT 
			rt3.YEAR,
			rt3.gdp_percentage,
			lag(rt3.gdp_percentage)
				OVER (ORDER BY rt3.year) AS gdp_percentage_prev_row,
			rt3.price_percentage,
			lag(rt3.price_percentage)
				OVER (ORDER BY rt3.year) AS price_percentage_prev_row,
			lead(rt3.price_percentage)
				OVER (ORDER BY rt3.year) AS price_percentage_foll_row,
			rt3.wage_percentage,
			lag(rt3.wage_percentage)
				OVER (ORDER BY rt3.year) AS wage_percentage_prev_row,
			lead(rt3.wage_percentage)
				OVER (ORDER BY rt3.year) AS wage_percentage_foll_row
		FROM 
			(SELECT 
				*,
				CASE 
					WHEN rt2.avg_gdp_europe_prev_row IS NOT NULL 
					THEN (100 - (rt2.avg_gdp_europe_prev_row / rt2.avg_gdp_europe * 100))
				END AS gdp_percentage,
				CASE 
					WHEN rt2.avg_price_in_year_prev_row IS NOT NULL 
					THEN (100 - (rt2.avg_price_in_year_prev_row / rt2.avg_price_in_year * 100))
				END AS price_percentage,
				CASE 
					WHEN rt2.avg_wage_in_year IS NOT NULL 
					THEN (100 - (rt2.avg_wage_in_year_prev_row / rt2.avg_wage_in_year * 100))
				END AS wage_percentage	
			FROM 
				(SELECT 
					*
				FROM 
					(SELECT 
						avg(tmm.gdp) AS avg_gdp_europe,
						lag(avg(tmm.gdp)) 
							OVER (ORDER BY tmm.YEAR) AS avg_gdp_europe_prev_row,
						tmm.YEAR
					FROM t_martin_mrazek_project_SQL_secondary_final tmm
					GROUP BY tmm.YEAR) AS rt1
					JOIN v_martin_mrazek_task_5_prices vmmt5p
						ON rt1.YEAR = vmmt5p.entry_year
					JOIN v_martin_mrazek_task_5_wages vmmt5w
						ON rt1.YEAR = vmmt5w.payroll_year) AS rt2) AS rt3) AS rt4) AS rt5;