USE [Titan]
Go

/*rollback record of product price for product 8*/

DELETE FROM [dbo].[tbl_product_prices] WHERE [product_id] = 8;

GO