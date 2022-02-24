USE [Titan]
GO

IF object_id(N'[dbo].[cp_Get_Retail_sold_products_search]','P') is not null
BEGIN
	DROP PROC [dbo].cp_Get_Retail_sold_products_search
	PRINT 'PROCEDURE [dbo].cp_Get_Retail_sold_products_search DROPPED SUCCESSFULLY'
END