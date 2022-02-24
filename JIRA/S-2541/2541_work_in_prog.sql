exec sp_help CMSContent

select * from CMSContent where contentid = 70456;
select * from CMSContent where contentid = 70457;

select * from CMSContent where contentid in (70421, 70422, 70423, 70424);
select * from CMSContent where contentid = 70422;
select * from CMSContent where contentid = 70423;
select * from CMSContent where contentid = 70424;

select * from CMSContent where contentid between 70000 and 79999;

select * from CMSContentTypeMapping where contentid in (70421, 70422, 70423, 70424)

select * from cmscontenttype where cmscontenttypeid in (29,30)

INSERT INTO [WebBooking].[dbo].[CMSContent] (CONTENTID, TITLE, BODY) VALUES(70457, 'Premium Outbound Seat Reservation', '<div class="col-xs-12 col-sm-12 ng-binding"><ul class="infoText"><li>Sit back and relax with a large table, extra recline and up to 50% extra legroom.</li><li>Plus, you’ll be sat on the top deck of our double decker services with the best views possible.</li><li>Reserve your Premium seat from just &#163;5 per person, per journey leg.</li><li>Limited availability - reserve now to guarantee your Premium seat!</li></ul><p><a href="https://www.nationalexpress.com/en/seat-reservation" target="_blank">Only available on selected routes</a></p><p><a href="https://www.nationalexpress.com/en/help/conditions-of-carriage" target="_terms">Terms and conditions</a></p></div>');

INSERT INTO [WebBooking].[dbo].[CMSContentTypeMapping] ( ContentID, CmsContentTypeID) VALUES ( 70457,31);

select * from CMSContentTypeMapping;

exec sp_help CMSContentProduct;

select * from CMSContentProduct where contentid in (70421, 70422, 70423, 70424)

