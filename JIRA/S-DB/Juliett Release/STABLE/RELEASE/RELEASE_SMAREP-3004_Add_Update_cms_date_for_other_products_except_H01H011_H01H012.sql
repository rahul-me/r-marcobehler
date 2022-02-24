USE [WebBooking]
GO

DECLARE @contentId int
DECLARE @cmsContent nvarchar(max)
DECLARE @cmsTitle nvarchar(255)
DECLARE @cmsSKU varchar(45)
DECLARE @productId int

--'Band A Item'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H01H192'
SET @cmsTitle='Band A Item'
SET @cmsContent = '<div><p>Band A items include the following:</p><ul class="list-unstyled"><li>-Smart Phones</li><li>-Suitcases</li><li>-Laptops/Tablets</li><li>-Digital Cameras</li><li>-Musical Instruments</li><li>-Skis/Surfboards</li><li>-Cycles/Skateboards</li></ul><br><p>Please advise your customer this fee does not include postage/repatriation, which if required, shall be charged separately.</p></div>'
SET @productId=2253
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/Band-A-Item.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'Band B Item'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H01H191'
SET @cmsTitle='Band B Item'
SET @cmsContent = '<div><p>Band B items include the following:</p><ul class="list-unstyled"><li>-Passport</li><li>-Wallet/Purse</li><li>-Jewellery items</li><li>-Watch</li></ul><br><p>Please advise your customer this fee does not include postage/repatriation, which if required, shall be charged separately.</p></div>'
SET @productId=2252
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/Band-B-Item.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'Band C Item'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H01H190'
SET @cmsTitle='Band C item'
SET @cmsContent = '<div><p>Band C items include the following:</p><ul class="list-unstyled"><li>-Backpacks</li><li>-Umbrellas</li><li>-Gloves/Scarves/Hats</li><li>-Spectacles</li><li>-Keys</li><li>-Reading books</li><li>-Prams/Pushchairs</li><li>-Clothing items (single item/bag)</li></ul><br><p>Please advise your customer this fee does not include postage/repatriation, which if required, shall be charged separately.</p></div>'
SET @productId=2251
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/Band-C-Item.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'Lost Property Postage'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H60H001'
SET @cmsTitle='Lost Property Postage'
SET @cmsContent = '<div><p>For any customer items to be sent from BCS.</p><p>Please enter the appropriate charge based on the postage fees for this item.</p><p>Please advise your customer that this charge is separate to any handling fees that may apply.</p></div>'
SET @productId=3077
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/Lost-Property-Postage.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'NX Gift Voucher - 10 GBP'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H24H148'
SET @cmsTitle='NX Gift Voucher - 10 GBP'
SET @cmsContent = '<div><p>Please remind your customer of the following Terms & Conditions:</p><p>This gift voucher is valid in whole or part payment for any National Express coach travel ticket or product when presented at an appointed agent.</p><p>It is not valid for travel by itself, and cannot be redeemed through a driver.</p><p>This voucher cannot be replaced if lost, and credit cannot be given for it. Vouchers cannot be exchanged for cash, and no change can be given.</p><p>Refunds of tickets purchased with vouchers will be subject to National Express General Conditions available to view at sales offices and agents or online at <a href ="https://www.nationalexpress.com/en/help/terms-conditions" target="_blank">www.nationalexpress.com/en/help/terms-conditions</a></p></div>'
SET @productId=29
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/NX-Gift-Voucher-10-GBP.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'NX Gift Voucher - 20 GBP'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H24H149'
SET @cmsTitle='NX Gift Voucher - 20 GBP'
SET @cmsContent = '<div><p>Please remind your customer of the following Terms & Conditions:</p><p>This gift voucher is valid in whole or part payment for any National Express coach travel ticket or product when presented at an appointed agent.</p><p>It is not valid for travel by itself, and cannot be redeemed through a driver.</p><p>This voucher cannot be replaced if lost, and credit cannot be given for it. Vouchers cannot be exchanged for cash, and no change can be given.</p><p>Refunds of tickets purchased with vouchers will be subject to National Express General Conditions available to view at sales offices and agents or online at <a href ="https://www.nationalexpress.com/en/help/terms-conditions" target="_blank">www.nationalexpress.com/en/help/terms-conditions</a></p></div>'
SET @productId=30
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/NX-Gift-Voucher-20-GBP.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'NX Gift Voucher - 5 GBP'

SELECT @contentId=MAX(CONTENTID) +1 FROM CMSContent 
SET @cmsSKU='H24H147'
SET @cmsTitle='NX Gift Voucher - 5 GBP'
SET @cmsContent = '<div><p>Please remind your customer of the following Terms & Conditions:</p><p>This gift voucher is valid in whole or part payment for any National Express coach travel ticket or product when presented at an appointed agent.</p><p>It is not valid for travel by itself, and cannot be redeemed through a driver.</p><p>This voucher cannot be replaced if lost, and credit cannot be given for it. Vouchers cannot be exchanged for cash, and no change can be given.</p><p>Refunds of tickets purchased with vouchers will be subject to National Express General Conditions available to view at sales offices and agents or online at <a href ="https://www.nationalexpress.com/en/help/terms-conditions" target="_blank">www.nationalexpress.com/en/help/terms-conditions</a></p></div>'
SET @productId=28
INSERT INTO CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,@cmsTitle,@cmsContent,'n',1)
INSERT INTO CMSContentProduct VALUES(@contentId,@productId,@cmsTitle,@cmsSKU,0,'assets/img/NX-Gift-Voucher-5-GBP.png',NULL)
INSERT INTO CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en',@cmsTitle,@cmsContent,'')
INSERT INTO CMSContentTypeMapping VALUES(@contentId,29)

--'1 Year Young Person Coachcard'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H02H180' 
SET @cmsTitle='1 Year Young Person Coachcard'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Our one-year Young Persons Coachcard is just £12.50* - that''s a little over £1 a month and it''s more than £15 cheaper than a railcard or purchase our three-year Coachcard for £30, which saves you even more and means you have all your travel sorted for your entire time at University.</li><li class="nx-extra-bullet-icon">Save 1/3 on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon">Save 15% on travel to festivals & events</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

--'3 Year Young Person Coachcard'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H03H181' 
SET @cmsTitle='3 Year Young Person Coachcard'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Save 1/3 on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon">Save 15% on travel to festivals & events</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

--'1 Year Senior Coachcard'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H27H200' 
SET @cmsTitle='1 Year Senior Coachcard'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Save 1/3 on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon">Money-back guarantee –if you don’t save the cost of the card in a year, claim a refund for the full cost of the card. *Terms and conditions apply.</li><li class="nx-extra-bullet-icon">£15 day-return on Tuesdays, Wednesdays and Thursdays to anywhere in the UK (excluding airports), just book 3 days in advance of your travel.</li><li class="nx-extra-bullet-icon">We’ll give you a free journey if your coach is delayed for over an hour.</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'

--'1 Year Disabled Coachcard'

SELECT @contentId = CONTENTID FROM CMSContentProduct WHERE ProductkeySmartComposite = 'H27H201' 
SET @cmsTitle='1 Year Disabled Coachcard'
SET @cmsContent = '<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Save 1/3 on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon">Money-back guarantee –if you don’t save the cost of the card in a year, claim a refund for the full cost of the card. *Terms and conditions apply.</li><li class="nx-extra-bullet-icon">£15 day-return on Tuesdays, Wednesdays and Thursdays to anywhere in the UK (excluding airports), just book 3 days in advance of your travel.</li><li class="nx-extra-bullet-icon">We’ll give you a free journey if your coach is delayed for over an hour.</li></ul>'
UPDATE CMSContent SET BODY=@cmsContent, TITLE=@cmsTitle WHERE CONTENTID = @contentId
UPDATE CMSContentExtras_ML SET Body=@cmsContent, Title=@cmsTitle WHERE ContentID = @contentId AND LanguageCode ='en'