USE [WebBooking]
GO

DECLARE @contentId int
DECLARE @cmsContent nvarchar(max)
DECLARE @cmsTitle nvarchar(255)
DECLARE @cmsSKU varchar(45)
DECLARE @productId int

--'European Ticket'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H01H011'
SET @cmsTitle='European Ticket'
SET @cmsContent = '<div><p>To be used when a manual ticket has been issued for travel following a system outage or other extenuating circumstance.</p><p>Please have the manual ticket serial number to hand.</p></div>'
SET @productId=3429
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/European-Ticket.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'National Express Manual Ticket'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H01H012'
SET @cmsTitle='National Express Manual Ticket'
SET @cmsContent = '<div><p>To be used when a manual ticket has been issued for travel following a system outage or other extenuating circumstance.</p><p>Please have the manual ticket serial number to hand.</p></div>'
SET @productId=3430
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/National-Express-Ticket.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)