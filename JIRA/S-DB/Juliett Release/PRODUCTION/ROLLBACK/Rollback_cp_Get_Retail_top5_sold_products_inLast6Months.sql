USE [Titan]
GO

IF object_id(N'[dbo].[cp_Get_Retail_top5_sold_products_inLast6Months]','P') is not null
BEGIN
	DROP PROC [dbo].cp_Get_Retail_top5_sold_products_inLast6Months
	PRINT 'PROCEDURE [dbo].cp_Get_Retail_top5_sold_products_inLast6Months DROPPED SUCCESSFULLY'
END