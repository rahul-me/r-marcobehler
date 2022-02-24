select * from CMSContentTypeMapping where contentid = 70457

select * from CMSContentProduct where contentid in (70421, 70422, 70423, 70424);

select * from CMSContentProduct where contentid = 70457

exec sp_help CMSContentProduct

INSERT INTO [WebBooking].[dbo].[CMSContentProduct] ( CONTENTID, PRODUCTID, PRODUCTKEY, ProductkeySmartComposite, ProductSelectedByDefault, ProductImageURL, ProductTermsConditionsURL)VALUES (70457, 3341, 'Premium Outbound Seat Reservation', 'H05H038', 0, NULL, NULL);

INSERT INTO [WebBooking].[dbo].[CMSContentExtras_ML] (ContentID, LanguageCode, Title, Body, Summary, USER_COLUMN1, USER_COLUMN2, USER_COLUMN3)VALUES (70457, 'en', 'Premium Outbound Seat Reservation', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', NULL, NULL, NULL );

select * from CMSContentType where ownerid = 'TCDevTeam'

select * from CMSContentTypeMapping where contentid = 70457

select max(contentid) from cmscontent where contentid < 79999

select * from CMSContentType where Name in ('ProductsToSellTC', 'ProductsSoldTC')

select * from CMSContentTypeMapping where cmscontenttypeid in (31,32)

select * from CMSContentTypeMapping where contentid in (70421, 70422, 70423, 70424)

select * from CMSContent where contentid in (70421, 70422, 70423, 70424);

select * from CMSContent where contentid between 70000 and 79999;

select * from cmscontent where title = 'Premium Outbound Seat Reservation'

select * from CMSContentTypeMapping M inner join CMSContent C on M.contentid = C.contentid where M.contentid in (70421, 70422, 70423, 70424)
select * from CMSContentTypeMapping M inner join CMSContent C on M.contentid = C.contentid where M.contentid in (70457, 70458, 70459, 70460)

select * from CMSContentExtras_ML where contentid = 70457

exec sp_help CMSContentType
exec sp_help CMSContentTypeMapping
exec sp_help CMSContentProduct
exec sp_help CMSContentExtras_ML


select CT.CmsContentTypeID, CTM.CmsContentTypeMappingID, CTM.ContentId, CE.ID from CMSContentTypeMapping CTM INNER JOIN CMSContentType CT on CTM.CmsContentTypeID = CT.CMSContentTypeID INNER JOIN CMSContentExtras_ML CE on CE.ContentID = CTM.ContentID WHERE CT.CMSContentTypeID in (SELECT CMSContentTypeID FROM CMSContentType WHERE OwnerID = 'TCDevTeam'); 
select CT.CmsContentTypeID, CTM.CmsContentTypeMappingID from CMSContentTypeMapping CTM INNER JOIN CMSContentType CT on CTM.CmsContentTypeID = CT.CMSContentTypeID WHERE CT.CMSContentTypeID in (SELECT CMSContentTypeID FROM CMSContentType WHERE OwnerID = 'TCDevTeam'); 

select * from cmscontent where contentid in (70457, 70458)

-- select * from cmscontent C inner join CMSContentTypeMapping CTM on CTM.



DECLARE @DeleteIds TABLE (CMSContentTypeID INT, CMSContentTypeMappingID INT, ContentID INT, CMSContentExtras_ML_ID INT)

INSERT INTO @DeleteIds (CMSContentTypeID, CMSContentTypeMappingID, ContentID, CMSContentExtras_ML_ID)
SELECT CT.CmsContentTypeID, CTM.CmsContentTypeMappingID, CTM.ContentId, CE.ID 
	FROM CMSContentTypeMapping CTM 
		INNER JOIN CMSContentType CT on CTM.CmsContentTypeID = CT.CMSContentTypeID 
		INNER JOIN CMSContentExtras_ML CE on CE.ContentID = CTM.ContentID 
			WHERE CT.CMSContentTypeID in (SELECT CMSContentTypeID FROM CMSContentType WHERE OwnerID = 'TCDevTeam');

SELECT DISTINCT(CMSContentTypeID) from @DeleteIds;
SELECT DISTINCT(CMSContentTypeMappingID) from @DeleteIds;
SELECT DISTINCT(ContentID) FROM @DeleteIds;
SELECT DISTINCT(CMSContentExtras_ML_ID) FROM @DeleteIds;

-- SELECT * FROM @DeleteIds;

-- 31	995	70457	988
-- 31	996	70458	989
-- 32	997	70459	990
-- 32	998	70460	991

DELETE FROM CMSContentExtras_ML WHERE ID IN (SELECT DISTINCT(CMSContentExtras_ML_ID) FROM @DeleteIds);
DELETE FROM CMSContentProduct WHERE CONTENTID IN (SELECT DISTINCT(ContentID) FROM @DeleteIds);
DELETE FROM CMSContentTypeMapping WHERE CmsContentTypeMappingID IN (SELECT DISTINCT(CMSContentTypeMappingID) from @DeleteIds);
DELETE FROM CMSContent WHERE CONTENTID IN (SELECT DISTINCT(ContentID) FROM @DeleteIds);
DELETE FROM CMSContentType WHERE CmsContentTypeID IN (SELECT DISTINCT(CMSContentTypeID) from @DeleteIds);

-- select * from fnGetSplittedTable


-- JavaDevTeam-- -- 

DECLARE @DeleteIds TABLE (CMSContentTypeID INT, CMSContentTypeMappingID INT, ContentID INT, CMSContentExtras_ML_ID INT)

INSERT INTO @DeleteIds (CMSContentTypeID, CMSContentTypeMappingID, ContentID, CMSContentExtras_ML_ID)
SELECT CT.CmsContentTypeID, CTM.CmsContentTypeMappingID, CTM.ContentId, CE.ID 
	FROM CMSContentTypeMapping CTM 
		INNER JOIN CMSContentType CT on CTM.CmsContentTypeID = CT.CMSContentTypeID 
		INNER JOIN CMSContentExtras_ML CE on CE.ContentID = CTM.ContentID 
			WHERE CT.CMSContentTypeID in (SELECT CMSContentTypeID FROM CMSContentType WHERE OwnerID = 'JavaDevTeam');

SELECT * FROM @DeleteIds;

SELECT CT.CmsContentTypeID, CTM.CmsContentTypeMappingID, CTM.ContentId, CE.ID, CP.ProductkeySmartComposite 
	FROM CMSContentTypeMapping CTM 
		INNER JOIN CMSContentType CT on CTM.CmsContentTypeID = CT.CMSContentTypeID 
		INNER JOIN CMSContentExtras_ML CE on CE.ContentID = CTM.ContentID
		INNER JOIN CMSContentProduct CP ON CP.CONTENTID = CTM.ContentID
			WHERE CT.CMSContentTypeID in (SELECT CMSContentTypeID FROM CMSContentType WHERE OwnerID = 'JavaDevTeam')
				AND CP.ProductkeySmartComposite IN ('H05H039','H05H038');
