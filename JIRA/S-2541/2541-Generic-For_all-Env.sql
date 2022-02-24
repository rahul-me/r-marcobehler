USE [WebBooking]
GO

--'Premium Outbound Seat Reservation'--

-- Table: [CMSContentType]

DECLARE @ContentNameSell varchar(20)
DECLARE @ContentNameSold varchar(20)
DECLARE @OwnerId varchar(20)
DECLARE @DeviceId varchar(20)

DECLARE @contentTypeIdProdSell INT
DECLARE @contentTypeIdProdSold INT

DECLARE @cmsContentIdProdSell INT

DECLARE @maximumRange INT

SET @ContentNameSell = 'ProductsToSellTC'
SET @ContentNameSold = 'ProductsSoldTC'
SET @OwnerId = 'TCDevTeam'
SET @DeviceId = 'TCWebBooking'

SET @maximumRange = 79999



INSERT INTO [WebBooking].[dbo].[CMSContentType] (Name, OwnerID, DeviceID) VALUES (@ContentNameSell, @OwnerId, @DeviceId);

SET @contentTypeIdProdSell = IDENT_CURRENT ('CMSContentType')

INSERT INTO [WebBooking].[dbo].[CMSContentType] (Name, OwnerID, DeviceID) VALUES (@ContentNameSold, @OwnerId, @DeviceId);

SET @contentTypeIdProdSold = IDENT_CURRENT ('CMSContentType')

-- Table: [CMSContent]

-- Select Maximum content id from CMSContent
SELECT @cmsContentIdProdSell = (MAX(CONTENTID)+1) FROM CMSContent WHERE CONTENTID < @maximumRange;

INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(@cmsContentIdProdSell, 'Premium Outbound Seat Reservation', '<div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');

-- Table: CMSContentTypeMapping

INSERT INTO [WebBooking].[dbo].[CMSContentTypeMapping] ( ContentID, CmsContentTypeID) VALUES (@cmsContentIdProdSell,@contentTypeIdProdSell);

-- Table: CMSContentProduct

INSERT INTO [WebBooking].[dbo].[CMSContentProduct] ( CONTENTID, PRODUCTID, PRODUCTKEY, ProductkeySmartComposite, ProductSelectedByDefault, ProductImageURL, ProductTermsConditionsURL)VALUES (@cmsContentIdProdSell, 3341, 'Premium Outbound Seat Reservation', 'H05H038', 0, NULL, NULL);

-- Table: CMSContentExtras_ML

INSERT INTO [WebBooking].[dbo].[CMSContentExtras_ML] (ContentID, LanguageCode, Title, Body, Summary, USER_COLUMN1, USER_COLUMN2, USER_COLUMN3)VALUES (@cmsContentIdProdSell, 'en', 'Premium Outbound Seat Reservation', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', NULL, NULL, NULL );


---------------------------------------------------------------------------------------------------
--'Premium Return Seat Reservation'--

-- Table: CMSContent

SELECT @cmsContentIdProdSell = (MAX(CONTENTID)+1) FROM CMSContent WHERE CONTENTID < @maximumRange;

INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(@cmsContentIdProdSell, 'Premium Return Seat Reservation', ' <div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');                                                                                                  
                                                                                             
-- Table: CMSContentTypMapping

INSERT INTO [WebBooking].[dbo].[CMSContentTypeMapping] ( ContentID, CmsContentTypeID) VALUES (@cmsContentIdProdSell,@contentTypeIdProdSell);

-- Table: CMSContentProduct

INSERT INTO [WebBooking].[dbo].[CMSContentProduct] ( CONTENTID, PRODUCTID, PRODUCTKEY, ProductkeySmartComposite, ProductSelectedByDefault, ProductImageURL, ProductTermsConditionsURL)VALUES (@cmsContentIdProdSell, 3342, 'Premium Return Seat Reservation', 'H05H039', 0, NULL, NULL);
 
-- Table: CMSContentExtras_ML

INSERT INTO [WebBooking].[dbo].[CMSContentExtras_ML] (ContentID, LanguageCode, Title, Body, Summary, USER_COLUMN1, USER_COLUMN2, USER_COLUMN3)VALUES (@cmsContentIdProdSell, 'en', 'Premium Return Seat Reservation', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', NULL, NULL, NULL );

---------------------------------------------------------------------------------------------------

--'Premium Outbound Seat Reservation'--

--Table: CMSContent

-- Select Maximum content id from CMSContent
SELECT @cmsContentIdProdSell = (MAX(CONTENTID)+1) FROM CMSContent WHERE CONTENTID < @maximumRange;

INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(@cmsContentIdProdSell, 'Premium Outbound Seat Reservation', ' <div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');

-- Table: CMSContentTypMapping

INSERT INTO [WebBooking].[dbo].[CMSContentTypeMapping] ( ContentID, CmsContentTypeID) VALUES (@cmsContentIdProdSell,@contentTypeIdProdSold);

-- Table: CMSContentProduct

INSERT INTO [WebBooking].[dbo].[CMSContentProduct] ( CONTENTID, PRODUCTID, PRODUCTKEY, ProductkeySmartComposite, ProductSelectedByDefault, ProductImageURL, ProductTermsConditionsURL)VALUES (@cmsContentIdProdSell, 3341, 'Premium Outbound Seat Reservation', 'H05H038', 0, NULL, NULL);
 
-- Table: CMSContentExtras_ML

INSERT INTO [WebBooking].[dbo].[CMSContentExtras_ML] (ContentID, LanguageCode, Title, Body, Summary, USER_COLUMN1, USER_COLUMN2, USER_COLUMN3)VALUES (@cmsContentIdProdSell, 'en', 'Premium Outbound Seat Reservation', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', NULL, NULL, NULL );

---------------------------------------------------------------------------------------------------

--'Premium Return Seat Reservation'--

-- Table: CMSContent

-- Select Maximum content id from CMSContent
SELECT @cmsContentIdProdSell = (MAX(CONTENTID)+1) FROM CMSContent WHERE CONTENTID < @maximumRange;

INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(@cmsContentIdProdSell, 'Premium Return Seat Reservation', ' <div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');

-- Table: CMSContentTypMapping

INSERT INTO [WebBooking].[dbo].[CMSContentTypeMapping] ( ContentID, CmsContentTypeID) VALUES (@cmsContentIdProdSell,@contentTypeIdProdSold);

-- Table: CMSContentProduct

INSERT INTO [WebBooking].[dbo].[CMSContentProduct] ( CONTENTID, PRODUCTID, PRODUCTKEY, ProductkeySmartComposite, ProductSelectedByDefault, ProductImageURL, ProductTermsConditionsURL)VALUES (@cmsContentIdProdSell, 3342, 'Premium Return Seat Reservation', 'H05H039', 0, NULL, NULL);
 
-- Table: CMSContentExtras_ML

INSERT INTO [WebBooking].[dbo].[CMSContentExtras_ML] (ContentID, LanguageCode, Title, Body, Summary, USER_COLUMN1, USER_COLUMN2, USER_COLUMN3)VALUES (@cmsContentIdProdSell, 'en', 'Premium Return Seat Reservation', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', '<li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li>', NULL, NULL, NULL );


