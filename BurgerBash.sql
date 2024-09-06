show databases;
create database Bash;
use bash;
show tables;

CREATE TABLE `burger_name` (
  `burger_id` BIGINT,
  `burger_name` VARCHAR(1024)
);

INSERT INTO `burger_name` (`burger_id`,`burger_name`)
VALUES
(1,'Meatlovers'),
(2,'Vegetarian');

CREATE TABLE `runner_orders` (
  `order_id` BIGINT,
  `runner_id` BIGINT,
  `pickup_time` VARCHAR(1024),
  `distance` VARCHAR(1024),
  `duration` VARCHAR(1024),
  `cancellation` VARCHAR(1024) NULL
);

INSERT INTO `runner_orders` (`order_id`,`runner_id`,`pickup_time`,`distance`,`duration`,`cancellation`)
VALUES
(1,1,'01-01-21 18:15','20km','32 minutes',NULL),
(2,1,'01-01-21 19:10','20km','27 minutes',NULL),
(3,1,'03-01-21 0:12','13.4km','20 mins',NULL),
(4,2,'04-01-21 13:53','23.4','40',NULL),
(5,3,'08-01-21 21:10','10','15',NULL),
(6,3,'null','null','null','Restaurant Cancellation'),
(7,2,'08-01-21 21:30','25km','25mins','null'),
(8,2,'10-01-21 0:15','23.4 km','15 minute','null'),
(9,2,'null','null','null','Customer Cancellation'),
(10,1,'11-01-21 18:50','10km','10minutes','null');

CREATE TABLE `burger_runner` (
  `runner_id` BIGINT,
  `registration_date` VARCHAR(1024)
);

INSERT INTO `burger_runner` (`runner_id`,`registration_date`)
VALUES
(1,'2021-01-01T00:00:00.000Z'),
(2,'2021-01-03T00:00:00.000Z'),
(3,'2021-01-08T00:00:00.000Z'),
(4,'2021-01-15T00:00:00.000Z');

CREATE TABLE `customers` (
  `order_id` BIGINT,
  `customer_id` BIGINT,
  `burger_id` BIGINT,
  `exclusions` VARCHAR(1024) NULL,
  `extras` VARCHAR(1024) NULL,
  `order_time` VARCHAR(1024)
);

INSERT INTO `customers` (`order_id`,`customer_id`,`burger_id`,`exclusions`,`extras`,`order_time`)
VALUES
(1,101,1,NULL,NULL,'2021-01-01T18:05:02.000Z'),
(2,101,1,NULL,NULL,'2021-01-01T19:00:52.000Z'),
(3,102,1,NULL,NULL,'2021-01-02T23:51:23.000Z'),
(3,102,2,NULL,NULL,'2021-01-02T23:51:23.000Z'),
(4,103,1,'4',NULL,'2021-01-04T13:23:46.000Z'),
(4,103,1,'4',NULL,'2021-01-04T13:23:46.000Z'),
(4,103,2,'4',NULL,'2021-01-04T13:23:46.000Z'),
(5,104,1,'null','1','2021-01-08T21:00:29.000Z'),
(6,101,2,'null','null','2021-01-08T21:03:13.000Z'),
(7,105,2,'null','1','2021-01-08T21:20:29.000Z'),
(8,102,1,'null','null','2021-01-09T23:54:33.000Z'),
(9,103,1,'4','1, 5','2021-01-10T11:22:59.000Z'),
(10,104,1,'null','null','2021-01-11T18:34:49.000Z'),
(10,104,1,'2, 6','1, 4','2021-01-11T18:34:49.000Z');

#Q.1
SELECT COUNT(*) AS total_burgers_ordered
FROM customers;

#Q.2
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM customers;

#Q.3
SELECT ro.runner_id, COUNT(DISTINCT ro.order_id) AS successful_orders
FROM runner_orders ro
JOIN customers c ON ro.order_id = c.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id;

#Q.4
SELECT bn.burger_name, COUNT(c.burger_id) AS burgers_delivered
FROM customers c
JOIN runner_orders ro ON c.order_id = ro.order_id
JOIN burger_name bn ON c.burger_id = bn.burger_id
WHERE ro.cancellation IS NULL
GROUP BY bn.burger_name;

#Q.5
SELECT c.customer_id, bn.burger_name, COUNT(c.burger_id) AS burger_count
FROM customers c
JOIN burger_name bn ON c.burger_id = bn.burger_id
WHERE bn.burger_name IN ('Vegetarian', 'Meatlovers')
GROUP BY c.customer_id, bn.burger_name;

#Q.6
SELECT MAX(burger_count) AS max_burgers_in_single_order
FROM (
    SELECT order_id, COUNT(*) AS burger_count
    FROM customers
    GROUP BY order_id
) AS order_burger_counts;

#Q.7
SELECT 
    c.customer_id,
    COUNT(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 END) AS burgers_with_changes,
    COUNT(CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 END) AS burgers_without_changes
FROM 
    customers c
JOIN 
    runner_orders ro ON c.order_id = ro.order_id
WHERE 
    ro.cancellation IS NULL
GROUP BY 
    c.customer_id;
    
#Q.8
SELECT 
    DATE_FORMAT(STR_TO_DATE(c.order_time, '%Y-%m-%dT%H:%i:%s.000Z'), '%Y-%m-%d %H') AS hour_of_day,
    SUM(COUNT(*)) OVER(PARTITION BY DATE_FORMAT(STR_TO_DATE(c.order_time, '%Y-%m-%dT%H:%i:%s.000Z'), '%Y-%m-%d %H')) AS total_burgers_ordered
FROM 
    customers c
JOIN 
    runner_orders ro ON c.order_id = ro.order_id
WHERE 
    ro.cancellation IS NULL
GROUP BY 
    hour_of_day
ORDER BY 
    hour_of_day;
    
#Q.9
SELECT 
    YEARWEEK(STR_TO_DATE(br.registration_date, '%Y-%m-%dT%H:%i:%s.000Z')) AS week_number,
    COUNT(DISTINCT br.runner_id) AS runners_signed_up
FROM 
    burger_runner br
GROUP BY 
    week_number
ORDER BY 
    week_number;
    
#Q.10
SELECT
    customer_id,
    AVG(distance + 0) AS average_distance_traveled
FROM
    customers
JOIN
    runner_orders ON customers.order_id = runner_orders.order_id
WHERE
    runner_orders.cancellation IS NULL
GROUP BY
    customer_id;

    
    













