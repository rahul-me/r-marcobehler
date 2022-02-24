USE [Titan]
Go

/*rollback record of product price for product 9*/

DELETE FROM [dbo].[tbl_product_prices] WHERE [product_id] = 9;

GO