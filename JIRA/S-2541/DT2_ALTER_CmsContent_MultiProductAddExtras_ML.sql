USE [WebBooking]
GO

/****** Object:  StoredProcedure [dbo].[CmsContent_MultiProductAddExtras_ML]    Script Date: 8/6/2021 6:55:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Created By : Archi Patel  
-- Create date : 21/04/2020  
-- Reason :  (Ref JIRA BOOK-685) Create CMS SP to take multiple product SKU  
-- =============================================    
-- =============================================  
-- Alter By : Archi Patel  
-- Create date : 15/07/2020  
-- Reason :  (Ref JIRA BOOK-685) (use alreday craeted function [fnGetSplittedTable]and remove [splitCSV] )  
-- =============================================   
-- =============================================  
-- Alter By : Archi Patel  
-- Create date : 16/07/2020  
-- Reason :  (Ref JIRA BOOK-834)(Update summary if specific landuage code related data not there and pick 'en'language code as default)  
-- =============================================   
  
/*  
 sample Data for testing ::   
 --DECLARE @SKU nvarchar(200) = 'H05H028,H05H030,H05H029'  
 --DECLARE @LANGUAGECODE varchar(5) = 'en'  
 --DECLARE @OWNERID varchar(100)= 'JavaDevTeam'   
 --DECLARE @DEVICEID varchar(100)= 'DesktopJDT'  
 --DECLARE @DISPLAYCONTEXT varchar(50)='ProductsToSellDesk'  
   
*/  
ALTER PROCEDURE [dbo].[CmsContent_MultiProductAddExtras_ML] 
  @SKU nvarchar(1000),  
  @LANGUAGECODE varchar(5),  
  @OWNERID varchar(100),   
  @DEVICEID varchar(100),  
  @DISPLAYCONTEXT varchar(50)  

 
AS
Begin
  
SET NOCOUNT ON;  
  
 IF OBJECT_ID('tempdb..#tempProductSKU') IS NOT NULL BEGIN DROP TABLE #tempProductSKU END  
 IF OBJECT_ID(N'tempdb..#tempLang') IS NOT NULL BEGIN DROP TABLE #tempLang END
 
 DECLARE  @tempProductSKU table (SKU varchar(100))       
 INSERT INTO @tempProductSKU    
 SELECT * FROM  [dbo].[fnGetSplittedTable] (@SKU, ',');    
   
  
 SELECT  
  cmsC.CONTENTID  
  ,cmsCE.TITLE AS TITLE  
  ,cmsCE.BODY AS BODY  
  ,cmsC.CMSCONTENTPRIORITYID  
  ,cmsCP.ProductkeySmartComposite AS SKU  
  ,ISNULL(cmsCP.ProductImageURL,'') AS PRODUCTIMAGEURL  
  ,ISNULL(cmsCE.Summary,'') AS SUMMARY  
 INTO #tempLang
 FROM dbo.CMSContent cmsC WITH(NOLOCK)   
  INNER JOIN dbo.CMSContentTypeMapping cmsCTM WITH(NOLOCK) ON cmsC.CONTENTID = cmsCTM.ContentID   
  INNER JOIN dbo.CMSContentType cmsCT WITH(NOLOCK) ON cmsCTM.CmsContentTypeID = cmsCT.CmsContentTypeID   
  LEFT OUTER JOIN dbo.CMSContentProduct cmsCP WITH(NOLOCK) ON cmsCTM.ContentID = cmsCP.CONTENTID  
  LEFT OUTER JOIN dbo.CMSContentExtras_ML cmsCE WITH(NOLOCK) ON cmsC.CONTENTID = cmsCE.ContentID  AND cmsCE.LanguageCode=@LANGUAGECODE  
  INNER JOIN @tempProductSKU TPS  ON TPS.SKU = cmsCP.ProductkeySmartComposite  
 WHERE cmsCT.OwnerID=@OWNERID   
   AND cmsCT.DeviceID=@DEVICEID     
   AND cmsCT.Name = @DISPLAYCONTEXT  
  
  -- Update summary column if specific landuage code not found and pick 'en'language code as default
	UPDATE #tempLang 		
		SET #tempLang.SUMMARY = ce.Summary, #tempLang.TITLE = ce.Title , #tempLang.BODY = ce.Body
	FROM #tempLang tl  
	INNER JOIN CMSContentExtras_ML ce ON tl.CONTENTID= ce.CONTENTID	
	WHERE ISNULL(tl.SUMMARY,'') ='' AND ce.LanguageCode = 'en' 
	
	SELECT * FROM #tempLang	
	
	IF OBJECT_ID('tempdb..#tempProductSKU') IS NOT NULL BEGIN DROP TABLE #tempProductSKU END  
	IF OBJECT_ID(N'tempdb..#tempLang') IS NOT NULL BEGIN DROP TABLE #tempLang END
END  



GO


