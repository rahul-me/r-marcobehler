USE [WebBooking]
GO

DECLARE @contentId int

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H01H011' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H01H012' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId