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