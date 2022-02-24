USE [Titan]
Go

/*Rolling back value of Product_Role_Int to original for products with id */

UPDATE [dbo].[tbl_Products] SET [Product_Role_Int] = NULL where product_id IN ('2253','2252','2251','3077','8','9','29','30','28');