USE [Titan]
Go

/*rollback record of product for product SKU H01H011*/

DELETE FROM [dbo].[tbl_products] WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H011';

GO