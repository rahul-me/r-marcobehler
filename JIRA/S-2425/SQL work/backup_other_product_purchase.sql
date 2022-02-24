USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_RetailAPI_Basket_other_product_Purchase]    Script Date: 5/11/2021 3:13:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================================================
-- Author		:	Urvashi Parmar
-- Create date	:	10-March-2021
-- Description	:	Created procedure to record other product purchase(non travel ticket purchase) (used in TravelCat)
-- ==================================================================================================================

--declare @SaleID Int 
--declare @Message varchar(50) 	
-- declare @RESULT Int 

--EXEC cp_RetailAPI_Basket_other_product_Purchase '<Ticket agentCode="D085" agentUser="RChauhan" salesChannel="Call" ticketNumber="T4JD430"><Addons><Addon><Item_quantity>1</Item_quantity><Item_value>1250</Item_value><new_fare>0</new_fare><old_fare>0</old_fare><SKU>H03H181</SKU><Valid_from>2021-04-05</Valid_from><firstName>Bhavesh</firstName><surName>Kashikar</surName><emailAddress>bkashikar@email.com</emailAddress></Addon><Addon><Item_quantity>1</Item_quantity><Item_value>1250</Item_value><new_fare>0</new_fare><old_fare>0</old_fare><SKU>H03H181</SKU><Valid_from>2021-04-05</Valid_from><firstName>Urvashi</firstName><surName>Parmar</surName><emailAddress>urvashi@email.com</emailAddress></Addon><Addon><Item_quantity>1</Item_quantity><Item_value>600</Item_value><new_fare>0</new_fare><old_fare>0</old_fare><SKU>B06B005</SKU></Addon></Addons><Coachcards><Coachcard serialnumber="1C456325" type="CF"/><Coachcard serialnumber="1C456326" type="ST"/></Coachcards><DistributionDetails distributionType="Local Post Out" email="urvashi.parmar@nationalexpress.com"><PostalAddress><address1>Changan Uk R & D Centre Ltd</address1><address2>Unit 3500, Parkside</address2><address3/><addressTypeId>0</addressTypeId><postcode>B37 7YG</postcode><town>BIRMINGHAM</town></PostalAddress></DistributionDetails><LeadPassenger emailConsent="false" firstName="urvashi" surname="parmar" telephone="" telephoneConsent="false" title="Unkno"><Address><Address1>Changan Uk R & D Centre Ltd</Address1><Address2>Unit 3500, Parkside</Address2><Address3/><AddressTypeID>0</AddressTypeID><PostCode>B37 7YG</PostCode><Town>BIRMINGHAM</Town></Address></LeadPassenger><Passengers><Passenger type="AD"/></Passengers><Payment payment_type="Card" payment_value="1610"><BillingAddress><address1>Billing Address</address1><address2>Unit 3500, Parkside</address2><address3/><addressTypeId>0</addressTypeId><postcode>B37 7YG</postcode><town>BIRMINGHAM</town></BillingAddress><CardPayment card_type="visa" payment_provider="Barclays" payment_provider_transaction_id="8515dss2778456845102"/></Payment></Ticket>'
--,@SaleID output, @Message output,@RESULT output

ALTER procedure [dbo].[cp_RetailAPI_Basket_other_product_Purchase]


@TicketXML ntext
,@SaleID Int output
,@Message varchar(50) OUTPUT	
,@RESULT Int OUTPUT

AS

BEGIN
---- Add Addons

DECLARE @docHandle int

EXEC sp_xml_preparedocument @docHandle OUTPUT, @TicketXML

-- Internal Variables
declare @agent char(5)
declare @user char(8)
declare @agent_user_id int
declare @sale_id int
declare @RC int
DECLARE @sale_item_type_id int
declare @Ticket char(8)
declare @ticket_id int
declare @Channel char(15)
declare @TransType char(3)
declare @JrnyType char(1)
declare @sales_item_transaction_id int
declare @address_id int
declare @consumer_address_id int
declare @payment_provider_transaction_ID int
declare @ITEM_CONSUMER_id int
declare @from_location char(5)
declare @to_location char(5)
declare @departure_date_time datetime
declare @DeptDate int
declare @TicketQueue char(1)
declare @LeadPaxID int
declare @Title_id int
declare @ticket_consumer_id int
declare @errorCheck int
declare @PaymentProvider varchar(40)
DECLARE @tId uniqueidentifier
declare @PaymentAccount varchar(250)
declare @Postaladdress1 varchar(40)
declare @override_reason char(2)
declare @old_fare money
declare @new_fare money
declare @override_description varchar(500)
declare @override_id int
	

INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('Mercury Reservation Request'           
           ,getdate()         
           ,@TicketXML
           )


BEGIN TRAN
 --retrieve agent user ID
	select 
			@Ticket = ticketnumber,
			@agent = agentcode, 
			@user= agentuser,
			@Channel = SalesChannel			

	FROM Openxml( @docHandle , 'Ticket' ) 
	WITH ( 
			ticketnumber	char(8)		'@ticketNumber'
		   ,agentcode		char(5)		'@agentCode'
		   ,agentuser		char(8)		'@agentUser'
		   ,saleschannel	char(15)	'@salesChannel'		   
		   
		   
		 )



-- print 'agent'
-- print @agent
-- print '[user]'
-- print @user
-- print @ticket
-- print @channel


EXECUTE @RC =   [dbo].[cp_Get_Agent_User_ID_V2]
   @agent
  ,@user
  ,@agent_user_id OUTPUT


-- print @agent_user_id

IF (@@ERROR <> 0)
	begin
		--print 'error1'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to get Agent User Id'
	    RAISERROR('Failed to get Agent User Id',10,1)
		GOTO ErrorDetetcted
	end


 -- basket

declare @SalesChannelID int

SELECT 
     @SalesChannelID= isnull([sales_channel_id],2)     
  FROM [NXLookup].[dbo].[tbl_Agent_Sales_Channel]
where agent_code = @Agent order by sales_channel_id

Declare @isRsoMode bit

if @SalesChannelID = 5
BEGIN
	set @isRsoMode= 1
END

-- basket

EXECUTE @RC =   [dbo].[cp_Add_Sale_V2]
   @agent_user_id
  ,0
  ,@SalesChannelID
  ,@sale_id OUTPUT
-- print @sale_id

-- Extract Lead Passenger Details from XML

declare @LeadPaxTitle varchar(5)
declare @LeadPaxFirstName varchar(40)
declare @LeadPaxSurname varchar(40)
declare @LeadPaxTelephone varchar(15)
declare @LeadPaxPostOutConsent bit
declare @LeadPaxEmailConsent bit
declare @LeadPaxTelephoneConsent bit


	select
		@LeadPaxTitle = title
		,@LeadPaxFirstName = firstname
		,@LeadPaxSurname  = surname
		,@LeadPaxTelephone = telephone
		,@LeadPaxPostOutConsent = case PostConsent when 'true' then 1 else 0 end 
		,@LeadPaxEmailConsent = case emailconsent when 'true' then 1 else 0 end 
		,@LeadPaxtelephoneConsent = case phoneconsent when 'true' then 1 else 0 end 
	FROM Openxml( @docHandle , 'Ticket/LeadPassenger' ) 
	WITH ( 
			title			varchar(5)		'@title',
			firstname		varchar(40)	'@firstName',
			surname			varchar(40)	'@surname',
			telephone		varchar(15)	'@telephone',
			PostConsent		char(5)		'@postOutConsent',
			EmailConsent	char(5)		'@emailConsent',
			Phoneconsent	char(5)		'@telephoneConsent')

 --extract Distribution Details

declare @TicketDistributionType varchar(15)
declare @EmailAddress varchar(128)
declare @RemoteCollectLocation varchar(8)

		select
			@TicketDistributionType = distributiontype
			,@EmailAddress = Email
			,@RemoteCollectLocation = isnull(collectionlocation,'')

		FROM OPENXML ( @docHandle , 'Ticket/DistributionDetails' ) 
		with ( 
				distributiontype	varchar(15)	'@distributionType', --distributionType
				email				varchar(128)	'@email',
				collectionlocation	varchar(8)		'@collectionLocation'

				)


select @Title_id = title_id
FROM  dbo.tbl_Titles
				where title = @LeadPaxTitle

declare @ID int
declare @NonTravelProduct_sales_item_id int
declare @Product_id Int
declare @Item_value money
declare @Item_quantity int
declare @AddonCount int
declare @serial varchar(15)
declare @serial_number varchar(8)
declare @ProductConsumerID int
declare @product_sku varchar(10)
declare @firstName varchar(40)
declare @surName varchar(40)
declare @ccEmailAddress varchar(128)
declare @fromdate datetime
declare @todate datetime

---- create table variable
declare @NonTravelProduct table
	( ID int IDENTITY(1,1),
	  SKU char(7),	  
	  Product_id int,
	  categoryCode char(1),	
	  Serial char(15),
	  Item_single_value money,	  
	  Item_quantity int,
	  From_date datetime,
	  To_date datetime,	
	  consumer_id int,
	  override_reason char(2),
	  old_fare money,
	  new_fare money,
	  override_description varchar(500),
	  firstName varchar(40),
	  surName varchar(40),
	  emailAddress varchar(128)
	)

	insert into  @NonTravelProduct
	select
		SKU	
		,p.product_id
		, c.product_category_code
		,isnull(serial,'')		
		,cast(item_value as money) /100
		,item_quantity
		,isnull(Addons.valid_from, '01-Jan-1900 00:00:00')     
		 ,isnull(Addons.valid_to, '01-Jan-1900 00:00:00') 		
		,null
		,override_reason
		,old_fare
		,new_fare
		,override_description
		,firstName
		,surName
		,emailAddress
		
	FROM OpenXML (@docHandle, 'Ticket/Addons/Addon')
	with (
			SKU				char(7)		'SKU',
			serial			varchar(15)	'Serial',
			item_value		int			'Item_value',
			item_quantity	int			'Item_quantity',
			valid_from		datetime	'Valid_from',
			valid_to		datetime	'Valid_to',	
			firstName		varchar(40)	'firstName',	
			surName		varchar(40)	'surName',	
			emailAddress		varchar(128)	'emailAddress',	
			override_reason		char(2)	'override_reason_code',
			old_fare money 'old_fare',
			new_fare money 'new_fare',
			override_description varchar(80) 'override_description'	
			) Addons
		join dbo.tbl_Products P
			on Addons.SKU = (P.SMART_product_type_code + P.SMART_product_code)
		join tbl_product_category c
			on p.product_category_id = c.product_category_id
		set @AddonCount = @@rowcount

if @AddonCount >0 
	BEGIN

----		 loop
		set @ID = 1
		
		while @ID <= @AddonCount -- less than or equal to 
			begin
				select 
					@Product_id = product_id
					,@Item_value = Item_single_value
                    ,@Item_quantity = Item_quantity
					,@Serial = serial
					,@product_sku = SKU
					,@fromDate = From_date
					,@override_reason= override_reason
					,@old_fare= old_fare/100
					,@new_fare= new_fare/100
					,@override_description = override_description
					,@firstName = firstName
					,@surName = surName
					,@ccEmailAddress = emailAddress
				from
					@NonTravelProduct
				where
					ID = @ID


				
				If EXISTS(SELECT 1 from tbl_Product_Duration PD JOIN @NonTravelProduct P on P.Product_id = PD.Product_ID and P.ID = @ID)
				 BEGIN
				
					EXECUTE @RC = [dbo].[cp_Generate_Product_Active_To_Date] 							  
							   @product_id
							  ,@fromDate
							  ,@todate OUTPUT
							 
							if(@todate is not null)
							BEGIN
								update @NonTravelProduct
								set To_date = @todate
								where
									ID= @ID
							END
				 END
				 ----			GENERATE SERIAL NUMBER

                If EXISTS(SELECT 1 from @NonTravelProduct where ID = @ID and categoryCode in('C','P') and isnull(Serial,'') = '')
				BEGIN	

						EXECUTE @RC = [dbo].[cp_Generate_Product_Serial_Number] 
							   @product_id
							  ,@agent
							  ,@serial_number OUTPUT
				
							update @NonTravelProduct
							set serial = @serial_number
							where
								ID= @ID
				
				END
			       
----			 ADD SALES ITEM


			select
				 @Item_Value = Item_single_value
				,@Item_quantity = item_quantity
				,@serial = serial
			from
				@NonTravelProduct
			where
					ID= @ID
				
			EXECUTE @RC =   [dbo].[cp_Add_Sales_Item]
			   @sale_id
			  ,7
			  ,@Product_id
			  ,@ticket
			  ,@Item_Value
			  ,@Item_quantity
			  ,@NonTravelProduct_sales_item_id OUTPUT
			  ,@serial	

----			 aDD ITEM Transaction
			EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
			   @NonTravelProduct_sales_item_id
			  ,14
			  ,@sales_item_transaction_id OUTPUT

			  if (ISNULL(@override_reason,'')<>'')
					BEGIN
							  EXECUTE @RC =   [dbo].[cp_Add_Override]
							  @NonTravelProduct_sales_item_id
							   ,@agent_user_id 
							  ,@override_reason
							  ,@old_fare
							  ,@new_fare
							  ,@override_description							  
							  ,@override_id OUTPUT
					END
		
			  If EXISTS(SELECT 1 from @NonTravelProduct where ID = @ID and categoryCode in('C','P') )
				BEGIN	
		--				add Item Validity except for BritXplorers
					if not exists (SELECT 1 from @NonTravelProduct NTP
											where NTP.ID = @ID
											AND NTP.SKU  IN ('H27H164','H27H165','H27H166'))
					BEGIN
							INSERT INTO [dbo].[tbl_Sale_Item_Validity]
						   ([sale_item_id]
						   ,[from_date]
						   ,[to_date]
						   ,[active]
						   )
							SELECT
								@NonTravelProduct_sales_item_id,
								from_date,
								to_date,
								1
							From
								@NonTravelProduct
							where
								ID = @ID
					END
						
				END	

	--				add Consumer
				INSERT INTO dbo.tbl_Consumers
					   (
					  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
					  related_consumer_id , relation_type_id, Consumer_Role_id, Sale_id
					   )
				 VALUES(                  
						 1
						,@Title_id
						,isnull(@firstName,@LeadPaxFirstName)
						,isnull(@surName,@LeadPaxSurname)
						,0
						,0
						,0
						,getdate()
						,0
						,0
						,10
						,@sale_id )
			
                 
				set @ProductConsumerID = SCOPE_IDENTITY()
	
				update @NonTravelProduct
				set consumer_id = @ProductConsumerID
				where
					ID = @ID
					
					-- This will store coachcard email addresses.
					If EXISTS(SELECT 1 from @NonTravelProduct where ID = @ID and categoryCode in('C','P') )
					BEGIN
						INSERT INTO [dbo].[tbl_Email_Addresses]
						([consumer_id]
						,[email_address]
						,[active]
						,[marketing_consent]
						)
					Select 
					    consumer_id
					   ,emailAddress
					   ,1
					   ,@LeadPaxEmailConsent
					From
						@NonTravelProduct
					where
						ID = @ID
										

					END

				--set address
			  INSERT INTO dbo.tbl_Addresses
					   (
					  address1 ,
					  address2 ,
					  address3 ,
					  town ,
					  county_id ,
					  country_id ,
					  postcode,
					  [AddressTypeID]
		
					   )
				 select                  
				  [address1]
				  ,isnull([address2],'')
				  ,isnull([address3],'')
				  ,isnull([town],'')
				  ,isnull([county_id],0)
				  ,isnull([country_id],0)
				  ,isnull([postcode],'')
				  ,1
				FROM OpenXML ( @docHandle, 'Ticket/LeadPassenger/Address')
					With ( 
							Address1	varchar(40)	'Address1'
							,Address2	varchar(40)	'Address2'
							,Address3	varchar(40)	'Address3'
							,Town		varchar(40)	'Town'
							,PostCode	varchar(8)		'PostCode'
							,County		varchar(40)	'County'
							,Country	varchar(60)	'Country'
						) LPA
					left join dbo.tbl_Countries CO
						on LPA.Country = CO.country
					left join dbo.tbl_Counties COU
						on LPA.County = COU.county

					if @@error <> 0
					begin
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add lead address'
						RAISERROR('Failed to addlead address',11,1)
						GOTO ErrorDetetcted
					End	

					SET @address_id = SCOPE_IDENTITY()


			-- Add Consumer Address record

			 EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]
				   @ProductConsumerID
				  ,@address_id
				  ,0
				  ,0
				  ,1
				  ,@consumer_address_id OUTPUT 

			EXECUTE @RC = [dbo].[cp_Add_Item_Consumer] 
			   @NonTravelProduct_sales_item_id
			  ,@ProductConsumerID
			  ,0
			  ,1
			  ,@ticket_consumer_id OUTPUT
				
	----			 increment loop counter
				-- print @ID
				 
		
		set @ID = @ID +1	
	   end
	end


-- populate ticket_id

select @ticket_id = ticket_id
from
	dbo.tbl_Tickets
where
	ticket_serial = @Ticket


select @LeadPaxID = consumer_id
from @NonTravelProduct
where ID = 1

	


INSERT INTO [dbo].[tbl_Email_Addresses]
           ([consumer_id]
           ,[email_address]
           ,[active]
           ,[marketing_consent]
           )
     Select 
           consumer_id
           ,@EmailAddress
           ,1
           ,@LeadPaxEmailConsent
     From
			@NonTravelProduct
	 where
		ID = 1
			

   if not @LeadPaxTelephone is NULL
				Begin
					INSERT into dbo.tbl_Phone_Contacts
							 (
							consumer_id ,
							number ,
							number_type ,
							marketing_consent ,
							preferred
							 )

					   Values
							(@LeadPaxId ,
							@LeadPaxTelephone ,
							'',
							@LeadPaxTelephoneConsent ,
							1)
				End




DECLARE @BillingAddress1 varchar(40)
			select
			@BillingAddress1 = Address1			

			FROM OPENXML ( @docHandle , 'Ticket/Payment/BillingAddress' ) 
			with ( 
					Address1	varchar(40)	'address1'
				 )

			IF @BillingAddress1 <>''
		    BEGIN		
			 declare @BillingaddressPaxID int
			  declare @BillingaddressID int
			  INSERT INTO dbo.tbl_Consumers
					   (
					  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
					  related_consumer_id , relation_type_id, consumer_role_id, sale_id
					   )
				 SELECT
                   
						1
						,isnull(@Title_id,0)
						,@LeadPaxFirstName
						,@LeadPaxSurname
						,0
						,0
						,0
						,getdate()
						,0
						,0
						,7
						,@sale_id
                 
			if @@error <> 0
			begin
				--print 'error6'
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to add postal Consumer details'
				RAISERROR('Failed to add postal Consumer details',11,1)
				GOTO ErrorDetetcted
			end	

			set @BillingaddressPaxID = SCOPE_IDENTITY()			

						
			--	   add billing address record
			 INSERT INTO dbo.tbl_Addresses
				   (
				  address1 ,
				  address2 ,
				  address3 ,
				  town ,
				  county_id ,
				  country_id ,
				  postcode,
				  [AddressTypeID]		
				   )
			 select        
			  [address1]
			  ,isnull([address2],'')
			  ,isnull([address3],'')
			  ,[town]
			  ,isnull([county_id],0)
			  ,isnull([country_id],0)
			  ,isnull([postcode],'')
			  ,2
			FROM OpenXML ( @docHandle, 'Ticket/Payment/BillingAddress')
				With ( 
						Address1	varchar(40)	'address1'
						,Address2	varchar(40)	'address2'
						,Address3	varchar(40)	'address3'
						,Town		varchar(40)	'town'
						,PostCode	varchar(8)		'postcode'
						,County		varchar(40)	'county'
						,Country	varchar(60)	'country'
					) LPA
				left join dbo.tbl_Countries CO
					on LPA.Country = CO.country
				left join dbo.tbl_Counties COU
					on LPA.County = COU.county

			
				if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add billing address'
					RAISERROR('Failed to add billing address',11,1)
					GOTO ErrorDetetcted
				End

				SET @BillingaddressID = SCOPE_IDENTITY()
			
				--add billing consumer address record(s)                           
			
				EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]
				   @BillingaddressPaxID
				  ,@BillingaddressID
				  ,0
				  ,0
				  ,1
				  ,@consumer_address_id OUTPUT  
				  
				  if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add billing consumer address'
					RAISERROR('Failed to add billing consumer address',11,1)
					GOTO ErrorDetetcted
				End 
			END


--- Add Payment Records

---- Extract from XML

declare @PaymentValue money
declare @PaymentType varchar(20)
declare @PaymentProviderReference varchar(40)
declare @Payment_Provider_Record_id int
declare @payment_type_id int
declare @CardType varchar(20)
declare @Payment_Provider_id int
declare @card_details_id int
declare @MerchantID varchar(20)
declare @TerminalID varchar(20)
declare @AuthCode varchar(20)
declare @LastFour char(4)
declare @transactionId varchar(50)






select  @PaymentValue = cast(payment_value as money)/100
		,@PaymentType = payment_type
		
from OPENXML ( @docHandle,'Ticket/Payment')
With (
		payment_value	int			'@payment_value'
		,payment_type	varchar(20) '@payment_type'
		
	  )

select @payment_type_id = payment_type_id  from dbo.tbl_Payment_Types where payment_type = @PaymentType

-- Check to see if payment by card

if @PaymentType = 'CARD' and @PaymentValue <> 0

BEGIN

	select 
			@PaymentProviderReference = payment_provider_transaction_id
			,@cardtype = card_type
			,@PaymentProvider = payment_provider
			,@MerchantID= merchant_ID 
			,@TerminalID = terminal_id
			,@AuthCode = authorisation_code
			,@LastFour = last4digits
			,@transactionId= transactionId

	FROM OPENXML ( @docHandle,'Ticket/Payment/CardPayment')
	WITH
			(
				payment_provider_transaction_id varchar(40) '@payment_provider_transaction_id'
				,card_type						varchar(20)	'@card_type'
				,payment_provider				varchar(40) '@payment_provider'
				,merchant_ID					varchar(20) '@merchant_ID'
				,terminal_ID					varchar(20) '@terminal_ID'
				,authorisation_code				varchar(20) '@authorisation_code'
				,last4digits					char(4)		'@last4digits'
				,transactionId					char(4)		'@transactionId'
			)
	---- check to see payment transaction record does not already exist
	DECLARE @card_type_id int 	

	
			select 	
				@card_type_id =titan_card_type_id
				,@Payment_Provider_id = CTM.payment_provider_id
			from 
				NXLookup.dbo.tbl_Payment_Provider_Card_Type_Mappings CTM
				join NXLookup.dbo.tbl_Payment_Providers PP
					ON CTM.payment_provider_id = PP.id
						and PP.[name]= @PaymentProvider
						and CTM.provider_specific_card_id = @CardType
		
	
		
			-- CODE FOR ADDITING payment Transaction 
		
			--SET @tId = newid()
			--print 'Params'
			--print @Payment_Provider_id
			--print @tId
			--print @PaymentProviderReference
			--print @cardtype
			--print @ticket
			--print @Channel

			
			
			exec @RC =  cp_insert_payment_provider_transaction_v5 @Payment_Provider_id,@tId,@PaymentProviderReference,@card_type_id,0,'','','',@ticket,@Payment_Provider_Record_id OUTPUT,@transactionId,@isRsoMode, @sale_id

			-- error check
			Set @errorCheck = @@error
			if(@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add payment provider transaction'
					RAISERROR('Failed to add  payment provider transaction',11,1)
					GOTO ErrorDetetcted
				end
			--print 'OUT'
			--print @Payment_Provider_Record_id
				
			----update existing record with Sale_id

			print 'transaction'
			update dbo.tbl_Payment_Provider_Transactions
			set sale_id = @Sale_id
			where unique_transaction_reference = @PaymentProviderReference

			-- error check
			Set @errorCheck = @@error
			if @errorCheck <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to update sale id in payment provider transaction'
					RAISERROR('Failed to update sale id in payment provider transaction',11,1)
					GOTO ErrorDetetcted
				end


			-- Add Card Details
			CREATE TABLE #tmp (CardDate Datetime)
			
			INSERT INTO #tmp
			exec @RC = dbo.cp_Add_Card_Details_v2 
				@card_type_id,
				'',
				'',
				'',
				'',
				1,
				'',
				-1,
				@PaymentProviderReference,
				0,
				@card_details_id OUT

			-- error check
			print 'card'
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add card details'
					RAISERROR('Failed to add card details',11,1)
					GOTO ErrorDetetcted
				end
		 -- add card related details Web
		 DROP TABLE #tmp
	END 


-- PayPal Change
if @PaymentType = 'PayPal'

BEGIN
	Print 'Payment Type is PayPal'
	
	select 
			@PaymentProviderReference = payment_provider_transaction_id
			,@PaymentProvider = payment_provider
			,@PaymentAccount = account
	FROM OPENXML ( @docHandle,'Ticket/Payment/PayPalDetails')
	WITH
			(
				payment_provider_transaction_id varchar(40) '@payment_provider_transaction_id'
				,payment_provider		        varchar(50)	'@payment_provider'
				,account						varchar(250) '@account'
			)
			
	-- Get Payment Provider ID
	select @Payment_Provider_id = id from NXLookup.dbo.tbl_Payment_Providers
										where name = @PaymentProvider
										
	-- Write Payment Provider Transaction Record
	SET @tId = newid()
		--print 'Params'
		--print @Payment_Provider_id
		--print @tId
		--print @PaymentProviderReference
		--print @cardtype
		--print @ticket
		--print @Channel
		exec @RC =  cp_insert_payment_provider_transaction_v3 @Payment_Provider_id,@tId,@PaymentProviderReference,0,0,'','','',@ticket,@Payment_Provider_Record_id OUT

		-- error check
		Set @errorCheck = @@error
		if(@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to add payment provider transaction of paypal'
					RAISERROR('Failed to add payment provider transaction of paypal',11,1)
					GOTO ErrorDetetcted
			end
		--print 'OUT'
		--print @Payment_Provider_Record_id
				
		----update existing record with Sale_id
		update dbo.tbl_Payment_Provider_Transactions
		set sale_id = @Sale_id
		where unique_transaction_reference = @PaymentProviderReference

		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to update sale Id in payment provider transaction of paypal'
					RAISERROR('Failed to  update sale Id in payment provider transaction of paypal',11,1)
					GOTO ErrorDetetcted
			end

END -- end of PayPal Payment Type

if @card_details_id is null set @card_details_id = 0
if @MerchantID is null set @MerchantID = ''
if @TerminalID is null set @TerminalID = ''

---- Add record to tbl_payments
INSERT INTO [dbo].[tbl_Payments]
           ([payment_type_id]
        ,[consumer_id]
           ,[card_details_id]
           ,[authorisation_code]
           ,[merchant_id]
           ,[till_id]
           ,[nmp_id]
           ,[currency_id]
           ,[payment_value]
           ,[date_created]
           ,[sale_id]
           ,[sale_item_id]
           ,[foreign_payment_value]
           ,[payment_provider_id]
           ,[payment_provider_transaction_id]
           )
     VALUES
           (@payment_type_id 
           ,@leadPaxID --@PayingConsumerID
           ,@card_details_id
           ,''
			,''
           ,''
         ,0
           ,0
           ,@PaymentValue
           ,getdate()
           ,@Sale_id
           ,0
           ,0
           ,@Payment_Provider_id
           ,@Payment_Provider_Record_id --this needs sorting 
           )

print 'payment'
---- SAles Item Transaction Payment

EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,7


---- Add Distribution



-- print 'distributiontype' + '-' + @TicketDistributionType

declare @Collection_Location_ID int


select 
	@Collection_Location_ID = Collection_Id
from
	dbo.SMARTCollectionLocationsImport
where
	Collection_Agent=@RemoteCollectLocation

declare @Distribution_Type_ID int

	select @Distribution_Type_ID = distribution_type_id
	from
		dbo.tbl_Ticket_Distribution_Types	
			where distribution_type = @TicketDistributionType




	INSERT INTO [dbo].[tbl_Ticket_Distribution]
           ([ticket_id]
           ,[ticket_type_id]
           ,[distribution_type_id]
           ,[collection_location_id]
           ,[sale_id]
           ,[date_generated])
     Values( @ticket_id
			,1
			,isnull(@Distribution_Type_ID, 0) 
			,isnull(@collection_location_id,0)
			,@sale_id
			,getdate()
			)






---- (1) ETicket
--	if @TicketDistributionType = 'E TICKET'
--		BEGIN
--			set @TicketQueue = 'E'
--		END
	
	

---- (2) mTicket
--	if @TicketDistributionType = 'M TICKET'
--		BEGIN
--
--		set @TicketQueue = 'M'
--		
------		 add sms number
--		INSERT into dbo.tbl_Phone_Contacts
--                 (
--                consumer_id ,
--                number ,
--                number_type ,
--                marketing_consent ,
--                preferred,
--				PhoneTypeID
--                 )
--
--           Values
--                (@LeadPaxId ,
--                @SMSPhoneNo ,
--                '',
--                @LeadPaxTelephoneConsent ,
--                0,
--				5)
--
------		 add to queue
--			EXECUTE @RC = [dbo].[cp_Queue_Add_M_Ticket] 
--					   @sale_id
--					  ,@ticket
--					  ,@SMSPhoneNo
--					  ,'R'
--		END

----	 (3) Post Out
	if @TicketDistributionType = 'Local Post Out'
	BEGIN	
		set @TicketQueue = 'P'
			select
			@Postaladdress1 = Address1			
			
		FROM OPENXML ( @docHandle , 'Ticket/DistributionDetails/PostalAddress' ) 
		with ( 
				Address1	varchar(40)	'address1'
			 )
		 
		DECLARE @additioalProducts BIT
				 
		SET @additioalProducts = 1
			 
		EXEC cp_Queue_Add_Post_Out @sale_id, @Ticket,@agent,@additioalProducts,'','','Q'	 
		
		if @@error <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to add Local Postout QUEUE'
				RAISERROR('Failed to add Local Postout QUEUE',11,1)
				GOTO ErrorDetetcted
			End

		IF @Postaladdress1 <>'' 
		 BEGIN		
		 declare @PostaladdressPaxID int
		  declare @PostaladdressID int
		 INSERT INTO dbo.tbl_Consumers
					   (
					 consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
					  related_consumer_id , relation_type_id, consumer_role_id, sale_id
					   )
				 SELECT
                   
						1
						,isnull(@Title_id,0)
						,@LeadPaxFirstName
						,@LeadPaxSurname
						,0
						,0
						,0
						,getdate()
						,0
						,0
						,8
						,@sale_id
                 
			if @@error <> 0
			begin
				--print 'error6'
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to add postal Consumer details'
				RAISERROR('Failed to add postal Consumer details',11,1)
				GOTO ErrorDetetcted
			end

			set @PostaladdressPaxID = SCOPE_IDENTITY()			
			
			--	   add postal address record
			 INSERT INTO dbo.tbl_Addresses
				   (
				  address1 ,
				  address2 ,
				  address3 ,
				  town ,
				  county_id ,
				  country_id ,
				  postcode,
				  [AddressTypeID]
		
				   )
			 select   
			  [address1]
			  ,isnull([address2],'')
			  ,isnull([address3],'')
			  ,[town]
			  ,isnull([county_id],0)
			  ,isnull([country_id],0)
			  ,isnull([postcode],'')
			  ,3
			FROM OpenXML ( @docHandle, 'Ticket/DistributionDetails/PostalAddress')
				With ( 
						Address1	varchar(40)	'address1'
						,Address2	varchar(40)	'address2'
						,Address3	varchar(40)	'address3'
						,Town		varchar(40)	'town'
						,PostCode	varchar(8)		'postcode'
						,County		varchar(40)	'county'
						,Country	varchar(60)	'country'
					) LPA
				left join dbo.tbl_Countries CO
					on LPA.Country = CO.country
				left join dbo.tbl_Counties COU
					on LPA.County = COU.county

			
				if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add postal address'
					RAISERROR('Failed to add postal address',11,1)
					GOTO ErrorDetetcted
				End
				
				SET @PostaladdressID = SCOPE_IDENTITY()		
	
				--add postal consumer address record(s)                           
				
				 EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]				   
				   @PostaladdressPaxID
				   ,@PostaladdressID
				  ,0
				  ,0
				  ,1
				  ,@consumer_address_id OUTPUT  
				  
				if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add postal consumer address'
					RAISERROR('Failed to add postal consumer address',11,1)
					GOTO ErrorDetetcted
				End 
			END
		
		END	


------ (4) Remote Collect
	if @TicketDistributionType = 'REMOTE COLLECT'
		BEGIN

			set @TicketQueue = 'R'
			-- set default value
			set @departure_date_time = getdate()

			EXECUTE @RC = [dbo].[cp_Queue_Add_Remote_Collect] 
			   @sale_id
			  ,@ticket
			  ,@RemoteCollectLocation
			  ,@departure_date_time
			  ,'R'
		END

---- Add Sales Item Transaction

EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,8




---- Add Summary Records
-- (1) Basket summary
       


       INSERT INTO [dbo] .[tbl_Basket_Summary]
           ([Sale_ID]
           ,[TicketNo]
           ,[Timestamp]
           ,[AgentID]
           ,[ClerkID]
           ,[Transstatus]
           ,[TransType]
           ,[Previous_Sale_ID]
           ,[Highest_Fare_Paid_To_Date]
           ,[Highest_Fare_Paid_To_Date_Outward]
           ,[Highest_Fare_Paid_To_Date_return])
     SElect
            @Sale_id
             ,@ticket
             ,datediff( s,'01-Jan-1970 00:00:00' ,getdate())
             ,@agent
             ,@user
             ,'Q'
			 ,'N'
             ,0
             ,0
             ,0
             ,0

			if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add Basket Summary'
					RAISERROR('Failed to add Basket Summary',11,1)
					GOTO ErrorDetetcted
				End
--(2) Journey Summary
      
        INSERT INTO [dbo].[tbl_Journey_Summary]
           ([Sale_ID]
           ,[Faretype]
           ,[FareValue]
           ,[TicketType]
           ,[TicketQueue]
           ,[CollectionLoc]
           ,[Destination]
           ,[DeptDate])
         VALUES
           (@sALE_id
           ,''
          ,0
          ,'N'
          ,@TicketQueue
          ,@RemoteCollectLocation
          ,''
          ,0)
        
		if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add Journey Summary'
					RAISERROR('Failed to add Journey Summary',11,1)
					GOTO ErrorDetetcted
				End

--(3) Paying Consumer
            INSERT INTO [dbo].[tbl_Basket_Paying_Consumer]
           ([Sale_ID]
           ,[PaymentValue]
           ,Title
           ,[Initials]
           ,[Surname]
           ,[Deladdr1]
           ,[Deladdr2]
           ,[Deldist]
           ,[Deltown]
           ,[Delcounty]
           ,[Delpostcode]
           ,[Telnoday]
           ,[Telnoeve]
           ,[Emailaddress])   

            Select 
				@Sale_id
				,(@PaymentValue *100)
				,@LeadPaxTitle
				,substring(@LeadPaxFirstname,1,1)
				,@LeadPaxSurname
				,isnull(Address1,'')
				,isnull(Address2,'')
				,isnull(Address3,'')
				,isnull(Town,'')
				,isnull(County,'')
				,isnull(PostCode,'')
				,isnull(@LeadPaxTelephone,'')
				,''
				,isnull(@Emailaddress,'')
		FROM OpenXML ( @docHandle, 'Ticket/LeadPassenger/Address')
			With ( 
					Address1	char(40)	'Address1'
					,Address2	char(40)	'Address2'
					,Address3	char(40)	'Address3'
					,Town		char(40)	'Town'
					,PostCode	char(8)		'PostCode'
					,County		char(40)	'County'
				) LPA
             
	  Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to insert record into paying counsumer basket'
					RAISERROR('Failed to insert record into paying counsumer basket',11,1)
					GOTO ErrorDetetcted
			end
		
             

--(4) Misc Info
        INSERT INTO [dbo].[tbl_Misc_Basket_Info]
           ([Sale_ID]
           ,[Alteration_Fee]
           ,[OverrideReason]
           ,[OverridingClerk]
           ,[InsuranceAmount]
           ,[Passownrisk])
    
        VaLUES ( @Sale_id
                    ,0
                    ,''
                    ,''
                    ,0
                    ,0 )
        
		if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add Misc Basket Info'
					RAISERROR('Failed to add Misc Basket Info',11,1)
					GOTO ErrorDetetcted
				End		

INSERT INTO dbo.tbl_Discounts_Applied   --- SMAREP-1739 - UP
					   (
					  discount_code ,
					  campaign_code ,
					  value ,
					  sale_id,
					  ProductSKU,
					  CampaignID
					)
				 select                  
				  [discountCode]
				  ,[campaignCode]
				  ,[value] / 100
				  ,@sale_id
				  ,productSKU
				  ,campaignID
				FROM OpenXML ( @docHandle, 'Ticket/Discounts/Discount')
					With ( 
							discountCode char(50) '@discountCode',
							campaignCode char(50) '@campaignCode',
							value	decimal(10,2) '@value',
							productSKU char(7)    '@productSKU',
							campaignID int        '@campaignID'
						) 
				if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add Discount applied'
					RAISERROR('Failed to add Discount applied',11,1)
					GOTO ErrorDetetcted
				End		

 --Close Basket
EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,10



select @SaleID = @sale_id
select @RESULT = 1
select @Message = 'Product Purchase Added Successfully'
EXEC sp_xml_removedocument @docHandle
COMMIT TRAN
GOTO Ending

	

ErrorDetetcted:
		--SELECT 'ErrorDetetcted';
		ROLLBACK TRAN
		SET @RESULT = 0
GOTO Ending

Ending:

END


GO

