-- 7-1
SELECT department_id, SUBSTR(SYS_CONNECT_BY_PATH(emp_name, ','), 2) AS empnames
FROM (
    SELECT emp_name, department_id,
        COUNT(*) OVER (PARTITION BY department_id) AS cnt,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY emp_name) AS rseq
    FROM employees
    WHERE department_id IS NOT NULL
)
WHERE rseq = cnt
START WITH rseq = 1
CONNECT BY PRIOR rseq + 1 = rseq AND PRIOR department_id = department_id
ORDER BY department_id;

-- 7-2
SELECT employee_id, emp_name, hire_date, LEAD(hire_date) OVER (ORDER BY hire_date) AS retire_date
FROM employees
WHERE job_id = 'SH_CLERK'
ORDER BY hire_date;

-- 7-3
SELECT TRUNC((TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - c.cust_year_of_birth) / 10) * 10 || '대' AS 연령대, SUM(s.amount_sold) AS 매출금액
FROM sales s, customers c
WHERE s.cust_id = c.cust_id AND s.sales_month = '200112'
GROUP BY TRUNC((TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - c.cust_year_of_birth) / 10) * 10
ORDER BY 1;

-- 7-4
WITH basis AS (
    SELECT s.sales_month, c.country_region, SUM(s.amount_sold) AS amt
    FROM sales s, customers b, countries c
    WHERE s.cust_id = b.cust_id AND b.country_id = c.country_id
    GROUP BY s.sales_month, c.country_region
), 
ranked AS (
    SELECT sales_month, country_region, amt, RANK() OVER (PARTITION BY sales_month ORDER BY amt) AS rnk
    FROM basis
)
SELECT 
    sales_month AS 매출월,
    country_region AS "지역(대륙)",
    amt AS 매출금액
FROM ranked
WHERE rnk = 1
ORDER BY sales_month;

-- 7-5
WITH basis AS (
    SELECT region, gubun,
        SUM(DECODE(period, '201111', loan_jan_amt, 0)) a1,
        SUM(DECODE(period, '201112', loan_jan_amt, 0)) a2,
        SUM(DECODE(period, '201210', loan_jan_amt, 0)) a3,
        SUM(DECODE(period, '201211', loan_jan_amt, 0)) a4,
        SUM(DECODE(period, '201212', loan_jan_amt, 0)) a5,
        SUM(DECODE(period, '201310', loan_jan_amt, 0)) a6,
        SUM(DECODE(period, '201311', loan_jan_amt, 0)) a7
    FROM kor_loan_status
    GROUP BY region, gubun
)
SELECT region AS 지역, gubun AS 대출종류,
    a1||'( '||ROUND(RATIO_TO_REPORT(a1) OVER (PARTITION BY region)*100)||'% )' "201111",
    a2||'( '||ROUND(RATIO_TO_REPORT(a2) OVER (PARTITION BY region)*100)||'% )' "201112",
    a3||'( '||ROUND(RATIO_TO_REPORT(a3) OVER (PARTITION BY region)*100)||'% )' "201210",
    a4||'( '||ROUND(RATIO_TO_REPORT(a4) OVER (PARTITION BY region)*100)||'% )' "201211",
    a5||'( '||ROUND(RATIO_TO_REPORT(a5) OVER (PARTITION BY region)*100)||'% )' "201212",
    a6||'( '||ROUND(RATIO_TO_REPORT(a6) OVER (PARTITION BY region)*100)||'% )' "201310",
    a7||'( '||ROUND(RATIO_TO_REPORT(a7) OVER (PARTITION BY region)*100)||'% )' "201311"
FROM basis
ORDER BY region, gubun;