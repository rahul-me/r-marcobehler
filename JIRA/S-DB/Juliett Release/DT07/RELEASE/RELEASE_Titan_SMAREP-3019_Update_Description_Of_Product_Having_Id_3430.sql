USE [Titan]
Go

/*Update product description from 'National Express Ticket' to 'National Express Manual Ticket' of product id 3430 AND SKU H01H012 */

UPDATE [dbo].[tbl_Products] SET [product_description] = 'National Express Manual Ticket' where product_id = 3430;