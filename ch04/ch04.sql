-- 4-1
SELECT employee_id, emp_name, phone_number, '(02)' || SUBSTR(phone_number, INSTR(phone_number, '.') + 1) AS seoul_phone
FROM employees
ORDER BY employee_id;

-- 4-2
SELECT
    employee_id AS 사원번호,
    emp_name AS 사원명,
    hire_date AS 입사일자,
    TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS 근속년수
FROM employees
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) >= 120
ORDER BY 근속년수 DESC, hire_date;

-- 4-3
SELECT cust_id, cust_name, cust_main_phone_number, 
    REPLACE(cust_main_phone_number, '-', '/') AS new_phone
FROM customers;

-- 4-4
SELECT cust_id, cust_main_phone_number,
    TRANSLATE(cust_main_phone_number, '0123456789', 'acielsfjwm') AS enc_phone
FROM customers;

-- 4-5
SELECT cust_id, cust_name, cust_year_of_birth,
    DECODE(TRUNC((TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - cust_year_of_birth) / 10),
        3, '30대',
        4, '40대',
        5, '50대',
            '기타'
    ) AS generation
FROM customers;

-- 4-6
SELECT cust_id, cust_name, age,
    CASE WHEN age < 10 THEN '10세 미만'
        WHEN age BETWEEN 10 AND 19 THEN '10대'
        WHEN age BETWEEN 20 AND 29 THEN '20대'
        WHEN age BETWEEN 30 AND 39 THEN '30대'
        WHEN age BETWEEN 40 AND 49 THEN '40대'
        WHEN age BETWEEN 50 AND 59 THEN '50대'
        WHEN age BETWEEN 60 AND 69 THEN '60대'
        WHEN age BETWEEN 70 AND 79 THEN '70대'
        WHEN age BETWEEN 80 AND 89 THEN '80대'
        ELSE '90대 이상'
    END AS generation
FROM (
    SELECT cust_id, cust_name,
    TO_NUMBER(
        TO_CHAR(SYSDATE, 'YYYY')
    ) - cust_year_of_birth AS age
    
    FROM customers
);