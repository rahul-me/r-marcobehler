
DECLARE @productId int

SELECT @productId = product_id FROM [dbo].[tbl_products] 
WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H192';

select * from  tbl_products  where product_id = @productId;
select * from tbl_Product_Prices where product_id = @productId;

SELECT @productId = product_id FROM [dbo].[tbl_products] 
WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H191';

select * from  tbl_products  where product_id = @productId;
select * from tbl_Product_Prices where product_id = @productId;

SELECT @productId = product_id FROM [dbo].[tbl_products] 
WHERE [SMART_product_type_code] = 'H01' AND [SMART_product_code] = 'H190';

select * from  tbl_products  where product_id = @productId;
select * from tbl_Product_Prices where product_id = @productId;

SELECT @productId = product_id FROM [dbo].[tbl_products] 
WHERE [SMART_product_type_code] = 'H60' AND [SMART_product_code] = 'H001';

select * from  tbl_products  where product_id = @productId;
select * from tbl_Product_Prices where product_id = @productId;




