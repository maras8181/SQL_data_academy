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
	rt1.industry_branch_code,
	rt1.cpib_name AS name,
	round(avg(rt1.avg_value_in_year_quarter), 2) AS avg_value_in_year,
	rt1.payroll_year
FROM 
	(SELECT 
		vmmt1.industry_branch_code,vmmt1.cpib_name,
		avg(vmmt1.cpayroll_value) AS avg_value_in_year_quarter,
		vmmt1.payroll_year,
		vmmt1.payroll_quarter
	FROM v_martin_mrazek_task_1 vmmt1
	GROUP BY vmmt1.industry_branch_code, vmmt1.payroll_year, vmmt1.payroll_quarter) AS rt1
GROUP BY rt1.industry_branch_code, rt1.payroll_year;
	
/* 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? */

/* Question 2 (VIEW 1) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_prices AS 
(SELECT 
	DISTINCT tmm2.cprice_id,
	tmm2.category_code,
	tmm2.cpc_name AS name,
	round(avg(tmm2.cprice_value), 2) AS avg_value_in_period,
	tmm2.date_from,
	tmm2.date_to,
	tmm2.price_value,
	tmm2.price_unit
FROM t_martin_mrazek_project_sql_primary_final tmm2
WHERE tmm2.date_from IN ('2006-01-02', '2018-12-10')
AND tmm2.category_code IN (111301, 114201)
GROUP BY tmm2.category_code, tmm2.date_from);

/* Question 2 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_2_avg_wages AS 
(SELECT 
	DISTINCT tmm2.cpayroll_id,
	round(avg(tmm2.cpayroll_value), 2) AS avg_wage_in_period,
	tmm2.date_from
FROM t_martin_mrazek_project_sql_primary_final tmm2
WHERE tmm2.date_from = '2006-01-02' AND tmm2.payroll_quarter = 1
OR tmm2.date_from = '2018-12-10' AND tmm2.payroll_quarter = 4
GROUP BY tmm2.date_from);

/* Question 2 (FINAL QUERY) */

SELECT 
	vmmt2ap.category_code,
	vmmt2ap.name,
	vmmt2ap.avg_value_in_period,
	vmmt2aw.avg_wage_in_period,
	round((vmmt2aw.avg_wage_in_period / vmmt2ap.avg_value_in_period), 2) AS can_be_purchased,
	vmmt2ap.date_from,
	vmmt2ap.date_to,
	vmmt2ap.price_value,
	vmmt2ap.price_unit
FROM v_martin_mrazek_task_2_avg_prices vmmt2ap
JOIN v_martin_mrazek_task_2_avg_wages vmmt2aw
	ON vmmt2ap.date_from = vmmt2aw.date_from;
		
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
	rt4.category_code,
	rt4.name,
	concat(round(avg(rt4.year_on_year_increase), 2), ' %') AS year_on_year_increase
FROM
(SELECT 
	*,
	CASE 
		WHEN rt3.category_code = rt3.category_code_prev_row
			THEN ((rt3.avg_value_in_year - rt3.avg_value_in_year_prev_row) / rt3.avg_value_in_year_prev_row) * 100
		ELSE 0
	END year_on_year_increase
FROM
	(SELECT 
		rt2.category_code,
		lag(rt2.category_code) OVER
			(PARTITION BY rt2.name ORDER BY rt2.category_code, rt2.entry_year) AS category_code_prev_row,
		rt2.name,
		rt2.avg_value_in_year,
		lag(rt2.avg_value_in_year) OVER
			(PARTITION BY rt2.name ORDER BY rt2.category_code, rt2.entry_year) AS avg_value_in_year_prev_row,
		rt2.entry_year
	FROM 
		(SELECT
			rt1.category_code,
			rt1.name,
			round(avg(rt1.avg_value_in_month), 2) AS avg_value_in_year,
			rt1.entry_year
		FROM 
			(SELECT 
				vmmt3.category_code,
				vmmt3.cpc_name AS name,
				round(avg(vmmt3.cprice_value), 2) AS avg_value_in_month,
				vmmt3.entry_month,
				vmmt3.entry_year
			FROM v_martin_mrazek_task_3 vmmt3
			GROUP BY vmmt3.category_code, vmmt3.entry_year, vmmt3.entry_month
			ORDER BY vmmt3.category_code, vmmt3.entry_year, vmmt3.entry_month) AS rt1
		GROUP BY rt1.category_code, rt1.entry_year) AS rt2) AS rt3) AS rt4
	GROUP BY rt4.category_code
	ORDER BY round(avg(rt4.year_on_year_increase), 2)
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
	rt3.entry_year AS year,
	round((rt3.avg_value_in_year), 2) AS avg_price_value_in_year,	
	concat(round((rt3.year_on_year_percentage), 2), ' %') AS price_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt2.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE ((rt2.avg_value_in_year - rt2.avg_value_in_year_prev_row) / rt2.avg_value_in_year_prev_row) * 100
		END AS year_on_year_percentage
	FROM
		(SELECT 
			avg(rt1.avg_value_in_year_period) AS avg_value_in_year,
			lag(avg(rt1.avg_value_in_year_period))
				OVER (PARTITION BY rt1.name ORDER BY rt1.entry_year) AS avg_value_in_year_prev_row,
			rt1.entry_year			
		FROM
			(SELECT 
				vmmt4.category_code,
				vmmt4.cpc_name AS name,
				avg(vmmt4.cprice_value) AS avg_value_in_year_period,
				vmmt4.entry_year
			FROM v_martin_mrazek_task_4 vmmt4
			GROUP BY vmmt4.category_code, vmmt4.entry_year
			ORDER BY vmmt4.category_code, vmmt4.entry_year) AS rt1 
		GROUP BY rt1.entry_year) AS rt2) AS rt3;
		
/* 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
  ve stejném nebo násdujícím roce výraznějším růstem? */
	
/* Question 5 (VIEW 1) */
	
CREATE OR REPLACE VIEW v_martin_mrazek_task_5_gdp AS 
(SELECT 
	rt2.YEAR,
	rt2.gdp,
	concat(round((rt2.year_percentage), 2), ' %') AS gdp_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt1.country = rt1.country_prev_row
				THEN ((rt1.gdp - rt1.gdp_prev_row) / rt1.gdp_prev_row) * 100
			ELSE 0	
		END AS year_percentage	
	FROM
		(SELECT 
			tmmpssf.country,
			lag(tmmpssf.country)
				OVER (PARTITION BY tmmpssf.country ORDER BY tmmpssf.country, tmmpssf.year) AS country_prev_row,
			tmmpssf.YEAR,
			tmmpssf.gdp,
			lag(tmmpssf.gdp)
				OVER (PARTITION BY tmmpssf.country ORDER BY tmmpssf.country, tmmpssf.year) AS gdp_prev_row
		FROM t_martin_mrazek_project_sql_secondary_final tmmpssf
		ORDER BY tmmpssf.country, tmmpssf.YEAR) AS rt1) AS rt2
	GROUP BY rt2.YEAR);
	
/* Question 5 (VIEW 2) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_prices AS 
(SELECT 
	rt3.entry_year,
	round((rt3.avg_price_value_in_year), 2) AS avg_price_value_in_year,
	concat(round((rt3.year_percentage_increase), 2), ' %') AS price_year_percentage_increase
FROM
	(SELECT 
		*,
		CASE 
			WHEN rt2.avg_value_in_year_prev_row IS NULL THEN 0
			ELSE ((rt2.avg_price_value_in_year - rt2.avg_value_in_year_prev_row) / rt2.avg_value_in_year_prev_row) * 100
		END AS year_percentage_increase		
	FROM 
		(SELECT 
			avg(rt1.avg_value_in_year_period) AS avg_price_value_in_year,
			lag(avg(rt1.avg_value_in_year_period))
				OVER (PARTITION BY rt1.name ORDER BY rt1.entry_year) AS avg_value_in_year_prev_row,
			rt1.entry_year
		FROM 
			(SELECT 
				vmmt4.category_code,
				vmmt4.cpc_name AS name,
				avg(vmmt4.cprice_value) AS avg_value_in_year_period,
				vmmt4.entry_year
			FROM v_martin_mrazek_task_4 vmmt4
			GROUP BY vmmt4.category_code, vmmt4.entry_year
			ORDER BY vmmt4.category_code, vmmt4.entry_year) AS rt1
			GROUP BY rt1.entry_year) AS rt2) AS rt3);

/* Question 5 (VIEW 3) */

CREATE OR REPLACE VIEW v_martin_mrazek_task_5_wages AS 
(SELECT 
	rt2.payroll_year,
	round((rt2.avg_wage_in_year), 2) AS avg_wage_in_year,
	concat(round((rt2.wage_percentage_increase), 2), ' %') AS wage_year_percentage_increase
FROM 
	(SELECT 
		*,
		CASE 
			WHEN rt1.avg_wage_in_year_prev_row IS NULL
				THEN 0
			ELSE ((rt1.avg_wage_in_year - rt1.avg_wage_in_year_prev_row) / rt1.avg_wage_in_year_prev_row) * 100
		END AS wage_percentage_increase
	FROM
		(SELECT 
			vmmt1.payroll_year,
			round(avg(vmmt1.cpayroll_value), 2) AS avg_wage_in_year,
			lag(round(avg(vmmt1.cpayroll_value), 2))
				OVER (ORDER BY vmmt1.payroll_year) AS avg_wage_in_year_prev_row
		FROM v_martin_mrazek_task_1 vmmt1
		GROUP BY vmmt1.payroll_year) AS rt1) AS rt2);

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