USE [Titan]
Go

/*Assigning Product role id 1 (which is Addon) to products with id */

UPDATE [dbo].[tbl_Products] SET [Product_Role_Int] = 1 where product_id IN ('2253','2252','2251','3077','8','9','29','30','28');