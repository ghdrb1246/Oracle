-- 2-1
CREATE TABLE orders (
   order_id      NUMBER(12,0),
   order_date    DATE,
   order_mode    VARCHAR2(8 BYTE),
   customer_id   NUMBER(6,0),
   order_status  NUMBER(2,0),
   order_total   NUMBER(8,2) DEFAULT 0,
   sales_rep_id  NUMBER(6,0),
   promotion_id  NUMBER(6,0),
   CONSTRAINT pk_orders      PRIMARY KEY (order_id),
   CONSTRAINT ck_order_mode  CHECK (order_mode IN ('direct', 'online'))
);

SELECT constraint_name, constraint_type, search_condition FROM user_constraints WHERE table_name = 'ORDERS';

-- 2-2
CREATE TABLE order_items (
   order_id      NUMBER(12,0),
   line_item_id  NUMBER(3,0),
   product_id    NUMBER(3,0),
   unit_price    NUMBER(8,2) DEFAULT 0,
   quantity      NUMBER(8,0) DEFAULT 0,
   CONSTRAINT pk_order_items PRIMARY KEY (order_id, line_item_id)
);

SELECT column_name, data_type, data_default FROM user_tab_columns WHERE table_name = 'ORDER_ITEMS';

-- 2-3
CREATE TABLE promotions (
    promo_id    NUMBER(6,0),
    promo_name  VARCHAR2(20),
    CONSTRAINT pk_promotions PRIMARY KEY (promo_id)
);

DESC promotions;

-- 2-4
/*
 FLOAT(n)의 n 은 이진수 자릿수이며, 이진수 n 자리로 표현 가능한 크기는 2^n 이고,
 이를 십진수 자릿수로 바꾸려면 10^x = 2^n 을 풀면 됩니다.
 0.30103 은 log10(2) 값이고, 이진 자릿수는 십진 자릿수 변환 계수 입니다.
*/
SELECT LOG(10, 2)       AS log10_2,
       126 * LOG(10, 2) AS float126_digits
FROM dual;

-- 2-5
CREATE SEQUENCE orders_seq
    INCREMENT BY 1
    START WITH   1000
    MINVALUE     1
    MAXVALUE     99999999
    NOCYCLE
    NOCACHE;

SELECT orders_seq.NEXTVAL FROM dual;
SELECT sequence_name, min_value, max_value, increment_by, last_number FROM user_sequences WHERE sequence_name = 'ORDERS_SEQ';