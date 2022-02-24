USE [Titan]
Go

/*Update product description from 'Band C Item' to 'Lost Property' of product id 2251 AND SKU H01H190 */

UPDATE [dbo].[tbl_Products] SET [product_description] = 'Lost Property' where product_id = 2251;