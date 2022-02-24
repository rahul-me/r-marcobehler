USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_RetailAPI_Basket_Amendment]    Script Date: 8/5/2021 11:14:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* ============================== Change History =================================
-- Author		:	Urvashi Parmar
-- Create date	:	06-Nov-2019
-- Description	:
-- ===================================================================
-- Modified By	: Urvashi Trivedi
-- Modified Date: 12-Nov-2019
-- Description	: Internal SP call 'cp_Add_Card_Details_v2' resultset has been supressed.
-- ===================================================================
-- Modified By  : Jay Shah
-- Modified Date: 24-Apr-2020
-- Description  : Changed currency id to 0 from 1
-- ===================================================================
-- Modified By	: Urvashi Parmar
-- Modified Date: 11-06-2020
-- Description	:SMAREP-1379 added new departure date and arrival date string in XML
-- ===================================================================
-- Author		:	Kajal Patel
-- Modified date:	06-Nov-2020
-- Description	:	SMAREP-1836 : Hardcoded TravelCAT SalesChannelCode for contactcenter transaction to identify transactions done by TravelCAT application.
-- ==================================================================================================================
-- Author		:	Kajal Patel
-- Modified date:	09-Nov-2020
-- Description	:	SMAREP-1926 : Selected fare_id instead of passing fare type
-- ==================================================================================================================
-- Author		:	Urvashi Parmar
-- Modified date:	15-Dec-2020
-- Description	:	SMAREP-1916 : fixed issue of invalid HighestFarePaidToDate value in basket summary table
-- ==================================================================================================================
-- Sample Execution Script	: 
--	EXEC cp_RetailAPI_Basket_Amendment @TicketXML='<Ticket agentCode="D085" agentUser="sys" journeyType="S" salesChannel="Call" ticketNumber="8Q008198"><Addons><Addon><Item_quantity>1</Item_quantity><Item_value>1000</Item_value><new_fare>1000</new_fare><ol

d_fare>500</old_fare><override_description>dfsfsdfsdf</override_description><override_reason_code>A</override_reason_code><SKU>B02B002</SKU></Addon></Addons><Coachcards><Coachcard serialnumber="1C569325" type="CF"/></Coachcards>	<DistributionDetails distr

ibutionType="M TICKET" mTicketPhone="07123456789"/><Fare inBoundJourneySideFare="0" netPrice="1200" NewFare="0" oldFare="0" outBoundJourneySideFare="1200" type="CST"/><LeadPassenger emailConsent="false" firstName="Test" surname="Test" telephone="071234567

89" title="Mr."><Address><Address1>test test</Address1><Address2>test</Address2><Address3>test</Address3><PostCode>SE1 6SG </PostCode><Town>London</Town></Address></LeadPassenger><Legs><Leg><actual_fare_value>0</actual_fare_value><arr_date>1570579200</arr

_date><arr_day>0</arr_day><arr_time>360</arr_time><booking_ref>NCSE</booking_ref><check_in_time>180</check_in_time>	<company_brand_id>NX</company_brand_id><coupon_fare_value>0</coupon_fare_value><cust_info_id>JH</cust_info_id>	<dept_date>1570579200</dept_

date><dept_time>180</dept_time><displacement_days></displacement_days><fail_cd>H</fail_cd><fare_type>CST</fare_type><flight_code>EA</flight_code><flight_start_time>1419</flight_start_time><from_loc>33023</from_loc><from_stop>A</from_stop><gd_trigger_level

>0</gd_trigger_level><leg_dir>O</leg_dir><leg_no>0</leg_no><serv_dir>I</serv_dir><serv_nr>920</serv_nr><to_loc>57366</to_loc><to_stop>T</to_stop></Leg></Legs><Passengers Over60s="0"><Passenger type="AD"/></Passengers><Payment payment_type="Card" payment_v

alue="1500"><CardPayment card_type="VISA" merchant_ID="dfsfdsf" payment_provider="Barclays" payment_provider_transaction_id="test123489"/></Payment></Ticket>',@SaleID=@SaleID,@Messagef=@Message, @RESULT=@RESULT
*/
-- ====================================================================================================================
ALTER PROCEDURE [dbo].[cp_RetailAPI_Basket_Amendment]
(
	 @TicketXML ntext
	,@SaleID Int output
	,@Message varchar(50) OUTPUT	
	,@RESULT Int OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
----NOTE ALL PRICES ARE EXPRESSED IN PENCE	

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
	declare @amendType varchar(50)
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
	declare @CarryForwardOutBoundLegs bit
	declare @CarryForwardInBoundLegs bit
	declare @LastSaleID int
	declare @LastTravelSaleItemID int
	declare @OutBoundLegCount int
	declare @LegsAdded int
	declare @AmendmentFeeValue int
	declare @PaymentProvider varchar(40)
	declare @errorCheck int
	DECLARE @tId uniqueidentifier
	declare @PaymentAccount varchar(250)
	declare @PaymentID int
	declare @FirstTravelSaleItemID int
	declare @FirstSaleID int
	declare @FareTypeID int
	declare @amendabilityReasonCode char(2)
	declare @amendabilityReasonDescription varchar(500)


	INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('Add ESB Amendment'           
           ,getdate()         
           ,@TicketXML
           )
BEGIN TRAN

 --retrieve agent user ID
	select 
			@Ticket = ticketnumber,
			@agent = agentcode, 
			@user= agentuser,
			@Channel = SalesChannel,			
			@JrnyType = upper(JourneyType),
			@amendabilityReasonCode = 	amendabilityReasonCode,
			@amendabilityReasonDescription=amendabilityReasonDescription	
	FROM Openxml( @docHandle , 'Ticket' ) 
	WITH ( 
			ticketnumber	char(8)		'@ticketNumber'
		   ,agentcode		char(5)		'@agentCode'
		   ,agentuser		char(8)		'@agentUser'
		   ,saleschannel	char(15)	'@salesChannel'		   
		   ,journeyType		char(1)		'@journeyType'
		   ,amendabilityReasonCode  char(2) '@amendabilityOverrideCode' 
		   ,amendabilityReasonDescription  char(500) '@amendabilityOverrideDescription' 
		   
		 )

--print 'agent'
--print @agent
--print '[user]'
--print @user
--print @ticket
--print @channel
--print @amendtype
--print @jrnytype


-- get first & last sale IDs
select  @FirstSaleID = min(sale_id)
		,@LastSaleID= max( sale_id)
from
      dbo .tbl_Sales_Items SI
       join dbo. tbl_Item_Serial_Link ISL
             on ISL. item_serial_id = si .item_serial_id
       join dbo. tbl_Tickets T
             on T. ticket_id = ISL .ticket_id
                   and ticket_serial = @ticket


--get @FirstTravelSaleItemID
select @FirstTravelSaleItemID = sales_item_id
	from
dbo.tbl_sales_items
	where sale_id = @FirstSaleID
		and product_id = 1

--get @LastTravelSaleItemID
select @LastTravelSaleItemID = sales_item_id
	from
dbo.tbl_sales_items
	where sale_id = @LastSaleID
		and product_id = 1



EXECUTE @RC =   [dbo].[cp_Get_Agent_User_ID_V2]
   @agent
  ,@user
  ,@agent_user_id OUTPUT


--print @agent_user_id

IF (@@ERROR <> 0)
	begin
		--print 'error1'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to get Agent User Id'
	    RAISERROR('Failed to get Agent User Id',10,1)
		GOTO ErrorDetetcted
	end

-- SMAREP-1836 : Added order by to always get recently added channelID 
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
  ,@SAlesChannelID
  ,@sale_id OUTPUT

if @@error <> 0
	begin
		--print 'error2'
		EXEC sp_xml_removedocument @docHandle
		 SET @Message = 'Failed to create new Sale record'
	    RAISERROR('Failed to create new Sale record',11,1)
		GOTO ErrorDetetcted
	end


--print @sale_id


-- Extract Fare Information from XML

declare @FareValue as money
declare @FareType as char(3)
declare @outBoundJourneySideFare money
declare @inBoundJourneySideFare money
declare @Fare_override_reason char(2)
declare @Fare_old_fare money
declare @Fare_new_fare money
declare @Fare_override_description varchar(80)
declare @Fare_override_id int



select
	@FareValue = cast(value as money)/100
	,@FareType = type
	,@outBoundJourneySideFare = outBoundJourneySideFare 
	,@inBoundJourneySideFare = inBoundJourneySideFare
	,@Fare_override_reason=override_reason
	,@Fare_old_fare= old_fare/100
	,@Fare_new_fare = new_fare/100
	,@Fare_override_description=override_description
	FROM Openxml( @docHandle , 'Ticket/Fare' ) 
		with (
				value						int		'@netPrice'
				,type						char(3) '@type'
				,outBoundJourneySideFare	int		'@outBoundJourneySideFare'
				,inBoundJourneySideFare		int		'@inBoundJourneySideFare'
				
			,override_reason		char(2)	'@overrideReasonCode',
			old_fare money '@oldFare',
			new_fare money '@NewFare',
			override_description varchar(500) '@overrideDescription'
			  )

-- if partial amendment ?
if @outBoundJourneySideFare IS NULL
	-- need to know Journey Type Single/ Open Return / Return
	begin
		if @JrnyType = 'S' or @JrnyType = 'O'
			begin
				-- whole fare
				set @outBoundJourneySideFare = @FareValue					
			end
		else	
			begin
				-- half fare
				set @outBoundJourneySideFare = @FareValue  /2
			end
	end
else
	-- convert to money
	begin
		set @outBoundJourneySideFare = @outBoundJourneySideFare/100
	end 


if @inBoundJourneySideFare IS NULL
	-- need to know Journey Type Single/ Open Return / Return
	begin
		if @JrnyType = 'S' or @JrnyType = 'O'
			begin
				set @inBoundJourneySideFare = 0
			end
		else
			begin
				select @inBoundJourneySideFare =  @FareValue/2
			end
	end
else
	-- convert to money
	begin
		set @InBoundJourneySideFare = @INBoundJourneySideFare/100	
	end 

	
-- Set sales transaction type

set @sale_item_type_id = 2

DECLARE @Travel_sales_item_id int

DECLARE @totalFare money
set @totalFare=@outBoundJourneySideFare + @inBoundJourneySideFare

EXECUTE @RC =   [dbo].[cp_Add_Sales_Item]
   @sale_id
  ,@sale_item_type_id
  ,1
  ,@ticket
  ,@totalFare
  ,1
  ,@Travel_sales_item_id OUTPUT
  ,''


if @@error <> 0
	begin
		--print 'error3'
		EXEC sp_xml_removedocument @docHandle
		 SET @Message = 'Failed to create new Sale Item record'
	    RAISERROR('Failed to create new Sale Item record',11,1)
		GOTO ErrorDetetcted
	end

	--insert amendability override details
if (ISNULL(@amendabilityReasonCode,'')<>'') 
					BEGIN
							  EXECUTE @RC =   [dbo].[cp_Add_Override]
							  @Travel_sales_item_id
							   ,@agent_user_id 
							  ,@amendabilityReasonCode
							  ,0
							  ,0
							  ,@amendabilityReasonDescription							
							  ,@Fare_override_id OUTPUT
					END

					
if @@error <> 0
	begin
		--print 'error3'
		EXEC sp_xml_removedocument @docHandle
		 SET @Message = 'Failed to create sale override record'
	    RAISERROR('Failed to create sale override record',11,1)
		GOTO ErrorDetetcted
	end

--insert fare override details
 if (ISNULL(@Fare_override_reason,'')<>'')   
					BEGIN
							  EXECUTE @RC =   [dbo].[cp_Add_Override]
							  @Travel_sales_item_id
							   ,@agent_user_id 
							  ,@Fare_override_reason
							  ,@Fare_old_fare
							  ,@Fare_new_fare
							  ,@Fare_override_description							
							  ,@Fare_override_id OUTPUT
					END

					
if @@error <> 0
	begin
		--print 'error3'
		EXEC sp_xml_removedocument @docHandle
		 SET @Message = 'Failed to create sale override record'
	    RAISERROR('Failed to create sale override record',11,1)
		GOTO ErrorDetetcted
	end

--DECLARE @MaxOutBoundJourneySideFare MONEY ,@MaxInBoundJourneySideFare MONEY

--SELECT @MaxOutBoundJourneySideFare = OutBoundJourneySideFare,
--	@MaxInBoundJourneySideFare = InBoundJourneySideFare
--FROM fn_Get_Max_SideFare_For_Ticket (@Ticket)

-- Insert Journey Side Fares
INSERT INTO [dbo].[tbl_Journey_Side_Fares]
           ([OutBoundJourneySideFare] 
           ,[InBoundJourneySideFare]
           ,[Sale_ID])
     VALUES
           (ISNULL(@OutBoundJourneySideFare , 0) --+ @MaxOutBoundJourneySideFare
           ,ISNULL(@InBoundJourneySideFare , 0) --+ @MaxInBoundJourneySideFare
           ,@sale_id)
           
-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to create journey side fare'
	    RAISERROR('Failed to create journey side fare',11,1)
		GOTO ErrorDetetcted
	end





--	

select @ticket_id = ticket_id
from
	dbo.tbl_Tickets
where
	ticket_serial = @Ticket

INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
     ,[Request]
        )
     VALUES
           ('@ticket_id when retrieved'           
           ,getdate()         
           ,cast(@ticket_id as varchar(100))
           )


--print 'SalesItemID:'
--print @Travel_sales_item_id


 --add sale item transactions - basket item - added

EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
   @Travel_sales_item_id
  ,1
  ,@sales_item_transaction_id OUTPUT

if @@error <> 0
	begin
		--print 'error4'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to create sale item transaction'
	    RAISERROR('Failed to create sale item transaction',11,1)
		GOTO ErrorDetetcted
	end

 --add journey type

EXECUTE @RC =   [dbo].[cp_Add_Ticket_Journey_Type_V3]
   @ticket
  ,@JrnyType
  ,@sale_id

if @@error <> 0
	begin
		--print 'error5'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to add ticket journey type'
	    RAISERROR('Failed to add ticket journey type',11,1)
		GOTO ErrorDetetcted
	end

/*
Need to determine type of amendment so can handle legs correctly.
Flow A
If journey type is single or unvalidated open return just add legs.
If return journey and both sides amended just add legs
Flow B
If return journey and amending outbound only - add legs from XML
	and then carry forward inbound legs
Flow C
If return journey and amending inbound only - carry forward outbound legs
	and then add legs from XML.
*/


 --Add Legs

INSERT dbo.tbl_SmartJourneyLegs
		(
			sales_item_id, 
			leg_number, 
			leg_direction, 
			from_location_code,							
			to_location_code, 
			from_stop, 
			to_stop, 
			company_brand_code, 
			[service], 
			direction,
			flight_code, 
			displacement_days, 
			flight_start_time, 
			departure_date, 
			check_in_time,
			departure_time, 
			arrival_date, 
			arrival_time, 
			arrival_day, 
			gd_trigger_level, 
			fare_type,
			coupon_fare_value, 
			actual_fare_value, 
			through_fare_leg, 
			special_fare_code,
			booking_reference, 
			attraction_code,
			customer_info_code, 
			fail_code, 
			date_created)
	SELECT 
			@Travel_sales_item_id, 
			leg_no , 
			case when leg_dir='I' then 'R' else leg_dir end, 
			from_loc,
			to_loc, 
			from_stop, 
			to_stop, 
			company_brand_id, 
			serv_nr, 
			serv_dir,
			flight_code, 
			displacement_days, 
			flight_start_time, 
			DATEDIFF(s,'01-01-1970 00:00:00',convert(varchar(10),dept_date_string,101)), 
			check_in_time,
			dept_time, 
			DATEDIFF(s,'01-01-1970 00:00:00',convert(varchar(10),arr_date_string,101)), 
			arr_time, 
			arr_day, 
			gd_trigger_level, 
			fare_type,
			coupon_fare_value, 
			actual_fare_value, 
			isnull(through_fare_leg,''), 
			isnull(special_fare_id,''),
			booking_ref, 
			isnull(attraction_id,''),
			isnull(cust_info_id,''),
			isnull(fail_cd,''),
			getdate()
	FROM OPENXML (@docHandle, 'Ticket/Legs/Leg')
	WITH (
		[sales_item_id]			[int]		'sales_item_id',
		[leg_no]				[int]		'leg_no',
		[leg_dir]				[char] (1)	'leg_dir',
		[from_loc]				[char] (5)	'from_loc',
		[to_loc]				[char] (5)	'to_loc',
		[from_stop]				[char] (1)	'from_stop',
		[to_stop]				[char] (1)	'to_stop',
		[company_brand_id]		[char] (2)	'company_brand_id',
		[serv_nr]				[char] (3)	'serv_nr',
		[serv_dir]				[char] (1)	'serv_dir',
		[flight_code]			[char] (2)	'flight_code',
		[displacement_days]		[char] (1)	'displacement_days',
		[flight_start_time]		[char] (4)	'flight_start_time',
		[dept_date_string]		[char] (20)		'dept_date_string', -- SMAREP-1379 - Urvashi Parmar
		[check_in_time]			[smallint]	'check_in_time',
		[dept_time]				[int]		'dept_time',
		[arr_date_string]		[char] (20)		'arr_date_string',  --SMAREP-1379 - Urvashi Parmar
		[arr_time]				[smallint]	'arr_time',
		[arr_day]				[smallint]	'arr_day',
		[gd_trigger_level]		[smallint]	'gd_trigger_level',
		[fare_type]				[char] (3)	'fare_type',
		[coupon_fare_value]		[int]		'coupon_fare_value',
		[actual_fare_value]		[int]		'actual_fare_value',
		[through_fare_leg]		[char] (1)  'through_fare_leg',
		[special_fare_id]		[char] (6)	'special_fare_id',
		[booking_ref]			[char] (4)	'booking_ref',
		[attraction_id]			[char] (3)	'attraction_id',
		[cust_info_id]			[char] (5)	'cust_info_id',
		[fail_cd]				[char] (1)	'fail_cd'
		)

	
if @@error <> 0
	begin
		--print 'error6'
		EXEC sp_xml_removedocument @docHandle
		SET @Message = 'Failed to add journey legs'
	    RAISERROR('Failed to add journey legs',11,1)
		GOTO ErrorDetetcted
	end	
				set @LegsAdded = @@rowcount
			
 --store some leg data to use later
declare @TempLegs table
  (
    leg_no int
    ,leg_dir char(1)
    ,from_loc char(5)
    ,to_loc char (5)
    ,dept_date_time datetime
	,dept_date int
    )
insert into @TempLegs
SELECT 
      leg_number,
      leg_direction,
	  from_location_code,
	  to_location_code,
	  dateadd(s,  departure_date+ (departure_time * 60), '01-Jan-1970 00:00:00' ),
	  departure_date
From
	dbo.tbl_SmartJourneyLegs 
where
	sales_item_id = @Travel_sales_item_id


select @from_location = from_loc from @templegs where leg_no = 0
select @departure_date_time = dept_date_time from @templegs where leg_no = 0
select @DeptDate = dept_date from @templegs where leg_no = 0
select @to_location = to_loc from @templegs where leg_dir = 'O' and leg_no = (select max(leg_no) from @templegs where leg_dir = 'O') 


 --Add Sales Item Transaction / Amended in EXTRA
EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
   @Travel_sales_item_id
  ,4
  ,@sales_item_transaction_id OUTPUT		




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



--print 'distributiontype' + '-' + @TicketDistributionType

INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('@TicketDistributionType from xml'           
           ,getdate()         
           ,@TicketDistributionType
           )
		

 --Determine Lead Pax Type Title
declare @Title_id int

select @Title_id = title_id
FROM  dbo.tbl_Titles
				where title = @LeadPaxTitle

 --Determine Pax Type of Lead Pax

declare @LeadPaxConsumerType int
declare @LeadPaxID int

declare @Pax table

	(ID int IDENTITY(1,1),
	paxtype char(2)	
	,consumer_type_id int
	,generic_consumer_id int)
	
	
insert into @Pax
SELECT type,  consumer_type_id,
	case  consumer_type_id
		when 1 then 1 -- AD
		when 2 then 2 -- CH
		when 3 then 3 -- CF
		when 4 then 4 -- ST
		when 5 then 5 -- GH (infant)
		when 7 then 5445592 -- YP
		when 8 then 5445601 --SC
		when 9 then 5445609 -- HM
	else
		0
	end as generic_consumer
		
 FROM OpenXml( @docHandle , 'Ticket/Passengers/Passenger' , 1)    
 WITH
  ( type char(3) '@type')
	 X
	join dbo.tbl_Consumer_Types CT
		on X.type = CT.Passenger_Type_Code




 --Determine Pax type of lead passenger (assumption is the first passenger)
select @LeadPaxConsumerType = consumer_type_id 
from @Pax
where ID = 1

declare @AdditionalPaxCount int

select @AdditionalPaxCount = count(ID)
from @Pax
		where ID <> 1

	-- Non Alliance Ticket	

	-- Add Lead Passenger


	 INSERT INTO dbo.tbl_Consumers
					   (
					  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
					  related_consumer_id , relation_type_id, consumer_role_id, sale_id
					   )
				 SELECT
                   
						@LeadPaxConsumerType
						,isnull(@Title_id,0)
						,@LeadPaxFirstName
						,@LeadPaxSurname
						,0
						,0
						,0
						,getdate()
						,0
						,0
						,6
						,@sale_id
    		
			if @@error <> 0
			begin
				--print 'error6'
				EXEC sp_xml_removedocument @docHandle
				SET @Message = 'Failed to add lead Consumer details'
				RAISERROR('Failed to add lead Consumer details',11,1)
				GOTO ErrorDetetcted
			end	

			set @LeadPaxId = SCOPE_IDENTITY()
			


	--              add item consumer record
				 EXECUTE @RC =   [dbo].[cp_Add_Item_Consumer]
				   @Travel_sales_item_id
				  ,@LeadPaxId
				  ,0
				  ,1
				  ,@ITEM_CONSUMER_id OUTPUT 
				  
				--print 'error6'
				if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add item Consumer'
					RAISERROR('Failed to add item Consumer',11,1)
					GOTO ErrorDetetcted
				End
				  
				          
 
	--	   add lead pax address record
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

				
				--add consumer address record(s)                           
				--print  '@address_id'
				--print  @address_id
				--print '@LeadPaxId'
				--print @LeadPaxId

				 EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]
				   @LeadPaxId
				  ,@address_id
				  ,0
				  ,0
				  ,1
				  ,@consumer_address_id OUTPUT  
				  
				  if @@error <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					SET @Message = 'Failed to add consumer address'
					RAISERROR('Failed to add consumer address',11,1)
					GOTO ErrorDetetcted
				End 
			
		

		declare @Postaladdress1 varchar(40)
		
		select
			@Postaladdress1 = Address1			

		FROM OPENXML ( @docHandle , 'Ticket/DistributionDetails/PostalAddress' ) 
		with ( 
				Address1	varchar(40)	'address1'
			 )

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
                   
						@LeadPaxConsumerType
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
                   
						@LeadPaxConsumerType
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


	----		 Add email

	          IF @EmailAddress <> ''
			  BEGIN

				 INSERT INTO dbo.tbl_Email_Addresses
							 (
							consumer_id ,
							email_address ,
							active ,
							marketing_consent 
							 )
				 VALUES (@LeadPaxid ,
						  @EmailAddress ,
						  1,
						  NULL) --(ESB-362)

					if @@error <> 0
					begin
						EXEC sp_xml_removedocument @docHandle
						SET @Message = 'Failed to add email address'
						RAISERROR('Failed to add email address',11,1)
						GOTO ErrorDetetcted
					End 
			 END

					  INSERT INTO tbl_Consumer_Consents
					(DateCreated,
					 Consumer_ID,
					 Via_Email,
					 NX_White_Coach)

					 VALUES
					 (
						GETDATE(),
						@LeadPaxid,
						@LeadPaxEmailConsent,
						@LeadPaxEmailConsent
					 )


	----		 Add telephone

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

				-- SMAREP-1926 : corrected query : selected fare_id instead of passing fare type
				SELECT @FareTypeID = fare_id
				FROM
				tbl_SMART_FareType_Import
				WHERE rtrim(fare_code) = rtrim(@FareType)


		---- Add Passengers

			-- Add Passengers as passed in XML (pre-E&B Code)
				INSERT INTO   [dbo].[tbl_Item_Consumer]
					   ([sale_item_id]
					   ,[consumer_id]
					   ,[fare_id]
					   ,[active]
					   )
				select
					   @travel_sales_item_id
					   ,generic_consumer_id
					   ,isnull(@FareTypeID, 0) 
					   ,1
				from
					@Pax
				where ID <> 1


---- Add Addons

DECLARE @AddonCount int

declare @ID int
declare @Addon_sales_item_id int
declare @Product_id Int
declare @Item_value money
declare @Item_quantity int
declare @override_reason char(2)
declare @old_fare money
declare @new_fare money
declare @override_description varchar(500)
declare @override_id int
--print 'addon started'

---- create table variable
declare @Addons table
	( ID int IDENTITY(1,1),
	  SKU char(7),
	  Product_id int,
	  Serial varchar(15),
	  Item_single_value money,	  
	  Item_quantity int,
	  From_date datetime,
	  To_date datetime,
	  override_reason char(2),
		old_fare money,
		new_fare money,
		override_description varchar(500)

	)

	insert into @Addons
	select
		SKU
		,Product_id
		,serial
		,cast(item_value as money) /100
		,item_quantity
		,isnull(addons.valid_from, '01-Jan-1900 00:00:00') 
        ,isnull(addons.valid_to, '01-Jan-1900 00:00:00')
		,override_reason
		,old_fare
		,new_fare
		,override_description
	FROM OpenXML (@docHandle, 'Ticket/Addons/Addon')
	with (
			SKU				char(7)		'SKU',
			item_value		int			'Item_value',
			item_quantity	int			'Item_quantity',
			serial			varchar(15)	'Serial',
			valid_from		datetime	'Valid_from',
			valid_to		datetime	'Valid_to',
			override_reason		char(2)	'override_reason_code',
			old_fare money 'old_fare',
			new_fare money 'new_fare',
			override_description varchar(80) 'override_description'
			) Addons
		join dbo.tbl_Products P
			on Addons.SKU = (P.SMART_product_type_code +P.SMART_product_code)

		set @AddonCount = @@rowcount

		--print 'number of addons'
		--print @AddonCount
		

if @AddonCount >0 
	BEGIN

----		 loop
		set @ID = 1
		
		while @ID <= @AddonCount -- less than or equal to 
			begin
				select 
					@Product_id = product_id
					,@Item_value = Item_single_value
                    ,@Item_quantity = Item_quantity,
					@override_reason= override_reason
					,@old_fare= old_fare/100
					,@new_fare= new_fare/100
					,@override_description = override_description
				from
					@Addons
				where
					ID = @ID
				
			       
----			 ADD SALES ITEM
			EXECUTE @RC =   [dbo].[cp_Add_Sales_Item]
			   @sale_id
			  ,1
			  ,@Product_id
			  ,@ticket
			  ,@Item_Value
			  ,@Item_quantity
			  ,@Addon_sales_item_id OUTPUT
			  ,''	
			  
				if (ISNULL(@override_reason,'')<>'')
					BEGIN
							  EXECUTE @RC =   [dbo].[cp_Add_Override]
							  @Addon_sales_item_id
							   ,@agent_user_id 
							  ,@override_reason
							  ,@old_fare
							  ,@new_fare
							  ,@override_description							  
							  ,@override_id OUTPUT
					END
			  	

----			 aDD ITEM Transaction
			EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
			   @Addon_sales_item_id
			  ,14
			  ,@sales_item_transaction_id OUTPUT
					
----			 increment loop counter
			--print @ID
			set @ID = @ID +1	 
	   end
	end


--get amendment fee value
select
	@AmendmentFeeValue = A.Item_single_value *100
from
	@Addons A
where
	(A.SKU = 'B06B001' OR A.SKU = 'B06B002')


-- check for Insurance

declare @InsuranceValue int

select  @InsuranceValue = isnull(Item_single_value*item_quantity,0)*100
from @Addons
where SKU in ('H01H002','E02E011')

--print '@insuranceValue'
--print @insuranceValue
	

---- Add Payment Records

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

INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('@TicketDistributionType'           
           ,getdate()         
           ,@TicketDistributionType
           )

INSERT INTO [dbo].[Logs]
           ([ApplicationName]   
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('@Distribution_Type_ID'           
           ,getdate()         
           ,cast(@Distribution_Type_ID as varchar(100))
           )



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
	if @TicketDistributionType = 'E TICKET'
		BEGIN
			set @TicketQueue = 'E'
			 
		END
	
	

---- (2) mTicket
		if @TicketDistributionType = 'M TICKET'
			BEGIN
				set @TicketQueue = 'M'
				EXEC cp_Queue_Add_M_Ticket @sale_id, @Ticket,@LeadPaxTelephone,'Q'
			END


----	 (3) Post Out
		if @TicketDistributionType =  'Local Post Out'
			BEGIN			
				set @TicketQueue = 'P'
				DECLARE @additioalProducts BIT
				SET @additioalProducts=0
				if(@AddonCount>0)
				BEGIN
					SET @additioalProducts=1
				END
				EXEC cp_Queue_Add_Post_Out @sale_id, @Ticket,@agent,@additioalProducts,@from_location,@to_location,'Q'
			END
	

------ (4) Remote Collect
		if @TicketDistributionType = 'REMOTE COLLECT'
			BEGIN
				set @TicketQueue = 'R'
				EXEC cp_Queue_Add_Remote_Collect @sale_id, @Ticket,'',@departure_date_time,'Q'
			END

---------(8) TravelShop /Kiosk
		if @TicketDistributionType ='Retail Site Outlet'
		BEGIN
			--print 'Third Party API'
			set @TicketQueue = 'R'
		END

---- Add Sales Item Transaction

EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,8


---- Add Coachcards

	INSERT INTO [dbo].[tbl_Pass_Use]
           ([sale_ID]
           ,[Pass_Number]
           ,[Pass_Type]
           ,[NMP_Id]
      )
    SELECT
           @Sale_ID
		   ,serialnumber
		   ,case type
				when 'YoungPerson' then 'ST'
				when 'Family1plus1' then 'AD'
				when 'Senior' then 'CF'
				when 'Disabled' then 'CF'
			else 
				'AD'
			end
		    ,0

	FROM OPENXML (@docHandle, 'Ticket/Coachcards/Coachcard')
	WITH (
			type			varchar(50) '@type'
			,serialnumber	varchar(50) '@serialnumber'
		 )
		


---- Add Summary Records
-- (1) Basket summary
       declare @highestFarePaid int

	   declare @highestFarePaidSoFar int

	   select
			@highestFarePaidSoFar =max ([Highest_Fare_Paid_To_Date])
	   from
			dbo.tbl_basket_summary
	   where ticketno = @ticket
		

	   if @highestFarePaidSoFar > @totalFare * 100   --SMAREP-1916 - UP
			BEGIN
				set @highestFarePaid = @highestFarePaidSoFar
			END
		ELSE
			BEGIN
				set @highestFarePaid = @totalFare * 100 --SMAREP-1916 - UP
			END


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
             ,'Z'
			 ,'A'
             ,0
             ,@highestFarePaid
             ,0
             ,0

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
           ,@Faretype
          ,(@FareValue *100)
          ,@JrnyType
          ,@TicketQueue
          ,@RemoteCollectLocation
          ,@to_location
          ,@DeptDate)
        
print 'Paying'
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
             

--(4) Misc Info
             INSERT INTO [dbo].[tbl_Misc_Basket_Info]
           ([Sale_ID]
           ,[Alteration_Fee]
           ,[OverrideReason]
           ,[OverridingClerk]
           ,[InsuranceAmount]
           ,[Passownrisk])
    
             VaLUES ( @Sale_id
                    ,isnull(@AmendmentFeeValue,0)
                    ,''
                    ,''
                    ,isnull(@insuranceValue,0)
                    ,0 )
             

print 'misc'

 --Close Basket
EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,10

 
--

select @SaleID = @sale_id
select @RESULT = 1
select @Message = 'Ticket Amended Successfully'
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


