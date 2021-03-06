USE [Titan]
GO

DECLARE	@return_value int,
		@SaleID int,
		@Message varchar(50),
		@RESULT int

EXEC	@return_value = [dbo].[cp_retail_other_product_purchase]
		@TicketXML = N'<Ticket agentCode="D085" agentUser="RChauhan" salesChannel="Call" ticketNumber="U2002513"> <Addons> <Addon> <Item_quantity>1</Item_quantity> <Item_value>0</Item_value> <new_fare>0</new_fare> <old_fare>250</old_fare> <override_description>afdsfsd</override_description> <override_reason_code>C</override_reason_code> <SKU>B02B002</SKU> </Addon> <Addon> <Item_quantity>1</Item_quantity> <Item_value>0</Item_value> <new_fare>0</new_fare> <old_fare>250</old_fare> <override_description>afdsfsd</override_description> <override_reason_code>C</override_reason_code> <SKU>H42H240</SKU> </Addon> <Addon> <emailAddress>rahul.chauhan@nationalexpress.com</emailAddress> <firstName>Rahu</firstName> <Item_quantity>1</Item_quantity> <Item_value>0</Item_value> <new_fare>0</new_fare> <old_fare>1250</old_fare> <override_description>afdsfsd</override_description> <override_reason_code>C</override_reason_code> <SKU>H27H200</SKU> <surName>Chauhan</surName> <Valid_from>2021-05-22 00:00:00</Valid_from> </Addon> <Addon> <emailAddress>rahul.chauhan@nationalexpress.com</emailAddress> <firstName>Maunish</firstName> <Item_quantity>1</Item_quantity> <Item_value>0</Item_value> <new_fare>0</new_fare> <old_fare>1250</old_fare> <override_description>afdsfsd</override_description> <override_reason_code>C</override_reason_code> <SKU>H27H201</SKU> <surName>Soni</surName> <Valid_from>2021-05-15 00:00:00</Valid_from> </Addon> </Addons> <Discounts /> <DistributionDetails distributionType="Local Post Out" email="rahul.chauhan@nationalexpress.com" /> <LeadPassenger emailConsent="false" firstName="Rahu" surname="Chauhan" telephone="4411111111" telephoneConsent="false" title="Mr"> <Address> <Address1>WS Davies &amp; Son</Address1> <Address2>Harwood On Teviot Farm</Address2> <Address3 /> <AddressTypeID>0</AddressTypeID> <PostCode>TD90JY</PostCode> <Town>HAWICK</Town> </Address> </LeadPassenger> <Payment payment_type="Cash" payment_value="0"> <BillingAddress> <address1>WS Davies &amp; Son</address1> <address2>Harwood On Teviot Farm</address2> <address3 /> <addressTypeId>0</addressTypeId> <postcode>TD90JY</postcode> <town>HAWICK</town> </BillingAddress> </Payment> </Ticket>',
		@SaleID = @SaleID OUTPUT,
		@Message = @Message OUTPUT,
		@RESULT = @RESULT OUTPUT

SELECT	@SaleID as N'@SaleID',
		@Message as N'@Message',
		@RESULT as N'@RESULT'

SELECT	'Return Value' = @return_value

GO
