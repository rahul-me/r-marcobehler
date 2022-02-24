USE [Titan]
Go


Declare @maxorder int 
select @maxorder = max(ProductPriorityOrder) from tbl_Product_Additional_Data

set @maxorder = @maxorder + 1000
UPDATE tbl_Product_Additional_Data SET ProductPriorityOrder = @maxorder where SKU='H27H200'

set @maxorder = @maxorder + 1000
UPDATE tbl_Product_Additional_Data SET ProductPriorityOrder = @maxorder where SKU='H27H201'

set @maxorder = @maxorder + 1000
UPDATE tbl_Product_Additional_Data SET ProductPriorityOrder = @maxorder where SKU='H02H180'

set @maxorder = @maxorder + 1000
UPDATE tbl_Product_Additional_Data SET ProductPriorityOrder = @maxorder where SKU='H03H181'



