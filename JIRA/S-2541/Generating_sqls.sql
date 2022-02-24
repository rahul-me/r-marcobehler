USE [WebBooking]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CmsContent_MultiProductAddExtras_ML]
		@SKU = N'H05H036,H05H038,H05H040',
		@LANGUAGECODE = N'EN',
		@OWNERID = N'JavaDevTeam',
		@DEVICEID = N'DesktopJDT',
		@DISPLAYCONTEXT = N'ProductsToSellDesk'

SELECT	'Return Value' = @return_value

GO


----------------------------------------------------------------------

USE [WebBooking]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CmsContent_MultiProductAddExtras_ML]
		@SKU = N'H05H036,H05H038,H05H040',
		@LANGUAGECODE = N'EN',
		@OWNERID = N'TCDevTeam',
		@DEVICEID = N'TCWebBooking',
		@DISPLAYCONTEXT = N'ProductsToSellDesk'

SELECT	'Return Value' = @return_value

GO

--------------------------------------

select * from CMSContentType where DeviceID = 'TCWebBooking'

select * from CMSContentType where DeviceID = 'DesktopJDT'
select * from CMSContentType where OwnerID = 'JavaDevTeam'


DECLARE @contentId int

SELECT @contentId=MAX(CmsContentTypeID) +1 from cmsContentType 

print @contentId

select top 2 * from cmscontent order by contentid desc

select * from cmscontenttype where CmsContentTypeID = 70456

exec sp_help CMSContent
exec sp_help CMSContentTypeMapping

exec sp_help cmscontenttype
select * from cmscontenttype order by cmscontenttypeid desc

DECLARE @contentId int

SELECT @contentId=MAX(CmsContentTypeID) +1 from cmsContentType 
INSERT INTO [WebBooking].[dbo].[CMSContentType] (CmsContentTypeID, Name, OwnerID, DeviceID) VALUES (@contentId, 'ProductsToSellTC', 'TCDevTeam', ' TCWebBooking');
INSERT INTO [WebBooking].[dbo].[CMSContentType] (CmsContentTypeID, Name, OwnerID, DeviceID) VALUES (@contentId, 'ProductsSoldTC', 'TCDevTeam', ' TCWebBooking');

WebBooking.dbo.CMSContentTypeMapping: FK_CMSContentTypeMapping_ContentId

DECLARE @contentId int

SELECT @contentId=MAX(CmsContentTypeID) +1 from [CMSContentType] 
INSERT INTO [WebBooking].[dbo].[CMSContentType] (CmsContentTypeID, Name, OwnerID, DeviceID) VALUES (@contentId, 'ProductsToSellTC', 'TCDevTeam', ' TCWebBooking');

-- INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(70457, 'Premium Outbound Seat Reservation', ' <div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="'_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');                                                                                                  

-- select top 3 * from CMSContent order by contentid desc

-- 70456 79999

select * from cmscontent where contentid between 70000 and 80000

DECLARE @ContentNameSell varchar(10)
DECLARE @ContentNameSold varchar(10)
DECLARE @OwnerId varchar(10)
DECLARE @DeviceId varchar(10)

set @ContentNameSell = 'ProductsToSellTC'
set @ContentNameSold = 'ProductsSoldTC'
set @OwnerId = 'TCDevTeam'
set @DeviceId = 'TCWebBooking'

INSERT INTO [WebBooking].[dbo].[CMSContentType] (Name, OwnerID, DeviceID) VALUES (@ContentNameSell, @OwnerId, @DeviceId);

INSERT INTO [WebBooking].[dbo].[CMSContentType] (Name, OwnerID, DeviceID) VALUES (@ContentNameSold, @OwnerId, @DeviceId);


