USE [WebBooking]
GO

DECLARE @contentId int

select @contentId = CONTENTID from CMSContentProduct where ProductkeySmartComposite = 'H02H180' 

DELETE from CMSContentTypeMapping where ContentID=@contentId
DELETE from CMSContentExtras_ML where ContentID=@contentId
DELETE from CMSContentProduct where CONTENTID=@contentId
DELETE from CMSContent where CONTENTID=@contentId


select @contentId = CONTENTID from CMSContentProduct where ProductkeySmartComposite = 'H27H200' 

DELETE from CMSContentTypeMapping where ContentID=@contentId
DELETE from CMSContentExtras_ML where ContentID=@contentId
DELETE from CMSContentProduct where CONTENTID=@contentId
DELETE from CMSContent where CONTENTID=@contentId


select @contentId = CONTENTID from CMSContentProduct where ProductkeySmartComposite = 'H27H201' 

DELETE from CMSContentTypeMapping where ContentID=@contentId
DELETE from CMSContentExtras_ML where ContentID=@contentId
DELETE from CMSContentProduct where CONTENTID=@contentId
DELETE from CMSContent where CONTENTID=@contentId

select @contentId = CONTENTID from CMSContentProduct where ProductkeySmartComposite = 'H03H181' 

DELETE from CMSContentTypeMapping where ContentID=@contentId
DELETE from CMSContentExtras_ML where ContentID=@contentId
DELETE from CMSContentProduct where CONTENTID=@contentId
DELETE from CMSContent where CONTENTID=@contentId