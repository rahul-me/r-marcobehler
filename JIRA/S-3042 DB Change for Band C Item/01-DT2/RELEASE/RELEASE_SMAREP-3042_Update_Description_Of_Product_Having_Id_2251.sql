USE [Titan]
Go

/*Update product description from 'Lost Property' to 'Band C Item' of product id 2251 AND SKU H01H190 */

UPDATE [dbo].[tbl_Products] SET [product_description] = 'Band C Item' where product_id = 2251;