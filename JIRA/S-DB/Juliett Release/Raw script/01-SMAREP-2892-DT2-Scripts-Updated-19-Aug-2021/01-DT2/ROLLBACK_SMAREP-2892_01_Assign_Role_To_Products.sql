USE [Titan]
Go

/*Rolling back value of Product_Role_Int to original for products with id */

DECLARE @productId1 int
SELECT @productId1 = product_id FROM [dbo].[tbl_products] WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H011';

DECLARE @productId2 int
SELECT @productId2 = product_id FROM [dbo].[tbl_products] WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H012';

UPDATE [dbo].[tbl_Products] SET [Product_Role_Int] = NULL where product_id IN ('2253','2252','2251','3077','29','30','28',@productId1,@productId2);