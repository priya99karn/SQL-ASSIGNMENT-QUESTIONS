use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		
Select DATE_FORMAT(Order_Date,'%Y-%m') As Month, SUM(Quantity) As Quantities_Sold,
SUM(Sales) AS Sales
From Orders As ord 
Left Join ordered_items As ord_it on ord.Order_Id=ord_it.Order_Id
Left Join product_info As prod_info on ord_it.Item_Id=prod_info.Product_Id
where LOWER(Product_Name) like '%nike%'
Group By Month 
Order By Month;




-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/


SELECT prod_info.Product_Id,prod_info.Product_Name,
cat.Name AS Category_Name,
dept.Name AS Department_Name,
prod_info.Product_Price
FROM product_info AS prod_info
LEFT JOIN category AS cat ON prod_info.Category_Id =cat.Id
LEFT JOIN department AS dept ON prod_info.Department_Id=dept.Id
ORDER BY prod_info.Product_Price DESC
LIMIT 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
SELECT prod.Product_Name AS Product_Name, SUM(items.Sales) AS Sales, COUNT(DISTINCT ord.Order_Id) AS Distinct_Order_Count 
FROM orders AS ord INNER JOIN ordered_items AS items ON ord.Order_Id = items.Order_Id 
INNER JOIN product_info AS prod ON items.Item_Id = prod.Product_Id WHERE ord.Type = 'CASH' 
GROUP BY Product_Name ORDER BY Distinct_Order_Count DESC LIMIT 10;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
SELECT o.* FROM orders AS o LEFT JOIN customer_info AS c ON o.Customer_Id = c.Id
WHERE State = 'TX' AND lower(street) LIKE '%Plaza%' AND ~ (lower(street)LIKE '%Mountain%')
group by Order_id  ORDER BY Order_Id;

-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT count(DISTINCT ord.order_id) AS order_count FROM orders AS ord INNER JOIN customer_info AS cus 
ON ord.customer_id=cus.id INNER JOIN ordered_items AS ord_itm 
ON ord.order_id=ord_itm.order_id INNER JOIN product_info AS pro 
ON ord_itm.item_id=pro.product_id INNER JOIN department AS dep 
ON pro.department_id=dep.id 
WHERE cus.segment='Home Office' AND( dep.name = 'Apparel' OR dep.name = 'Outdoors') ;




-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
SELECT
  c.state AS order_state,
  c.city AS order_city,
  COUNT(DISTINCT o.order_id) AS order_count,
  DENSE_RANK() OVER (PARTITION BY c.state ORDER BY COUNT(DISTINCT o.order_id) DESC) AS city_rank
FROM customer_info c
INNER JOIN orders o ON c.id = o.customer_id
INNER
 
JOIN ordered_items oi ON o.order_id = oi.order_id
INNER
 
JOIN product_info p ON oi.item_id = p.product_id
INNER
 
JOIN department d ON p.department_id = d.id
WHERE c.segment =
 
'Home Office'
 
AND d.name IN ('Apparel', 'Outdoors')
GROUP BY c.state, c.city
ORDER BY c.state, c.city DESC;



-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/

SELECT O.Shipping_Mode,COUNT(O.order_id) 
       AS
       Shipping_Underestimated_Order_Count,
ROW_NUMBER()OVER (PARTITION BY YEAR(O.Order_Date)
ORDER BY Count(O.order_id) DESC) AS Shipping_Mode_Rank
FROM   orders O INNER JOIN customer_info CI
               ON O.Customer_Id = CI.Id
WHERE  (O.Order_Status = 'Complete' or O.Order_Status = 'Closed')
       AND CI.Segment = 'Consumer'
       AND O.Scheduled_Shipping_Days <Real_Shipping_Days
GROUP BY O.Shipping_Mode, YEAR(O.Order_Date);

-- **********************************************************************************************************************************





