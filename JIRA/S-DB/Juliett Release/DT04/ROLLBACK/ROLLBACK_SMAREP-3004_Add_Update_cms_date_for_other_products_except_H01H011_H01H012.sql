USE [WebBooking]
GO

DECLARE @contentId int
DECLARE @cmsContent nvarchar(max)
DECLARE @cmsTitle nvarchar(255)

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H01H192' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H01H191' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H01H190' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H60H001' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H24H148' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H24H149' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H24H147' 
DELETE FROM CMSContentTypeMapping WHERE ContentID=@contentId
DELETE FROM CMSContentExtras_ML WHERE ContentID=@contentId
DELETE FROM CMSContentProduct WHERE CONTENTID=@contentId
DELETE FROM CMSContent WHERE CONTENTID=@contentId

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H02H180' 
SET @cmsTitle='Young Persons Coachcards - 1 Year'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Our one-year Young Persons Coachcard is just £12.50* - that''s a little over £1 a month and it''s more than £15 cheaper than a railcard or purchase our three-year Coachcard for £30, which saves you even more and means you have all your travel sorted for your entire time at University.</li><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H03H181' 
SET @cmsTitle='Young Persons Coachcards - 3 Year'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H27H200' 
SET @cmsTitle='Senior Coachcards - 1 Year'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Money-back guarantee</b> –if you don’t save the cost of the card in a year, claim a refund for the full cost of the card. *Terms and conditions apply.</li><li class="nx-extra-bullet-icon"><b>£15 day-return</b> on Tuesdays, Wednesdays and Thursdays to anyWHERE in the UK (excluding airports), just book 3 days in advance of your travel.</li><li class="nx-extra-bullet-icon">We’ll give you <b>a free journey</b> if your coach is delayed for over an hour.</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H27H201' 
SET @cmsTitle='Disabled Coachcards - 1 Year'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Enjoy £15 mid-week day</b> returns on Tuesdays, Wednesdays and Thursdays.</li><li class="nx-extra-bullet-icon">We recommend getting in touch at least 36 hours before you intend to travel with us (WHEREver possible). We can then discuss any assistance needs you have.</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'



