USE [Titan]
Go

/*rollback record of product price for product H01H011*/

DECLARE @productId int
SELECT @productId = product_id FROM [dbo].[tbl_products] WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H011';

DELETE FROM [dbo].[tbl_product_prices] WHERE [product_id] = @productId;

GO