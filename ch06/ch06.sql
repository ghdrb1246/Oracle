-- 6-1
SELECT 
    a.employee_id AS 사번,
    a.emp_name AS 사원명,
    d.job_title AS job명칭,
    b.start_date AS job시작일자,
    b.end_date AS job종료일자,
    c.department_name AS job수행부서명
FROM 
    employees a,
    job_history b,
    departments c,
    jobs d
WHERE 
    a.employee_id = b.employee_id
    AND b.department_id = c.department_id
    AND b.job_id = d.job_id
    AND a.employee_id = 101
ORDER BY b.start_date;

-- 6-2
SELECT a.employee_id, a.emp_name, b.job_id, b.department_id
FROM employees a, job_history b
WHERE a.employee_id = b.employee_id(+) AND a.department_id(+) = b.department_id;

/*
 첫 조건은 a 를 기준으로 b 를 외부 조인을 하고,
 둘째 조건은 b 를 기준으로 a 를 외부 조인을 합니다.
 같은 두 테이블을 서로 반대 방향으로 동시에 외부 조인하므로 어느 쪽이 기준 테이블인지 정할 수 없어 오류가 발생합니다.
*/

-- 6-3
SELECT a.department_id, a.department_name, b.employee_id
FROM departments a, employees b
WHERE a.department_id = b.department_id(+) AND b.job_id(+) IN ('SH_CLERK', 'ST_CLERK');

SELECT a.department_id, a.department_name, b.employee_id
FROM departments a, employees b
WHERE a.department_id = b.department_id(+) AND b.job_id(+) IN ('SH_CLERK');

/*
 IN는 내부적으로 col = v1 OR col = v2 로 바뀝니다.
 (+) 연산자는 OR 조건의 피연산자로 쓸 수 없으므로 값이 여러 개면 오류가 발행합니다.
 값이 하나인 IN은 옵티마이저가 'col = v1' 로 변환하므로 OR 가 생기지 않아 일반 외부 조인 조건처럼 처리된니다.
*/

-- 6-4
SELECT a.department_id, a.department_name
FROM departments a
INNER JOIN employees b ON a.department_id = b.department_id
WHERE b.salary > 3000
ORDER BY a.department_name;

-- 6-5
SELECT a.department_id, a.department_name
FROM departments a
WHERE a.department_id IN (
    SELECT department_id
    FROM job_history
);

-- 6-6
WITH emp_sale AS (
    SELECT SUBSTR(a.sales_month, 1, 4) AS years, a.employee_id, SUM(a.amount_sold) AS amount_sold
    FROM sales a, customers b, countries c
    WHERE a.cust_id    = b.cust_id
        AND b.country_id = c.country_id
       AND c.country_name = 'Italy'
    GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id
), 
year_sale AS (
    SELECT years, MAX(amount_sold) AS max_sold, MIN(amount_sold) AS min_sold
    FROM emp_sale
    GROUP BY years
)
SELECT e.years,
    CASE WHEN e.amount_sold = y.max_sold THEN '최대' ELSE '최소' END AS 구분,
    e.employee_id, m.emp_name, e.amount_sold
FROM emp_sale e
JOIN year_sale y ON e.years = y.years AND e.amount_sold IN (y.max_sold, y.min_sold)
JOIN employees m ON e.employee_id = m.employee_id
ORDER BY e.years, 구분;