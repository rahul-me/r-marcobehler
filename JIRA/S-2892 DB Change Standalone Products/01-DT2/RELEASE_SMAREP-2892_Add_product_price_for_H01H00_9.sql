USE [Titan]
Go

/*Add record in product price for product 9*/

DECLARE @currentdatetime DATETIME
SET @currentdatetime = GETDATE()
DECLARE	@return_value int

EXEC	@return_value = [dbo].[cp_Add_Product_Price]
		@product_id = 9,
		@price = 0.00,
		@valid_from = @currentdatetime,
		@valid_to = N'2099-12-31',
		@active = 1

SELECT	'Return Value' = @return_value

GO