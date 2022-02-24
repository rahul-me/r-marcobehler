USE [Titan]
Go

/*Rollback Update product description from 'Lost Property Postage' to '(Blank)' of product id 3077 */

UPDATE [dbo].[tbl_Products] SET [product_description] = '(Blank)' where product_id = 3077;