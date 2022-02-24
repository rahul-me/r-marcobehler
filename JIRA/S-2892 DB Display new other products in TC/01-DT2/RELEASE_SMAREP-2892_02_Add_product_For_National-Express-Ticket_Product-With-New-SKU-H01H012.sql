USE [Titan]
Go

DECLARE @RC int
DECLARE @SMART_product_type_code char(3)
DECLARE @SMART_product_code char(4)
DECLARE @product_type_id int
DECLARE @product_family_id int
DECLARE @product_brand_id int
DECLARE @product_description varchar(35)
DECLARE @valid_from datetime
DECLARE @valid_to datetime
DECLARE @print_template_id int
DECLARE @serial_required bit
DECLARE @validity_period char(1)
DECLARE @refund_type_id int
DECLARE @print_coupon int
DECLARE @active bit
DECLARE @product_category_id int
DECLARE @product_consumer_type_id int

/*Add record in product for product 'National Express Ticket' with new SKU to have consitency of unique SKU for each products that serves through product catalogue */

EXEC @RC = [dbo].[cp_Add_Product] 
   @SMART_product_type_code = 'H01'
  ,@SMART_product_code = 'H012'
  ,@product_type_id = 5
  ,@product_family_id = 12
  ,@product_brand_id = 1
  ,@product_description = 'National Express Ticket'
  ,@valid_from = ''
  ,@valid_to = ''
  ,@print_template_id = 1
  ,@serial_required = 1
  ,@validity_period = 'N'
  ,@refund_type_id = 1
  ,@print_coupon = 0
  ,@active = 1
  ,@product_category_id = 1
  ,@product_consumer_type_id = 1

SELECT	'Return Value' = @RC

GO