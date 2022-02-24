USE [Titan]
Go

/*Update product description from '(Blank)' to 'Lost Property Postage' of product id 3077 */

UPDATE [dbo].[tbl_Products] SET [product_description] = 'Lost Property Postage' where product_id = 3077;