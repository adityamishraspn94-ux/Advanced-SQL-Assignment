/*------------  Advanced SQL Assignment  -----------*/

use company_db;

CREATE TABLE Products (
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Category VARCHAR(50),
Price DECIMAL(10,2));

INSERT INTO Products 
VALUES
(1, 'Keyboard', 'Electronics', 1200),
(2, 'Mouse', 'Electronics', 800),
(3, 'Chair', 'Furniture', 2500),
(4, 'Desk', 'Furniture', 5500);

CREATE TABLE Sales_1 (
SaleID INT PRIMARY KEY,
ProductID INT,
Quantity INT,
SaleDate DATE,
FOREIGN KEY (ProductID) 
REFERENCES Products(ProductID));

INSERT INTO Sales_1 
VALUES
(1, 1, 4, '2024-01-05'),
(2, 2, 10, '2024-01-06'),
(3, 3, 2, '2024-01-10'),
(4, 4, 1, '2024-01-11');

SELECT * FROM Products;
SELECT * FROM Sales_1;

/*-- Q6. Write a CTE to calculate the total revenue for each product 
 (Revenues = Price × Quantity), and return only products where  revenue > 3000. --*/

WITH ProductRevenue AS (
SELECT 
p.ProductID,
p.ProductName,
SUM(p.Price * s.Quantity) AS Revenue
FROM Products p
JOIN Sales_1 s
ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.ProductName)
SELECT * FROM ProductRevenue
WHERE Revenue > 3000;

/*-- Q7. Create a view named vw_CategorySummary that shows: Category, TotalProducts, and AveragePrice.--*/

CREATE VIEW vw_CategorySummary AS
SELECT
Category,
COUNT(*) AS TotalProducts,
AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category;

SELECT * FROM vw_CategorySummary;

/*-- Q8. Create an updatable view containing ProductID, ProductName, and Price. 
Then update the price of ProductID = 1 using the view.--*/

# Create Updatable View
 
CREATE VIEW vw_ProductPrice AS
SELECT
ProductID,
ProductName,
Price
FROM Products;

## Update using the View

UPDATE vw_ProductPrice
SET Price = 1300
WHERE ProductID = 1;

SELECT * FROM Products WHERE ProductID = 1;

/*-- Q9. Create a stored procedure that accepts a category name and returns all products belonging to that category.--*/

DELIMITER //

CREATE PROCEDURE GetProductsByCategory (
IN cat_name VARCHAR(50))
BEGIN
SELECT *
FROM Products
WHERE Category = cat_name;
END //

DELIMITER ;

CALL GetProductsByCategory('Electronics');

CALL GetProductsByCategory('Furniture');

/*-- Q10. Create an AFTER DELETE trigger on the products table that archives deleted product rows into a new
table productArchive. The archive should store ProductID, ProductName, Category, Price, and DeletedAt
timestamp.--*/ 

CREATE TABLE ProductArchive (
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DeletedAt TIMESTAMP);

SELECT * FROM ProductArchive;

DELIMITER //

CREATE TRIGGER trg_after_delete_products
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive
    (ProductID, ProductName, Category, Price, DeletedAt)
    VALUES
    (OLD.ProductID, OLD.ProductName, OLD.Category, OLD.Price, NOW());
END //

DELIMITER ;

START TRANSACTION;

DELETE FROM Sales_1 WHERE ProductID = 2;
DELETE FROM Products WHERE ProductID = 2;
SELECT * FROM ProductArchive;

ROLLBACK;








