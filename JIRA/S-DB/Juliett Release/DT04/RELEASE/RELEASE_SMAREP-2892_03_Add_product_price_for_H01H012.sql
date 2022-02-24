USE [Titan]
Go

/*Add record in product price for product H01H012*/

DECLARE @currentdatetime DATETIME
SET @currentdatetime = GETDATE()
DECLARE	@return_value int

DECLARE @productId int
SELECT @productId = product_id FROM [dbo].[tbl_products] WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H012';

EXEC	@return_value = [dbo].[cp_Add_Product_Price]
		@product_id = @productId,
		@price = 0.00,
		@valid_from = @currentdatetime,
		@valid_to = N'2099-12-31',
		@active = 1

SELECT	'Return Value' = @return_value

GO