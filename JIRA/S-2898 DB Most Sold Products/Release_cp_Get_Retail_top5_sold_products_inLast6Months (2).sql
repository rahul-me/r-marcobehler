USE [Titan]
GO
/****** Object:  StoredProcedure [dbo].[cp_Get_Retail_top5_sold_products_inLast6Months]    Script Date: 17/08/2021 11:26:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- Created By  :  Kavya Parmar
-- Create date  : 17/08/2021   
-- Description  : to fecth the top 5 sold products by agent in last 6 months
--EXEC cp_Get_Retail_top5_sold_products_inLast6Months '1811,1810,20,442,2253,2252,2251,3077,8,9,29,3028','D085'
-- ===========================================================

CREATE PROCEDURE [dbo].[cp_Get_Retail_top5_sold_products_inLast6Months] 
(
 @productIdsList nvarchar(1000),
 @agent varchar(10)
)

AS
BEGIN

DECLARE @AgentID varchar(20);

SELECT @AgentID = agent_id from tbl_agents where agent_code=@agent

DECLARE @sql nvarchar(1500);

SET @sql = 'select top 5 p.product_id,p.[SMART_product_type_code] + p.[SMART_product_code] AS [sku], count(s.sale_id) as TotalSold
    from tbl_Products p WITH (nolock) 
    inner join tbl_Sales_Items si WITH (nolock) on si.product_id = p.product_id and p.product_id in ('+ @productIdsList +')
    inner join tbl_sales s WITH (nolock) on s.sale_id = si.sale_id and s.sale_date >= DATEADD(m, -6, current_timestamp) 
    inner join tbl_agent_users au WITH (nolock) on au.agent_user_id = s.agent_user_id and au.agent_id = '+@AgentID+'   
    group by p.product_id,p.[SMART_product_type_code],p.[SMART_product_code]
    order by TotalSold desc'

EXEC sp_executesql @sql

END
