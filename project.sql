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
WHERE cpay.value_type_code = 5958)

CREATE OR REPLACE INDEX i_category_code ON t_martin_mrazek_project_SQL_primary_final(category_code);
CREATE OR REPLACE INDEX i_date_from_month ON t_martin_mrazek_project_SQL_primary_final(entry_month); 
CREATE OR REPLACE INDEX i_date_from_month ON t_martin_mrazek_project_SQL_primary_final(entry_year); 

/*
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční 
 * nárůst)?
 */

CREATE OR REPLACE VIEW v_martin_mrazek_task_3 AS (
SELECT 
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
ORDER BY tmm.category_code, tmm.entry_year, tmm.entry_month)

SELECT 
	rt3.category_code,
	rt3.avg_year_increasing
FROM 
	(SELECT 
		rt2.category_code,
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