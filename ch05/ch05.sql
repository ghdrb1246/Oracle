-- 5-1
SELECT TO_CHAR(hire_date, 'YYYY') AS hire_year, COUNT(*) AS emp_cnt
FROM employees
GROUP BY TO_CHAR(hire_date, 'YYYY')
ORDER BY hire_year;

-- 5-2
SELECT period, region, SUM(loan_jan_amt) AS totl_jan
FROM kor_loan_status
WHERE period LIKE '2012%'
GROUP BY period, region
ORDER BY period, region;

-- 5-3
SELECT period, gubun, SUM(loan_jan_amt) AS totl_jan
FROM kor_loan_status
WHERE period LIKE '2013%'
GROUP BY period, gubun
UNION ALL

SELECT period, NULL, SUM(loan_jan_amt)
FROM kor_loan_status
WHERE period LIKE '2013%'
GROUP BY period
ORDER BY 1, 2 NULLS LAST;

-- 5-4
SELECT period, SUM(loan_jan_amt) AS 주택담보대출액, 0 AS 기타대출액
FROM kor_loan_status
WHERE period = '201311'
AND gubun  = '주택담보대출'
GROUP BY period
UNION ALL

SELECT period, 0, SUM(loan_jan_amt)
FROM kor_loan_status
WHERE period = '201311'
AND gubun  = '기타대출'
GROUP BY period;

-- 5-5
SELECT region AS 지역,
    SUM(DECODE(period, '201111', loan_jan_amt, 0)) AS "201111",
    SUM(DECODE(period, '201112', loan_jan_amt, 0)) AS "201112",
    SUM(DECODE(period, '201210', loan_jan_amt, 0)) AS "201210",
    SUM(DECODE(period, '201211', loan_jan_amt, 0)) AS "201211",
    SUM(DECODE(period, '201212', loan_jan_amt, 0)) AS "201212",
    SUM(DECODE(period, '201310', loan_jan_amt, 0)) AS "201310",
    SUM(DECODE(period, '201311', loan_jan_amt, 0)) AS "201311"
FROM kor_loan_status
GROUP BY region
ORDER BY region;