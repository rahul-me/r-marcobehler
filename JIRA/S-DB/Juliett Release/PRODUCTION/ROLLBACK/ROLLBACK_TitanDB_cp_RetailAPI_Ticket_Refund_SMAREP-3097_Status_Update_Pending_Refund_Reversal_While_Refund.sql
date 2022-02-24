USE [Titan]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================== Change History =====================================
--Author:     Urvashi Parmar
--Created date: 20/01/2020	
--Description: created stored procedure to record refund
-- ===================================================================
--Author:     Kinnal Parmar
--Modified DAte: 04/03/2020	
--Description: added validation for already refunded ticket
-- ===================================================================
-- Author : Bhavesh Kashikar
-- Modified Date : 02nd July 2020
-- Fixed wrong condition of payment provider id 
-- Commneted entry mode id code it is not required.
-- ===================================================================
-- Author : Bhavesh Kashikar
-- Modified Date : 03rd July 2020
-- Fixed inserting paypla and amazon email address in tbl_payment_account
-- ===================================================================
-- Author		:	Kajal Patel
-- Modified date:	06-Nov-2020
-- Description	:	SMAREP-1836 : Hardcoded TravelCAT SalesChannelCode for contactcenter transaction to identify transactions done by TravelCAT application.
-- ============================================================================================
-- Sample Execution Script	: 
--<Ticket ticketNumber="E2JD3845" agentCode="D085" agentUser="sys" salesChannel="Call"> <Refund refundPrice="200" override_reason_code="" old_fare="0" new_fare="0"><RefundItems><Item productSKU="H01H001" refund_value="1460" quantity="1"> </Item></RefundItems><Payments><Payment><originalPaymentId>66461953</originalPaymentId><merchant_id>0</merchant_id><currency_Type>GBP</currency_Type><payment_Value>200</payment_Value><foreign_payment_value>200</foreign_payment_value><payment_Provider>Barclays</payment_Provider><unique_transaction_reference>jdfhdighdddddfigduigdfidfj</unique_transaction_reference><transaction_label>U20003605sdfdgdg</transaction_label> </Payment></Payments></Refund></Ticket>',@SaleID,@Message,@Result
-- =============================================================================================

ALTER PROCEDURE [dbo].[cp_RetailAPI_Ticket_Refund]
(
	 @RefundXML ntext
	,@SaleID Int output
	,@Message varchar(100) OUTPUT	
	,@RESULT Int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @docHandle int

	EXEC sp_xml_preparedocument @docHandle OUTPUT, @RefundXML

	
	DECLARE @FirstSaleID int,  @previous_sale_id int
	DECLARE @sale_id int
	DECLARE @agent_user_id int
	DECLARE @sales_channel_id int	
	DECLARE @agent_code char(5)
	DECLARE @user char(8)		
	DECLARE @Channel char(15)	
	DECLARE @card_number char(20)
	DECLARE @card_start_date char(10)
	DECLARE @card_end_date char(10)
	DECLARE @card_holder char(30)	
	DECLARE @issue_number char(2)		
	DECLARE @card_details_id int	
	DECLARE @currency_id int
	DECLARE @RefundValue money	
	DECLARE @Ticket char(8)
	DECLARE @refund_item_transaction_id int
	DECLARE @Count int
	DECLARE @Refund_item_type_id int
	DECLARE @sp_retVal int
	SET @Refund_item_type_id = 5

	INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('Add Mercury Refund'           
           ,getdate()         
           ,@RefundXML
           )
	
	BEGIN TRANSACTION

	SELECT 
			@Ticket = ticketnumber,
			@user= agentuser,
			@Channel = SalesChannel,			
			@agent_code = agentcode		
	FROM Openxml( @docHandle , 'Ticket' ) 
	WITH ( 
			ticketnumber	char(8)		'@ticketNumber'
		   ,agentcode		char(5)		'@agentCode'
		   ,agentuser		char(8)		'@agentUser'
		   ,saleschannel	char(15)	'@salesChannel'	 		   
		   
		 )
		 	
	SELECT  @FirstSaleID = min(sale_id)	
	FROM
      dbo .tbl_Sales_Items SI
       join dbo. tbl_Item_Serial_Link ISL
             on ISL. item_serial_id = si .item_serial_id
       join dbo. tbl_Tickets T
             on T. ticket_id = ISL .ticket_id
                   and ticket_serial = @ticket
	
	SELECT @Previous_Sale_ID = Max(Sale_ID)
				FROM
      dbo .tbl_Sales_Items SI
       join dbo. tbl_Item_Serial_Link ISL
             on ISL. item_serial_id = si .item_serial_id
       join dbo. tbl_Tickets T
             on T. ticket_id = ISL .ticket_id
                   and ticket_serial = @ticket
				   
    SELECT @Count = count(*) 
	FROM dbo.tbl_Sales_Items 
	WHERE sale_item_type_id = @Refund_item_type_id AND sale_id in (Select Sale_ID from dbo.tbl_Basket_Summary where TicketNo = @Ticket)
	
	--IF (@Count > 0)

	--	BEGIN		
	--	    SET @SaleID=0
 --    		SET @Message = 'This Ticket is already refunded'
	--		SET @RESULT=0
	--		RAISERROR('This Ticket is already refunded',10,1)
	--		GOTO ErrorDetetcted
	--	END

	EXECUTE @sp_retVal =   [dbo].[cp_Get_Agent_User_ID_V2]
	   @agent_code
	  ,@user
	  ,@agent_user_id OUTPUT

	  IF (@sp_retVal <> 0)
	  BEGIN
		--print 'error1'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to get Agent User Id'
	    RAISERROR('Failed to get Agent User Id',10,1)
		GOTO ErrorDetetcted
	  END
	  
	  -- SMAREP-1836 :  : Replace ChannelCode CALL with TCAT
	  IF @Channel = 'CALL'
		BEGIN
			SET @Channel = 'TCAT';
		END

	  SELECT   @sales_channel_id= [sales_channel_id] FROM [NXLookup].[dbo].[tbl_Sales_Channels] where sales_channel_code=@Channel

	   IF (@@ERROR <> 0)
	   BEGIN
		--print 'error1'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to get sales channel Id'
	    RAISERROR('Failed to get channel Id',10,1)
		GOTO ErrorDetetcted
	  END

	  Declare @isRsoMode bit
		IF @sales_channel_id = 5
		BEGIN
			SET @isRsoMode= 1
		END
			


	EXECUTE @sp_retVal =   [dbo].[cp_Add_Sale_V2]
	   @agent_user_id
	  ,0
	  ,@sales_channel_id
	  ,@sale_id OUTPUT
	
	 IF @sp_retVal <> 0
		BEGIN
			--print 'error2'
			EXEC sp_xml_removedocument @docHandle
			 SET @Message = 'Failed to create new Sale record'
			RAISERROR('Failed to create new Sale record',11,1)
			GOTO ErrorDetetcted
	END

	
	DECLARE @Refund_override_reason char(2)
	DECLARE @Refund_old_value money
	DECLARE @Refund_new_value money
	DECLARE @Refund_override_description varchar(80)
	DECLARE @Refund_override_id varchar(80)
	declare @OutboundSideFare money
	declare @InboundSideFare money
		SELECT
		 @RefundValue = cast((-1 * value) as money)/100	
		,@Refund_override_reason=override_reason
		,@Refund_old_value= cast(old_value as money)/100 
		,@Refund_new_value =cast(new_value as money)/100   
		,@Refund_override_description=override_description,
		 @InboundSideFare = cast((-1 * inboundSideFare) as money)/100	
		,@OutboundSideFare=cast((-1 * outboundSideFare) as money)/100	
		FROM Openxml( @docHandle , 'Ticket/Refund' ) 
		with (
				value						int		'@refundPrice'		
				,override_reason		char(2)	'@overrideReasonCode',
				old_value money '@oldFare',
				new_value money '@newFare',
				override_description varchar(80) '@overrideDescription',
				inboundSideFare						int		'@inboundSideFare'		,
				outboundSideFare		int	'@outboundSideFare'  
			  )	 
			   
if @OutboundSideFare <> 0 or @InboundSideFare <> 0
begin
	EXECUTE @sp_retVal =   [dbo].[cp_Add_Journey_Side_Fares]
	   @OutboundSideFare
	  ,@InboundSideFare 
	  ,@sale_id  
end

	DECLARE @Refund_sales_item_id int

	DECLARE @refundItems table
	(
		id int IDENTITY(1,1),
		product_SKU char(7),		
		refund_value money,
		quantity int

	)

	DECLARE @itemCount INT

	INSERT INTO @refundItems(		
		product_SKU,		
		refund_value, 
		quantity)
	SELECT		
		product_SKU,		
		cast((-1* refund_value )as money)/100,
		quantity 	
			
		FROM OpenXML (@docHandle, 'Ticket/Refund/RefundItems/Item')
		with (
			product_SKU char(7) '@productSKU',		
			refund_value int '@refundValue',
			quantity int '@quantity')	
			
	SET @itemCount = @@rowcount
	DECLARE @ID INT		
	DECLARE @product_SKU char(7)
	DECLARE @product_code char(4)
	DECLARE @refund_value money
	DECLARE @productId INT
	DECLARE @productQuantity INT
	
	IF @itemCount >0 
		BEGIN
			SET @ID = 1
			
			WHILE @ID <= @itemCount -- less than or equal to 			
			BEGIN
				SET @Refund_sales_item_id = 0
				SELECT @product_SKU=product_SKU,@refund_value=refund_value,@productQuantity= quantity FROM @refundItems where ID =@ID
				SELECT @productId = product_id FROM dbo.tbl_Products where SMART_product_type_code+SMART_product_code=@product_SKU and active=1
			   EXECUTE @sp_retVal =   [dbo].[cp_Add_Sales_Item]
			   @sale_id
			  ,@Refund_item_type_id
			  ,@productId
			  ,@ticket
			 ,@refund_value
			  ,@productQuantity
			  ,@Refund_sales_item_id OUTPUT
			  ,''

				IF @sp_retVal <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create new Sale Item record for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END	

				--add sale item transactions - basket item - added

				EXECUTE @sp_retVal =   [dbo].[cp_Add_Sales_Item_Transaction]
				   @Refund_sales_item_id
				  ,1
				  ,@refund_item_transaction_id OUTPUT

				  EXECUTE @sp_retVal =   [dbo].[cp_Add_Sales_Item_Transaction]
				   @Refund_sales_item_id
				  ,17
				  ,@refund_item_transaction_id OUTPUT

				IF @sp_retVal <> 0
					BEGIN
						--print 'error4'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create sale item transaction for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
					END

				DECLARE @prvConsumerId int
				DECLARE @consumer_id int
				DECLARE @PrevSalesItemId INT
				SET @consumer_id = 0
				SELECT top 1 @PrevSalesItemId = sales_item_id FROM  dbo.tbl_Sales_Items where sale_id= @FirstSaleID and product_id=1

				SELECT top 1 @prvConsumerId= consumer_id FROM dbo.tbl_Item_Consumer where sale_item_id=@PrevSalesItemId and active=1

				INSERT INTO dbo.tbl_Consumers
				(
				consumer_type_id, title_id, forename, surname, suffix, coachcard_id, age_range_id, date_created,
				related_consumer_id, relation_type_id
				)
				SELECT consumer_type_id, title_id, forename, surname, suffix, coachcard_id, age_range_id, date_created,
				related_consumer_id, relation_type_id FROM dbo.tbl_Consumers where consumer_id=@prvConsumerId 

				IF @@ERROR <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create new Consumer for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END

				SET @consumer_id = SCOPE_IDENTITY()
	

				INSERT INTO dbo.tbl_Item_Consumer(sale_item_id, consumer_id, fare_id, active) 
				SELECT @Refund_sales_item_id,@consumer_id,fare_id,active FROM dbo.tbl_Item_Consumer WHERE sale_item_id = @PrevSalesItemId and active=1

				IF @@ERROR <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create new Item Consumer for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END

				DECLARE @PrevCaddressId INT
				DECLARE @addressId INT
				SELECT @PrevCaddressId=address_id FROM dbo.tbl_Consumers_Addresses WHERE consumer_id=@prvConsumerId and active=1

				INSERT INTO dbo.tbl_Addresses(address1,address2,address3,town,county_id,country_id,postcode,AddressTypeID)
				SELECT address1,address2,address3,town,county_id,country_id,postcode,AddressTypeID FROM dbo.tbl_Addresses where address_id=@PrevCaddressId

				IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create Address record for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END

				SET @AddressId = SCOPE_IDENTITY()

				INSERT tbl_Consumers_Addresses(consumer_id,address_id,marketing_consent,billing_address,active)
				SELECT @consumer_id,@addressId,marketing_consent,billing_address,active FROM  dbo.tbl_Consumers_Addresses where address_id=@PrevCaddressId and active=1

				IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create Consumer Address record for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END

				INSERT INTO tbl_Consumer_Consents(DateCreated,Consumer_ID,Via_Email,NX_White_Coach)
				SELECT GETDATE(),@consumer_id,Via_Email,NX_White_Coach FROM tbl_Consumer_Consents where Consumer_ID = @prvConsumerId

				IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to create Consumer Consent record for Item ' + @product_SKU
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END

				SET @ID= @ID+1
			END
		END

	DECLARE @payments table
	(
		ID int IDENTITY(1,1),
		original_payment_Id INT,
		payment_type char(20),
		authorisation_code varchar(8),
		merchant_id char(10),
		npm_id int,
		currency_Type char(10),
		paymentValue money,
		foreign_payment_value money,
		paymentProvider varchar(50),
		--providers_payment_reference uniqueidentifier,
		unique_transaction_reference varchar(40),	
		transaction_label VARCHAR(200) 	,
		transaction_id VARCHAR(50) ,
		security_key	 varchar(50),
		psp_Refrence varchar(40),
		third_party_authorisation bit,
		card_type_code char(3),
		card_type char(10), -- credit or debit
		lastfourdigit char(4),
		card_start_date char(10),
		card_end_date char(10),
		card_holder char(30),		
		entry_mode char(10),
		issue_number char(2)
	)

	DECLARE @paymentCount INT

	INSERT INTO @payments(
	    original_payment_Id,
		payment_type,
		authorisation_code ,
		merchant_id ,
		npm_id,
		currency_Type ,
		paymentValue ,
		foreign_payment_value ,
		paymentProvider ,
		--providers_payment_reference ,
		unique_transaction_reference ,		
		transaction_label,
		transaction_id,
		security_key,
		psp_Refrence ,
		third_party_authorisation ,
		card_type_code ,
		card_type,
		lastfourdigit ,
		card_start_date ,
		card_end_date ,
		card_holder ,
		entry_mode ,
		issue_number )
	SELECT	
	    original_payment_Id,
		payment_type,
		authorisation_code ,
		merchant_id ,
		npm_id,
		currency_Type ,
		cast((-1 * payment_Value )as money)/100 as payment_Value ,
		foreign_payment_value ,
		payment_Provider ,
		--providers_payment_reference ,
		unique_transaction_reference ,		
		transaction_label,
		transaction_id,
		security_key,
		psp_Refrence ,
		third_party_authorisation,
		card_type_code ,
		card_type,
		lastfourdigit ,
		card_start_date ,
		card_end_date ,
		card_holder ,
		entry_mode ,
		issue_number

		FROM OpenXML (@docHandle, 'Ticket/Refund/Payments/Payment')
		with (
		    original_payment_Id char(20) 'originalPaymentId',
			payment_type char(20) 'payment_type',
			authorisation_code varchar(8) 'authorisation_code',
			merchant_id char(10) 'merchant_id',
			npm_id int 'npm_id',
			currency_Type char(10) 'currency_Type',
			payment_Value money 'payment_Value',
			foreign_payment_value money 'foreign_payment_value',
			payment_Provider varchar(50) 'payment_Provider',
			--providers_payment_reference uniqueidentifier 'providers_payment_reference',
			unique_transaction_reference varchar(40) 'unique_transaction_reference',			
			transaction_label VARCHAR(200) 'transaction_label',
			transaction_id VARCHAR(50) 'transaction_id',
			security_key	 varchar(50) 'security_key',
			psp_Refrence varchar(40) 'psp_Refrence',
			third_party_authorisation bit 'third_party_authorisation',
			card_type_code char(3) 'card_type_code',
			card_type char(10) 'card_type',
			lastfourdigit char(4) 'lastfourdigit',
			card_start_date char(10) 'card_start_date',
			card_end_date char(10) 'card_end_date',
			card_holder char(30) 'card_holder',
			entry_mode char(10) 'entry_mode',
			issue_number char(2) 'issue_number'
			) 		

		SET @paymentCount = @@rowcount
		
		DECLARE @paymentTypeId INT
		DECLARE @originalPaymentId INT
		DECLARE @cardTypeId INT
		
		DECLARE @currencyTypeId INT
		DECLARE @lastfourdigit char(4)
		DECLARE @card_type_code char(3)
		DECLARE @card_type char(10)
		DECLARE @providers_payment_reference uniqueidentifier
		DECLARE @unique_transaction_reference varchar(40)
		DECLARE @authorisation_code varchar(8)
		DECLARE @security_key varchar(50)
		DECLARE @psp_Refrence varchar(40)
		DECLARE @third_party_authorisation bit
		DECLARE @transaction_label VARCHAR(200)
		DECLARE	@transaction_id VARCHAR(50)
		DECLARE	@payment_provider_transaction_id int
		DECLARE @paymentProviderId INT
		DECLARE @Is_RsoMode BIT
		DECLARE @paymentValue money
		DECLARE @totalpaymentValue money
		DECLARE @entry_mode_id INT
		set @totalpaymentValue = 0
		IF @paymentCount >0 
		BEGIN
			SET @ID = 1
			while @ID <= @paymentCount -- less than or equal to 
			BEGIN
			print 'inside while'
				SELECT  @paymentTypeId=payment_type_id FROM dbo.tbl_Payment_Types where payment_type COLLATE database_default =(SELECT payment_type FROM @payments where ID =@ID)

				  If (@paymentTypeId = 0)
					BEGIN
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Invalid Payment Type'
						RAISERROR('Invalid Payment Type',10,1)
						GOTO ErrorDetetcted				
					END

				SELECT @paymentProviderId=id FROM NXLookup.dbo.tbl_Payment_Providers where name COLLATE database_default=(SELECT paymentProvider FROM @payments where ID=@ID)

				  If (@paymentProviderId = 0)
					BEGIN
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Invalid Payment Provider'
						RAISERROR('Invalid Payment Provider',10,1)
						GOTO ErrorDetetcted				
					END

				SELECT @originalPaymentId=original_Payment_Id, @paymentValue=paymentValue,	
				@card_end_date=card_end_date, @card_holder=card_holder,@issue_number= issue_number, @third_party_authorisation=third_party_authorisation FROM @payments where ID=@ID

				

				SELECT @currency_id=currency_id FROM dbo.tbl_Currency_Types where currency_type COLLATE database_default=(SELECT currency_Type FROM @payments where ID=@ID)				

				--SELECT @entry_mode_id=entry_mode_id FROM dbo.tbl_Entry_Modes where entry_mode COLLATE database_default=(SELECT entry_mode FROM @payments where ID=@ID)

				--If (@entry_mode_id = 0)
				--	BEGIN
				--		EXEC sp_xml_removedocument @docHandle
				--		SET @Message = 'Invalid card entry mode'
				--		RAISERROR('Invalid card entry mode',10,1)
				--		GOTO ErrorDetetcted				
				--END

				SELECT @providers_payment_reference= NULL,@unique_transaction_reference= unique_transaction_reference, 
				@authorisation_code=authorisation_code, @security_key=security_key,@psp_Refrence=psp_Refrence,
				@transaction_label=transaction_label, @transaction_id=transaction_id				
				FROM @payments where ID=@ID

				DECLARE @prevCardDetailsId int

				SELECT @prevCardDetailsId= card_details_id from tbl_Payments where payment_id=@originalPaymentId
				SELECT @cardTypeId=card_type_id,@card_number=card_number,@card_start_date=card_start_date,@card_end_date=card_end_date,@card_holder=card_holder,@entry_mode_id=entry_mode_id,@issue_number=issue_number,@third_party_authorisation=third_party_authorisation from tbl_Card_Details where card_details_id=@prevCardDetailsId


				SET @card_details_id = 0
				SET @authorisation_code=''
				IF (@cardTypeId<>0)
				BEGIN	
						
					SELECT @cardTypeId= card_type_id FROM dbo.tbl_Card_Types WHERE card_type_code=@card_type_code and card_type=@card_type
					If (@cardTypeId = 0)
					BEGIN
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Invalid card type'
						RAISERROR('Invalid card type',10,1)
						GOTO ErrorDetetcted				
					END
					--SET @card_number = '**** **** **** '+ @card_number
					CREATE TABLE #tmp (CardDate VARCHAR(20))
			
					INSERT INTO #tmp
					EXEC @sp_retVal=cp_Add_Card_Details_v2 @cardTypeId,@card_number,@card_start_date,@card_end_date,@card_holder,@entry_mode_id,0,@issue_number,'',@third_party_authorisation,@card_details_id OUTPUT
					DROP TABLE #tmp -- to remove returned result from cp_Add_Card_Details_v2
					IF @sp_retVal <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add card details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END
			   END
			  
			   IF NOT ISNULL(@unique_transaction_reference,'') = ''
			   BEGIN
					If @sales_channel_id=5 
					BEGIN
						SET @Is_RsoMode = 1
					END 
					 set @providers_payment_reference = NULL
					
				 EXEC @sp_retVal = cp_insert_payment_provider_transaction_v5 @paymentProviderId,@providers_payment_reference,@unique_transaction_reference,@cardTypeId,1,@security_key,@authorisation_code,@card_number,@transaction_label,@payment_provider_transaction_id
 OUTPUT
,@transaction_id,@Is_RsoMode,@sale_id
				
				
				if(@sp_retVal<>0)
					BEGIN						
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to insert payment provider transaction reference details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				   END
			   END 

			   INSERT dbo.tbl_Payments
							(payment_type_id, consumer_id, card_details_id, authorisation_code, nmp_id, currency_id,
							payment_value, sale_id, sale_item_id, date_created, foreign_payment_value, payment_provider_id,
							payment_provider_transaction_id,merchant_id)
			   SELECT OP.payment_type_id, @consumer_id, @card_details_id, OP.authorisation_code,OP.nmp_id,@currency_id,P.paymentValue,
			   @sale_id,@Refund_sales_item_id,GETDATE(),P.foreign_payment_value,@paymentProviderId,@payment_provider_transaction_id,OP.merchant_id 
			   FROM @payments P JOIN tbl_Payments OP on P.original_payment_Id=OP.payment_id 
			   where P.ID=@ID
			   declare @insertedPaymentId int
			   SET @insertedPaymentId = SCOPE_IDENTITY()

			   if (@paymentProviderId=14 or @paymentProviderId=17)
				BEGIN
					insert [Titan].[dbo].[tbl_Payment_Account]([Payment_ID],[Payment_Account])
					select @insertedPaymentId,OP.[Payment_Account] 
					 FROM @payments P JOIN [Titan].[dbo].[tbl_Payment_Account] OP on P.original_payment_Id=OP.payment_id 
					where P.ID=@ID
				END
				
			   
			   IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add payment details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END
				set @totalpaymentValue = @totalpaymentValue+@paymentvalue
			    SET @ID= @ID+1
			  
		  END
	  END

				INSERT INTO dbo.tbl_Basket_Summary
			   (Sale_ID,TicketNo,[Timestamp],AgentID,ClerkiD,Transstatus,TransType,previous_sale_id,Highest_Fare_Paid_To_Date,Highest_Fare_Paid_To_Date_Outward,Highest_Fare_Paid_To_Date_Return)
			   SELECT @sale_id,@Ticket,DATEDIFF(SECOND, '1970-01-01 00:00:00', GETDATE()),@agent_code,@user,'R','',@previous_sale_id,Highest_Fare_Paid_To_Date,Highest_Fare_Paid_To_Date_Outward,Highest_Fare_Paid_To_Date_Return
			   From dbo.tbl_Basket_Summary where Sale_ID=@previous_sale_id

			    IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add basket summary details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END

			   INSERT INTO dbo.tbl_Journey_Summary
				(Sale_ID,Faretype,FareValue,TicketType,TicketQueue,CollectionLoc,Destination,DeptDate)
				SELECT @sale_id,FareType,0,TicketType,TicketQueue,CollectionLoc,Destination,DeptDate FROM dbo.tbl_Journey_Summary where Sale_ID=@previous_sale_id

				 IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add journey summary details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END

				INSERT INTO dbo.tbl_Basket_Paying_Consumer
				(Sale_ID,PaymentValue,Title,Initials,Surname,Deladdr1,Deladdr2,Deldist,Deltown,Delcounty,Delpostcode,Telnoday,Telnoeve,Emailaddress)
				SELECT @sale_id,@totalpaymentValue * 100,Title,Initials,Surname,Deladdr1,Deladdr2,Deldist,Deltown,Delcounty,Delpostcode,Telnoday,Telnoeve,Emailaddress
				FROM tbl_Basket_Paying_Consumer where Sale_ID=@FirstSaleID

				IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add Basket paying consumer details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END

				INSERT INTO dbo.tbl_Misc_Basket_Info
				(Sale_ID,Alteration_Fee,OverrideReason,OverridingClerk,InsuranceAmount,Passownrisk)
				VALUES(@sale_id,0,ISNULL(@Refund_override_reason,''),@user,0,0)

				IF @@error <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add Basket Misc details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END
				
				DECLARE @Fare_override_id varchar(80)
				If(ISNULL(@Refund_override_reason,'') <>'' and ISNULL(@Refund_override_description,'')<>'')
				BEGIN
					BEGIN
					Declare @journeySaleItemId int
					select @journeySaleItemId=sales_item_id from tbl_sales_items where sale_id =@sale_id and product_id=1
					if isnull(@journeySaleItemId,0)>0
					begin 
						set @Refund_sales_item_id = @journeySaleItemId
						end
							  EXECUTE  @sp_retVal  =   [dbo].[cp_Add_Override]
							  @Refund_sales_item_id
							   ,@agent_user_id 
							  ,@Refund_override_reason
							  ,@Refund_old_value
							  ,@Refund_new_value
							  ,@Refund_override_description							
							  ,@Refund_override_id OUTPUT
					END

					IF @sp_retVal <> 0
					BEGIN
						--print 'error3'
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add override details'
						RAISERROR(@Message,11,1)
						GOTO ErrorDetetcted
				END
			 END
select @SaleID = @sale_id
SET @RESULT = 1
SET @Message = 'Refund completed successfully'
COMMIT TRAN
GOTO Ending
ErrorDetetcted:		    
		ROLLBACK TRAN
		SET @RESULT = 0
GOTO Ending

Ending:
	print @Message
END
GO

