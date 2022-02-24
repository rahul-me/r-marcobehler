USE [WebBooking]
GO

--'Young Persons Coachcards - 1 Year

DECLARE @contentId int

SELECT @contentId=MAX(CONTENTID) +1 from CMSContent 



INSERT into CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,'Young Persons Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Our one-year Young Persons Coachcard is just £12.50* - that''s a little over £1 a month and it''s more than £15 cheaper than a railcard or purchase our three-year Coachcard for £30, which saves you even more and means you have all your travel sorted for your entire time at University.</li><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>','n',1)

Insert into CMSContentProduct VALUES(@contentId,20,'Young Persons Coachcards - 1 Year','H02H180',0,'assets/img/CoachcardProduct-YoungPerson.png',NULL)

INSERT into CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en','Young Persons Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon">Our one-year Young Persons Coachcard is just £12.50* - that''s a little over £1 a month and it''s more than £15 cheaper than a railcard or purchase our three-year Coachcard for £30, which saves you even more and means you have all your travel sorted for your entire time at University.</li><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>','')

INSERT into CMSContentTypeMapping VALUES(@contentId,29)


--Senior Coachcards - 1 Year

SELECT @contentId=MAX(CONTENTID) +1 from CMSContent 

INSERT into CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,'Senior Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Money-back guarantee</b> –if you don’t save the cost of the card in a year, claim a refund for the full cost of the card. *Terms and conditions apply.</li><li class="nx-extra-bullet-icon"><b>£15 day-return</b> on Tuesdays, Wednesdays and Thursdays to anywhere in the UK (excluding airports), just book 3 days in advance of your travel.</li><li class="nx-extra-bullet-icon">We’ll give you <b>a free journey</b> if your coach is delayed for over an hour.</li></ul>','n',1)

Insert into CMSContentProduct VALUES(@contentId,1810,'Senior Coachcards - 1 Year','H27H200',0,'assets/img/CoachcardProduct-Senior.png',NULL)

INSERT into CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en','Senior Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Money-back guarantee</b> –if you don’t save the cost of the card in a year, claim a refund for the full cost of the card. *Terms and conditions apply.</li><li class="nx-extra-bullet-icon"><b>£15 day-return</b> on Tuesdays, Wednesdays and Thursdays to anywhere in the UK (excluding airports), just book 3 days in advance of your travel.</li><li class="nx-extra-bullet-icon">We’ll give you <b>a free journey</b> if your coach is delayed for over an hour.</li></ul>','')

INSERT into CMSContentTypeMapping VALUES(@contentId,29)


--Disabled Coachcards - 1 Year

SELECT @contentId=MAX(CONTENTID) +1 from CMSContent 

INSERT into CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,'Disabled Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Enjoy £15 mid-week day</b> returns on Tuesdays, Wednesdays and Thursdays.</li><li class="nx-extra-bullet-icon">We recommend getting in touch at least 36 hours before you intend to travel with us (wherever possible). We can then discuss any assistance needs you have.</li></ul>','n',1)

Insert into CMSContentProduct VALUES(@contentId,1811,'Disabled Coachcards - 1 Year','H27H201',0,'assets/img/CoachcardProduct-Disabled.png',NULL)

INSERT into CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en','Disabled Coachcards - 1 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Enjoy £15 mid-week day</b> returns on Tuesdays, Wednesdays and Thursdays.</li><li class="nx-extra-bullet-icon">We recommend getting in touch at least 36 hours before you intend to travel with us (wherever possible). We can then discuss any assistance needs you have.</li></ul>','')

INSERT into CMSContentTypeMapping VALUES(@contentId,29)


--Young Persons Coachcards - 3 Year

SELECT @contentId=MAX(CONTENTID) +1 from CMSContent 

INSERT into CMSContent(CONTENTID, TITLE,BODY,DISABLED,CMSCONTENTPRIORITYID) VALUES(@contentId,'Young Persons Coachcards - 3 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>','n',1)

Insert into CMSContentProduct VALUES(@contentId,442,'Young Persons Coachcards - 3 Year','H03H181',0,'assets/img/CoachcardProduct-YoungPerson.png',NULL)

INSERT into CMSContentExtras_ML(ContentID,LanguageCode,Title,Body,Summary)  VALUES(@contentId,'en','Young Persons Coachcards - 3 Year','<ul class="list-unstyled"><li class="nx-extra-bullet-icon"><b>Save 1/3</b> on Standard and Fully Flexible fares, even at peak times.</li><li class="nx-extra-bullet-icon"><b>Save 15%</b> on travel to festivals & events</li></ul>','')

INSERT into CMSContentTypeMapping VALUES(@contentId,29)



