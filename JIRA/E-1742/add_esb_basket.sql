USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_Add_ESB_Basket_Reservation_V2]    Script Date: 11/2/2021 10:27:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*
- =============================================
-- Author		:
-- Create date	: 
-- Description	:	 
-- ============ Change History ================ 
-- Modified By   : Urvashi Trivedi
-- Modified Date : 22-April-2020
-- Description	: ESBS-673
-- =============================================
-- Modified By   : Iain McFarlane
-- Modified Date : 15-Jun-2020
-- Description	 : SMAREP-1300 Ensure correct currency recorded for transaction
 =============================================	
 Modified By   : Iain McFarlane
-- Modified Date : 16-Apr-2021
-- Description	 : ECR8635 Fix to only insert into tbl_Consumers_Additional_Details where @agent = 'NXDSK'
 =============================================	
 Modified BY : Iain McFarlane
 -- Modified Date : 16-Apr-2021
-- Description	 : ECR8635 Fix to only insert into tbl_Consumers_Additional_Details where  @leadPaxID not in  -------(0,1,2,3,4,5,5445592,5445601,5445609)
=================================
*/

ALTER procedure [dbo].[cp_Add_ESB_Basket_Reservation_V2]
(
 @TicketXML ntext
,@TicketNo char(8)OUTPUT
,@SaleID Int output
)
AS
/*
NOTE ALL PRICES ARE EXPRESSED IN PENCE
*/
BEGIN

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
declare @errorCheck int
declare @PaymentProvider varchar(50)
DECLARE @tId uniqueidentifier
declare @PaymentAccount varchar(250)
declare @PaymentID int
declare @ThirdPartyRef varchar(100)


INSERT INTO [dbo].[Logs]
           ([ApplicationName]          
           ,[LogTime]          
           ,[Request]
           )
     VALUES
           ('Add ESB Reservation'           
           ,getdate()         
           ,@TicketXML
           )



 --retrieve agent user ID
	select 
			@Ticket = ticketnumber,
			@agent = agentcode, 
			@user= agentuser,
			@Channel = SalesChannel,			
			@JrnyType = upper(JourneyType),
			@ThirdPartyRef = thirdPartyReference
			

	FROM Openxml( @docHandle , 'Ticket' ) 
	WITH ( 
			ticketnumber		char(8)		'@ticketNumber'
		   ,agentcode			char(5)		'@agentCode'
		   ,agentuser			char(8)		'@agentUser'
		   ,saleschannel		char(15)	'@salesChannel'		   
		   ,journeyType			char(1)		'@journeyType'
		   ,thirdPartyReference varchar(100) '@thirdPartyReference'	 
		   )



----print 'agent'
----print @agent
----print '[user]'
----print @user
----print @ticket
----print @channel
----print @transtype
----print @jrnytype

		EXECUTE @RC =   [dbo].[cp_Get_Agent_User_ID_V2]
		   @agent
		  ,@user
		  ,@agent_user_id OUTPUT

		-- ErrorCheck
		Set @errorCheck = @@error
		if (@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end


----print @agent_user_id

declare @SalesChannelID int

SELECT 
     @SalesChannelID= isnull([sales_channel_id],4)
     
  FROM [NXLookup].[dbo].[tbl_Agent_Sales_Channel]
where agent_code = @Agent



 -- basket

EXECUTE @RC =   [dbo].[cp_Add_Sale_V2]
   @agent_user_id
  ,0
  ,@SAlesChannelID
  ,@sale_id OUTPUT

-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end

----print @sale_id


-- Extract Fare Information from XML

declare @FareValue as money
declare @FareType as char(3)
declare @outBoundJourneySideFare money
declare @inBoundJourneySideFare money



select
	@FareValue = cast(value as money)/100
	,@FareType = type
	,@outBoundJourneySideFare = outBoundJourneySideFare
	,@inBoundJourneySideFare = inBoundJourneySideFare
	FROM Openxml( @docHandle , 'Ticket/Fare' ) 
		with (
				value						int		'@netPrice'
				,type						char(3) '@type'
				,outBoundJourneySideFare	int		'@outBoundJourneySideFare'
				,inBoundJourneySideFare		int		'@inBoundJourneySideFare'
			)
			
----print '@outBoundJourneySideFare' 
----print  cast(@outBoundJourneySideFare as varchar(10))

----print '@inBoundJourneySideFare' 
----print cast(@inBoundJourneySideFare as varchar(10))

			  
-- default JourneySide Fares			  
if @outBoundJourneySideFare is NULL 
	begin
		--print '@outBoundJourneySideFare is NULL'
		if @JrnyType = 'S' or @JrnyType = 'O'
			begin
				set @outBoundJourneySideFare = @FareValue
			end
		else
			begin
				set @outBoundJourneySideFare = @FareValue * 0.5
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
	
-- Set transaction type

set @sale_item_type_id = 1

DECLARE @Travel_sales_item_id int

EXECUTE @RC =   [dbo].[cp_Add_Sales_Item]
   @sale_id
  ,@sale_item_type_id
  ,1
  ,@ticket
  ,@FareValue
  ,1
  ,@Travel_sales_item_id OUTPUT
  ,''


-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end
	
-- Insert Journey Side Fares
INSERT INTO [dbo].[tbl_Journey_Side_Fares]
           ([OutBoundJourneySideFare]
           ,[InBoundJourneySideFare]
           ,[Sale_ID])
     VALUES
           (@OutBoundJourneySideFare
           ,@InBoundJourneySideFare
           ,@sale_id)
           
-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end





--


select @ticket_id = ticket_id
from
	dbo.tbl_Tickets
where
	ticket_serial = @Ticket

--INSERT INTO [dbo].[Logs]
--           ([ApplicationName]          
--           ,[LogTime]          
--           ,[Request]
--           )
--     VALUES
--           ('@ticket_id when retrieved'           
--           ,getdate()         
--           ,cast(@ticket_id as varchar(100))
--           )


----print 'SalesItemID:'
----print @Travel_sales_item_id


 --add sale item transactions - basket item - added

EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
   @Travel_sales_item_id
  ,1
  ,@sales_item_transaction_id OUTPUT

-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end

 --add journey type

EXECUTE @RC =   [dbo].[cp_Add_Ticket_Journey_Type_V3]
   @ticket
  ,@JrnyType
  ,@sale_id

-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end


 --Add Legs

INSERT dbo.tbl_SmartJourneyLegs
		(
			sales_item_id, 
			leg_number, leg_direction, 
			from_location_code,							
			to_location_code, 
			from_stop, 
			to_stop, 
			company_brand_code, 
			service, 
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
			leg_no, 
			leg_dir, 
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
			dept_date, 
			check_in_time,
			dept_time, 
			arr_date, 
			arr_time, 
			arr_day, 
			gd_trigger_level, 
			fare_type,
			coupon_fare_value, 
			actual_fare_value, 
			through_fare_leg, 
			special_fare_id,
			booking_ref, 
			attraction_id, 
			cust_info_id, 
			fail_cd, 
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
		[dept_date]				[int]		'dept_date',
		[check_in_time]			[smallint]	'check_in_time',
		[dept_time]				[int]		'dept_time',
		[arr_date]				[int]		'arr_date',
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

-- ErrorCheck
Set @errorCheck = @@error
if @errorCheck <> 0
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end

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
      leg_no,
      leg_dir,
	  from_loc,
	  to_loc,
	  dateadd(s, dept_date + (dept_time * 60), '01-Jan-1970 00:00:00' ),
	  dept_date 


	FROM OPENXML (@docHandle, 'Ticket/Legs/Leg')
	WITH (

		[leg_no]				[int]		'leg_no',
		[leg_dir]				[char] (1)	'leg_dir',
		[from_loc]				[char] (5)	'from_loc',
		[to_loc]				[char] (5)	'to_loc',
		[dept_date]				[int]		'dept_date',
		[dept_time]				[int]   'dept_time'
		)


select @from_location = from_loc from @templegs where leg_no = 0
select @departure_date_time = dept_date_time from @templegs where leg_no = 0
select @DeptDate = dept_date from @templegs where leg_no = 0
select @to_location = to_loc from @templegs where leg_dir = 'O' and leg_no = (select max(leg_no) from @templegs where leg_dir = 'O')

 --Add Sales Item Transaction / Amended in EXTRA
EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
   @Travel_sales_item_id
  ,2
  ,@sales_item_transaction_id OUTPUT		

-- ErrorCheck
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end

-- Add ThirdPartyReference If Supplied
if @ThirdPartyRef is NOT NULL
BEGIN
	INSERT INTO [dbo].[tbl_Third_Party_Reference]
           
     VALUES
           (@Travel_sales_item_id
           ,@ThirdPartyRef)

	-- ErrorCheck
	Set @errorCheck = @@error
	if (@errorCheck <> 0 or @RC <> 0)
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end
END


-- Extract Lead Passenger Details from XML

declare @LeadPaxTitle varchar(5)
declare @LeadPaxFirstName varchar(40)
declare @LeadPaxSurname varchar(40)
declare @LeadPaxTelephone varchar(15)
declare @LeadPaxPostOutConsent bit
declare @LeadPaxEmailConsent bit
declare @LeadPaxTelephoneConsent bit
declare @LeadPaxGender varchar(10)
declare @LeadPaxDOB char(10)


	select
		@LeadPaxTitle = title
		,@LeadPaxFirstName = firstname
		,@LeadPaxSurname  = surname
		,@LeadPaxTelephone = telephone
		,@LeadPaxPostOutConsent = case PostConsent when 'true' then 1 else 0 end 
		,@LeadPaxEmailConsent = case emailconsent when 'true' then 1 else 0 end 
		,@LeadPaxtelephoneConsent = case phoneconsent when 'true' then 1 else 0 end 
    ,@LeadPaxGender = Gender
    ,@LeadPaxDOB = DateOfBirth
	FROM Openxml( @docHandle , 'Ticket/LeadPassenger' ) 
	WITH ( 
			title			varchar(5)		'@title',
			firstname		varchar(40)	'@firstName',
			surname			varchar(40)	'@surname',
			telephone		varchar(15)	'@telephone',
			PostConsent		char(5)		'@postOutConsent',
			EmailConsent	char(5)		'@emailConsent',
			Phoneconsent	char(5)		'@telephoneConsent',
            Gender          varchar(10) '@gender',
            DateOfBirth     char(10)    '@dateOfBirth')


--print '@LeadPaxDOB'
--print @LeadPaxDOB
 --extract Distribution Details

declare @TicketDistributionType varchar(20)
declare @EmailAddress varchar(128)
declare @SMSPhoneNo varchar(15)
declare @RemoteCollectLocation varchar(8)

		select
			@TicketDistributionType = distributiontype
			,@EmailAddress = Email
			,@SMSPhoneNo = isnull(mTicketPhone,'')
			,@RemoteCollectLocation = isnull(collectionlocation,'')

		FROM OPENXML ( @docHandle , 'Ticket/DistributionDetails' ) 
		with ( 
				distributiontype	varchar(20)	'@distributionType', --distributionType
				email				varchar(128)	'@email',
				mTicketPhone		varchar(15)	'@mTicketPhone',
				collectionlocation	varchar(8)		'@collectionLocation'

				)


--		select 
--			@TicketDistributionType = DistributionType
--		from OPENXML ( @docHandle , 'Ticket/DistributionDetails' ) 
--		with (
--				DistributionType	char(15)	'DistributionType'
--			  )
--		

----print 'distributiontype' + '-' + @TicketDistributionType

--INSERT INTO [dbo].[Logs]
--           ([ApplicationName]          
--           ,[LogTime]          
--           ,[Request]
--           )
--     VALUES
--           ('@TicketDistributionType from xml'           
--           ,getdate()         
--           ,@TicketDistributionType
--           )

--print 'Email'		
--print @emailAddress


 --Determine Lead Pax Type Title
declare @Title_id int

select @Title_id = title_id
FROM  dbo.tbl_Titles
				where title = @LeadPaxTitle

 --Determine Pax Type of Lead Pax

declare @LeadPaxConsumerType int
declare @LeadPaxID int
declare @Address1 varchar(40)
declare @Town varchar(40)

declare @Pax table

	(ID int IDENTITY(1,1),
	paxtype char(2)	
	,consumer_type_id int
	,generic_consumer_id int
	,title char(5)
	,forename varchar(40)
	,surname varchar(40)
	,gender varchar(10)
	,dateofbirth char(10)
	)
	
	
insert into @Pax
SELECT [type],  
		consumer_type_id,
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
		end as generic_consumer,
		title,
		forename,
		surname,
		gender,
		dateofbirth
		
 FROM OpenXml( @docHandle , 'Ticket/Passengers/Passenger' , 1)    
 WITH
  ( [type] char(3) '@type'
    ,surname varchar(40)
	,forename varchar(40)
	,title char(5)
	,gender varchar(10)
	,dateOfBirth char(10)   
   )
	 X
	join dbo.tbl_Consumer_Types CT
		on X.type = CT.Passenger_Type_Code

---- extract over60s count

declare @Over60Count int

select
	@Over60Count = isnull(Over60s,0)
FROM OpenXML ( @docHandle , 'Ticket/Passengers' , 1)    
WITH
	(Over60s int '@Over60s')


 --Determine Pax type of lead passenger (assumption is the first passenger)
select @LeadPaxConsumerType = consumer_type_id 
from @Pax
where ID = 1

-- Add Lead Passenger

-- Check to see if lead passenger provided 

iF (@LeadPaxSurname is NULL and @EmailAddress is  NULL)
	BEGIN
		-- insert generic lead passenger
        --print 'Generic Lead Pax'
		select @LeadPaxConsumerType = consumer_type_id 
			from @Pax
			where ID = 1

		set @leadPaxID = @LeadPaxConsumerType
		--print @LeadPaxConsumerType
		--print @LeadPaxID



		EXECUTE @RC =   [dbo].[cp_Add_Item_Consumer]
			   @Travel_sales_item_id
			  ,@LeadPaxConsumerType
			  ,0
			  ,1
			  ,@ITEM_CONSUMER_id OUTPUT   
			
		-- ErrorCheck
		Set @errorCheck = @@error
		if (@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end    

	end 


ELSE
	BEGIN
		 INSERT INTO dbo.tbl_Consumers
						   (
						  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
						  related_consumer_id , relation_type_id, consumer_role_id, sale_id,gender,[dateOfBirth]
						   )
					 SELECT
		                   
							@LeadPaxConsumerType
							,isnull(@Title_id,0)
							,isnull(@LeadPaxFirstName,'')
							,isnull(@LeadPaxSurname,'')
							,0
							,0
							,0
							,getdate()
							,0
							,0
							,6
							,@sale_id
							,@LeadPaxGender
							,@LeadPaxDOB

					-- ErrorCheck
					Set @errorCheck = @@error
					if @errorCheck <> 0
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end
		                 
				set @LeadPaxId = SCOPE_IDENTITY()

		--              add item consumer record
					 EXECUTE @RC =   [dbo].[cp_Add_Item_Consumer]
					   @Travel_sales_item_id
					  ,@LeadPaxId
					  ,0
					  ,1
					  ,@ITEM_CONSUMER_id OUTPUT   
					
					-- ErrorCheck
					Set @errorCheck = @@error
					if (@errorCheck <> 0 or @RC <> 0)
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end       
		 
		--	   add address record
		select 
			@Address1 = address1
			,@town = town
		FROM OpenXML ( @docHandle, 'Ticket/LeadPassenger/Address')
					With ( 
							Address1	varchar(40)	'Address1'
							,Town		varchar(40)	'Town'
						) 

		if (@Address1 is not null and @town is not null) -- must have Address1 and Town to add an address
			BEGIN
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

					-- ErrorCheck
					Set @errorCheck = @@error
					if @errorCheck <> 0
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end

					SET @address_id = SCOPE_IDENTITY()

		--              add consumer address record(s)                           
		----print  '@address_id'
		----print  @address_id
		----print '@LeadPaxId'
		----print @LeadPaxId

					 EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]
					   @LeadPaxId
					  ,@address_id
					  ,0
					  ,0
					  ,1
					  ,@consumer_address_id OUTPUT   

					  -- ErrorCheck
					Set @errorCheck = @@error
					if (@errorCheck <> 0 or @RC <> 0)
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end
               END -- End of Add Address
		----		 Add email
			
					if @EmailAddress is not null
					BEGIN
						  	-- GDPR Change for M121/SAG/NX Colo Mobile to prevent Soft Opt In (ESB-361)
							if  (@agent = 'S610' or @agent = 'NXHQ' or @agent= 'NXMWB')
							BEGIN
								SET @LeadPaxEmailConsent = NULL
							END

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
									@LeadPaxEmailConsent) --(ESB-361)

						-- ErrorCheck
						Set @errorCheck = @@error
						if @errorCheck <> 0
							begin
								EXEC sp_xml_removedocument @docHandle
								return @errorCheck
							end
					END


		----		 Add telephone

					if @LeadPaxTelephone is not null
						BEGIN
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

							-- ErrorCheck
							Set @errorCheck = @@error
							if @errorCheck <> 0
								begin
									EXEC sp_xml_removedocument @docHandle
									return @errorCheck
								end
						END
						
--add consumer consents					
		INSERT INTO [dbo].[tbl_Consumer_Consents]
           ([DateCreated]
           ,[Consumer_ID]
           ,[Via_Email]
           ,[Via_SMS] 
		   ,[NX_White_Coach]
		   ,[Third_Party_Travel]
		   ,[Third_Party_Leisure_And_Entertainment]
		   ,[Third_Party_Shopping]
		   ,[Third_Party_Betting_and_Gambling]
		   ,[Third_Party_Discounts_Offers_and_Competitions]
		   ,[Third_Party_Events]
		   ,[Third_Party_Money_and_Finance]
		   ,[NXAccountID]
           )
    SELECT
            getdate()
		   ,@LeadPaxId
		   ,viaEmail = case viaEmail when 'true' then 1 when 'false' then 0 else null end 
			,viaSMS = case viaSMS when 'true' then 1 when 'false' then 0 else null end 
			,nxWhiteCoach = case nxWhiteCoach when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyTravel = case thirdPartyTravel when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyLeisure = case thirdPartyLeisure when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyShopping = case thirdPartyShopping when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyGambling = case thirdPartyGambling when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyOffers = case thirdPartyOffers when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyEvents = case thirdPartyEvents when 'true' then 1 when 'false' then 0 else null end 
			,thirdPartyFinance = case thirdPartyFinance when 'true' then 1 when 'false' then 0 else null end 
			,nxAccountID 
	FROM OPENXML (@docHandle, 'Ticket/LeadPassenger/ContactMethods')
	WITH (
		viaEmail char(5) '@viaEmail'
			,viaSMS char(5) '@viaSMS'
			,nxWhiteCoach char(5) '@nxWhiteCoach'
			,thirdPartyTravel char(5) '@thirdPartyTravel'
			,thirdPartyLeisure char(5) '@thirdPartyLeisure'
			,thirdPartyShopping char(5) '@thirdPartyShopping'
			,thirdPartyGambling char(5) '@thirdPartyGambling'
			,thirdPartyOffers char(5) '@thirdPartyOffers'
			,thirdPartyEvents char(5) '@thirdPartyEvents'
			,thirdPartyFinance char(5) '@thirdPartyFinance'
			,nxAccountID char(40) '@nxAccountID'
		)	

	-- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end		
						
						
						
	END -- end of add lead passenger 

---- Add Passengers

	--INSERT INTO   [dbo].[tbl_Item_Consumer]
 --          ([sale_item_id]
 --          ,[consumer_id]
 --          ,[fare_id]
 --          ,[active]
 --          )
	--select
	--	   @travel_sales_item_id
	--	   ,generic_consumer_id
	--	   ,0
	--	   ,1
	--from
	--	@Pax
	--where ID <> 1

	-- ErrorCheck
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end

    -- E & B Change - add additional passengers as a loop

	declare @PaxCount int
	declare @ItemConsumerID int
	select @Paxcount = count(ID) from @Pax
	if @PaxCount > 1 
	BEGIN
		declare @PaxArray int
		-- Set Counter
		set @PaxArray = 2 -- No 1 is the Lead Pax
		-- check counter
		while @PaxArray <= @PaxCount
		BEGIN
		-- Check to see if Generic Pax or not
			IF exists (select 1 from @Pax 
							where ID = @PaxArray and surname is not NULL)
				BEGIN
					INSERT INTO dbo.tbl_Consumers
						   (
						  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
						  related_consumer_id , relation_type_id, consumer_role_id, sale_id,gender,[dateOfBirth]
						   )
					 SELECT
		                   
							consumer_type_id
							,isnull(Title_id,0)
							,isnull(forename,'')
							,isnull(surname,'')
							,0
							,0
							,0
							,getdate()
							,0
							,0
							,NULL
							,@sale_id
							,gender
							,dateofbirth
					from
						@Pax Pax
						left join tbl_titles T
							on Pax.Title = T.title  collate database_default
					where
						Pax.ID = @PaxArray

					-- ErrorCheck
					Set @errorCheck = @@error
					if @errorCheck <> 0
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end
		                 
					set  @ItemConsumerID = SCOPE_IDENTITY()

					 --add item consumer record
					 EXECUTE @RC =   [dbo].[cp_Add_Item_Consumer]
					   @Travel_sales_item_id
					  ,@ItemConsumerID
					  ,0
					  ,1
					  ,@ITEM_CONSUMER_id OUTPUT   
					
					-- ErrorCheck
					Set @errorCheck = @@error
					if (@errorCheck <> 0 or @RC <> 0)
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end       


				END -- end add named passenger
			ELSE
				-- if Generic add consumer record
				BEGIN
					INSERT INTO   [dbo].[tbl_Item_Consumer]
						   ([sale_item_id]
						   ,[consumer_id]
						   ,[fare_id]
						   ,[active]
						   )
					select
						   @travel_sales_item_id
						   ,generic_consumer_id
						   ,0
						   ,1
					from
						@Pax
					where ID = @PaxArray

					-- ErrorCheck
					Set @errorCheck = @@error
					if (@errorCheck <> 0 or @RC <> 0)
						begin
							EXEC sp_xml_removedocument @docHandle
							return @errorCheck
						end  

				END -- Add Generic consumer
		-- increment counter
		    set @PaxArray = @PaxArray +1
		END -- while loop
	END -- add additional passengers


---- Add Addons

DECLARE @AddonCount int

declare @ID int
declare @Addon_sales_item_id int
declare @Product_id Int
declare @Item_value money
declare @Item_quantity int

----print 'addon started'

---- create table variable
declare @Addons table
	( ID int IDENTITY(1,1),
	  SKU char(7),
	  Product_id int,
	  Serial varchar(15),
	  Item_single_value money,	  
	  Item_quantity int,
	  From_date datetime,
	  To_date datetime
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
	FROM OpenXML (@docHandle, 'Ticket/Addons/Addon')
with(
			SKU				char(7)		'SKU',
			item_value		int			'Item_value',
			item_quantity	int			'Item_quantity',
			serial			varchar(15)	'Serial',
			valid_from		datetime	'Valid_from',
			valid_to		datetime	'Valid_to'
			) Addons
		join dbo.tbl_Products P
			on Addons.SKU = (P.SMART_product_type_code +P.SMART_product_code)

		set @AddonCount = @@rowcount

		----print 'number of addons'
		----print @AddonCount
		

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

			-- ErrorCheck
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end	

----			 aDD ITEM Transaction
			EXECUTE @RC =   [dbo].[cp_Add_Sales_Item_Transaction]
			   @Addon_sales_item_id
			  ,14
			  ,@sales_item_transaction_id OUTPUT

			-- ErrorCheck
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end
					
----			 increment loop counter
			----print @ID
			set @ID = @ID +1	 
	   end
	end


-- check for Insurance

declare @InsuranceValue int

select  @InsuranceValue = isnull(Item_single_value*item_quantity,0)*100
from @Addons
where SKU in ('H01H002','E02E011')

----print '@insuranceValue'
----print @insuranceValue
	

---- Add Payment Records----------------------------------------------------------

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
declare @CurrencyCode char(3)
declare @CurrencyID int


select  @PaymentValue = cast(payment_value as money)/100
		,@PaymentType = payment_type
		,@CurrencyCode = currency
		
from OPENXML ( @docHandle,'Ticket/Payment')
With (
		payment_value	int			'@payment_value'
		,payment_type	varchar(20) '@payment_type'
		,currency       char(3)		'@currency'
		
	  )
--print 'CurrencyCode'
--print @CurrencyCode

select @payment_type_id = payment_type_id  from dbo.tbl_Payment_Types where payment_type = @PaymentType
select @CurrencyID = isnull([currency_id],0) from [dbo].[tbl_Currency_Types] where [currency_type] = @CurrencyCode


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
			)
	---- check to see payment transaction record does not already exist
	DECLARE @card_type_id int 

	if @Channel = 'OBT'
		begin
			--print 'OBT Card Payment'
			set  @card_details_id = 0
			select @payment_type_id = payment_type_id  from dbo.tbl_Payment_Types where payment_type = 'card_OBT'
		end 

	if @Channel = 'Kiosk'
		begin
			--print  'Kiosk Card Payment'

			select 	
				@card_type_id =titan_card_type_id
				,@Payment_Provider_id = CTM.payment_provider_id
			from 
				NXLookup.dbo.tbl_Payment_Provider_Card_Type_Mappings CTM
				join NXLookup.dbo.tbl_Payment_Providers PP
					ON CTM.payment_provider_id = PP.id
						and PP.[name]= @PaymentProvider
						and CTM.provider_specific_card_id = @cardtype
			
			SET @tId = newid()
		----print 'Params'
		----print @Payment_Provider_id
		----print @tId
		----print @PaymentProviderReference
		----print @cardtype
		----print @ticket
		----print @Channel
		EXECUTE [dbo].[cp_Insert_Payment_Provider_Chip_and_Pin] 
		   @payment_provider_id
		  ,@tId
		  ,@PaymentProviderReference
		  ,@card_type_id
		  ,0
		  ,''
		  ,@AuthCode
		  ,@LastFour
		  ,''
		  ,@Sale_ID
		  ,@payment_provider_transaction_id OUTPUT

		-- error check
		Set @errorCheck = @@error
		if(@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
		----print 'OUT'
		----print @Payment_Provider_Record_id
				
		-- Add Card Details
		
		exec @RC = dbo.cp_Add_Card_Details_v2 
			@card_type_id,
			@LastFour,
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
		Set @errorCheck = @@error
		if (@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
	
		end 
	
	

	if @Channel = 'Web'
		BEGIN
			select 	
				@card_type_id =titan_card_type_id
				,@Payment_Provider_id = CTM.payment_provider_id
			from 
				NXLookup.dbo.tbl_Payment_Provider_Card_Type_Mappings CTM
				join NXLookup.dbo.tbl_Payment_Providers PP
					ON CTM.payment_provider_id = PP.id
						and PP.[name]= @PaymentProvider
						and CTM.provider_specific_card_id = @cardtype
		
			-- CODE FOR ADDITING payment Transaction 
		
			SET @tId = newid()
			----print 'Params'
			----print @Payment_Provider_id
			----print @tId
			----print @PaymentProviderReference
			----print @cardtype
			----print @ticket
			----print @Channel
			exec @RC =  cp_insert_payment_provider_transaction_v3 @Payment_Provider_id,@tId,@PaymentProviderReference,@card_type_id,0,'','','',@ticket,@Payment_Provider_Record_id OUT

			-- error check
			Set @errorCheck = @@error
			if(@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end
			----print 'OUT'
			----print @Payment_Provider_Record_id
				
			----update existing record with Sale_id
			update dbo.tbl_Payment_Provider_Transactions
			set sale_id = @Sale_id
			where unique_transaction_reference = @PaymentProviderReference

			-- error check
			Set @errorCheck = @@error
			if @errorCheck <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end


			-- Add Card Details
		
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
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end
		END 
END -- add card related details


-- PayPal Change
if @PaymentType = 'PayPal'

BEGIN
	--print 'Payment Type is PayPal'
	
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
		----print 'Params'
		----print @Payment_Provider_id
		----print @tId
		----print @PaymentProviderReference
		----print @cardtype
		----print @ticket
		----print @Channel
		exec @RC =  cp_insert_payment_provider_transaction_v3 @Payment_Provider_id,@tId,@PaymentProviderReference,0,0,'','','',@ticket,@Payment_Provider_Record_id OUT

		-- error check
		Set @errorCheck = @@error
		if(@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
		----print 'OUT'
		----print @Payment_Provider_Record_id
				
		----update existing record with Sale_id
		update dbo.tbl_Payment_Provider_Transactions
		set sale_id = @Sale_id
		where unique_transaction_reference = @PaymentProviderReference

		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end




END -- end of PayPal Payment Type


-- Amazon Pay
if @PaymentType = 'AmazonPay'

BEGIN
	--print 'Payment Type is AmazonPay'
	
	select 
			@PaymentProviderReference = payment_provider_transaction_id
			,@PaymentProvider = payment_provider
			,@PaymentAccount = account
	FROM OPENXML ( @docHandle,'Ticket/Payment/AmazonPayDetails')
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
		----print 'Params'
		----print @Payment_Provider_id
		----print @tId
		----print @PaymentProviderReference
		----print @cardtype
		----print @ticket
		----print @Channel
		exec @RC =  cp_insert_payment_provider_transaction_v3 @Payment_Provider_id,@tId,@PaymentProviderReference,0,0,'','','',@ticket,@Payment_Provider_Record_id OUT

		-- error check
		Set @errorCheck = @@error
		if(@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
		----print 'OUT'
		----print @Payment_Provider_Record_id
				
		----update existing record with Sale_id
		update dbo.tbl_Payment_Provider_Transactions
		set sale_id = @Sale_id
		where unique_transaction_reference = @PaymentProviderReference

		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end




END -- end of Amazon Pay Type

if @card_details_id is null set @card_details_id = 0
if @MerchantID is null set @MerchantID = ''
if @TerminalID is null set @TerminalID = ''

--print 'card details id'
--print @card_details_id

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
           ,@AuthCode
           ,@MerchantID 
           ,@TerminalID
           ,0
           ,@CurrencyID --1
           ,@PaymentValue
           ,getdate()
           ,@Sale_id
           ,0
           ,0
           ,@Payment_Provider_id
           ,@Payment_Provider_Record_id --this needs sorting 
           )
           
set @PaymentID = scope_identity()

-- error check
Set @errorCheck = @@error
if @errorCheck <> 0
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end
-- add payment account if relevant	
if @PaymentProvider in ('PayPal', 'AmazonPay') and @PaymentAccount is not NULL
	BEGIN
		-- store PayPal account details
		INSERT INTO [dbo].[tbl_Payment_Account]
			   ([Payment_ID]
			   ,[Payment_Account])
		 VALUES
			   (@PaymentID
			   ,@PaymentAccount)

	END

	-- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end

----------------------------------------------------------------------- Payment Insertion Area Finish
---- SAles Item Transaction Payment

EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,7

-- error check
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end

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


--print '@TicketDistributionType -' + @TicketDistributionType

--INSERT INTO [dbo].[Logs]
--           ([ApplicationName]          
--           ,[LogTime]          
--           ,[Request]
--           )
--     VALUES
--           ('@TicketDistributionType'           
--           ,getdate()         
--           ,@TicketDistributionType
--           )

--INSERT INTO [dbo].[Logs]
--           ([ApplicationName]          
--           ,[LogTime]          
--           ,[Request]
--           )
--     VALUES
--           ('@Distribution_Type_ID'           
--           ,getdate()         
--           ,cast(@Distribution_Type_ID as varchar(100))
--           )



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

	-- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end


	

---- (1) ETicket
	if @TicketDistributionType = 'E TICKET'
		BEGIN
			set @TicketQueue = 'E'
		END
	
	

---- (2) mTicket
	if @TicketDistributionType = 'M TICKET'
		BEGIN

		set @TicketQueue = 'M'
		
----		 add sms number
		INSERT into dbo.tbl_Phone_Contacts
                 (
                consumer_id ,
                number ,
                number_type ,
                marketing_consent ,
                preferred,
				PhoneTypeID
                 )

           Values
                (@LeadPaxId ,
                @SMSPhoneNo ,
                '',
                @LeadPaxTelephoneConsent ,
                0,
				5)

		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end

----		 add to queue
			EXECUTE @RC = [dbo].[cp_Queue_Add_M_Ticket] 
					   @sale_id
					  ,@ticket
					  ,@SMSPhoneNo
					  ,'R'

			-- error check
			Set @errorCheck = @@error
			if @errorCheck <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end

		END

----	 (3) Post Out
		if @TicketDistributionType =  'Local Post Out'
			BEGIN

			declare @DeliveryTitle varchar(5)
			declare @DeliveryFirstName varchar(40)
			declare @DeliverySurname varchar(40)
			declare @DeliveryConsumerID int	

			set @TicketQueue = 'P'

			select
				@DeliveryTitle = title
				,@DeliveryFirstName = firstName
				,@DeliverySurname  = surname
			FROM Openxml( @docHandle , 'Ticket/DistributionDetails/DeliveryTo' ) 
			WITH ( 
					title			varchar(5)	'@title',
					firstName		varchar(40)	'@firstName',
					surname			varchar(40)	'@surname'
					)

			select @Title_id =title_id
			from
				dbo.tbl_Titles
			where
					title	= @DeliveryTitle

----	 add consumer record

		----print 'DeliveryFirstName'
		----print @DeliveryFirstName
		----print 'add delivery to consumer'
		INSERT INTO dbo.tbl_Consumers
                   (
                  consumer_type_id , title_id, forename, surname , suffix, coachcard_id, age_range_id, date_created,
                  related_consumer_id , relation_type_id, Consumer_Role_id, Sale_id
                   )
             SELECT
                   
                     @LeadPaxConsumerType
                    ,isnull(@Title_id,0)
                    ,@DeliveryFirstName
                    ,@DeliverySurname
                    ,0
                    ,0
                    ,0
                    ,getdate()
                    ,0
                    ,0
					,8
					,@sale_id
		
		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
                 
        set @DeliveryConsumerID = SCOPE_IDENTITY()
				
----	 add address record

		 ----print 'add delivery to address'

         INSERT INTO dbo.tbl_Addresses
               (
              address1 ,
              address2 ,
              address3 ,
              town ,
              county_id ,
              country_id ,
              postcode,
			  [AddressTypeID])
		
         select                  
          [address1]
          ,isnull([address2],'')
          ,isnull([address3],'')
          ,[town]
          ,isnull([county_id],0)
          ,isnull([country_id],0)
          ,isnull([postcode],'')
		  , 3
		FROM OpenXML ( @docHandle, 'Ticket/DistributionDetails/DeliveryTo/Address')
			With (
					Address1	varchar(40)	'Address1'
					,Address2	varchar(40)	'Address2'
					,Address3	varchar(40)	'Address3'
					,Town		varchar(40)	'Town'
					,PostCode	varchar(8)	'PostCode'
					,County		varchar(40)	'County'
					,Country	varchar(60)	'Country'
				) DA
			left join dbo.tbl_Countries CO
				on DA.Country = CO.country
			left join dbo.tbl_Counties COU
				on DA.County = COU.county

			-- error check
			Set @errorCheck = @@error
			if @errorCheck <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end

			SET @address_id = SCOPE_IDENTITY()


		-- Add Consumer Address record

		----print 'add delivery to consumer address record'

		 EXECUTE @RC = [dbo]. [cp_Add_Consumer_Address]
               @DeliveryConsumerID
              ,@address_id
              ,0
              ,0
              ,1
              ,@consumer_address_id OUTPUT 

		-- error check
		Set @errorCheck = @@error
		if (@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
		-- add to queue

		----print 'add to ----print queue'

		EXECUTE @RC = [dbo].[cp_Queue_Add_Post_Out] 
		   @sale_id
		  ,@ticket
		  ,@agent
		  ,0
		  ,@from_location
		  ,@to_location
		  ,'R'

		-- error check
		Set @errorCheck = @@error
		if (@errorCheck <> 0 or @RC <> 0)
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end
		
		END

	

------ (4) Remote Collect
	if @TicketDistributionType = 'REMOTE COLLECT'
		BEGIN

			set @TicketQueue = 'R'

			EXECUTE @RC = [dbo].[cp_Queue_Add_Remote_Collect] 
			   @sale_id
			  ,@ticket
			  ,@RemoteCollectLocation
			  ,@departure_date_time
			  ,'R'

			-- error check
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end

		END

------ (5) Onboard Ticketing 
		if @TicketDistributionType ='Onboard Ticketing'
			BEGIN
				set @TicketQueue = 'O'
			END

------  (6) Third Party API - Post Office
		if @TicketDistributionType ='Credit Type'
			BEGIN
				----print 'Third Party API'
				set @TicketQueue = 'T'
			END

---------(8) TravelShop /Kiosk
			if @TicketDistributionType ='Retail Site Outlet'
			BEGIN
				----print 'Third Party API'
				set @TicketQueue = 'R'
			END

--print '@TicketQueue'
--print @TicketQueue
---- Add Sales Item Transaction

EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
   @sale_id
  ,8

-- error check
Set @errorCheck = @@error
if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end


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
				WHEN 'Senior' then 'CF'
				when 'Disabled' then 'CF'
				when 'BritXplorer' then 'BX'
			else 
				'AD'
			end
		    ,0

	FROM OPENXML (@docHandle, 'Ticket/Coachcards/Coachcard')
	WITH (
			type			varchar(50) '@type'
			,serialnumber	varchar(50) '@serialnumber'
		 )

	-- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end
		


---- Add Summary Records
-- (1) Basket summary
       declare @highestFarePaid int
       set @highestFarePaid = @Farevalue * 100


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
			 ,'R'
             ,0
             ,@highestFarePaid
             ,0--@highestFarePaid
             ,0

	 -- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end

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
        
		-- error check
		Set @errorCheck = @@error
		if @errorCheck <> 0
			begin
				EXEC sp_xml_removedocument @docHandle
				return @errorCheck
			end

--(3) Paying Consumer
			iF @LeadPaxSurname is NULL
				BEGIN
					INSERT INTO [dbo].[tbl_Basket_Paying_Consumer]
				   SELECT	
					@sale_id
				   ,(@PaymentValue *100)
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''
				   ,''   

					END


			ELSE
				BEGIN
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
						,@LeadPaxTelephone
						,''
						,@Emailaddress
				FROM OpenXML ( @docHandle, 'Ticket/LeadPassenger/Address')
					With ( 
							Address1	char(40)	'Address1'
							,Address2	char(40)	'Address2'
							,Address3	char(40)	'Address3'
							,Town		char(40)	'Town'
							,PostCode	char(8)		'PostCode'
							,County		char(40)	'County'
						) LPA

				END

				-- error checkm
				Set @errorCheck = @@error
				if @errorCheck <> 0
					begin
						EXEC sp_xml_removedocument @docHandle
						return @errorCheck
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
                    ,isnull(@insuranceValue,0)
                    ,0 )

			-- error check
			Set @errorCheck = @@error
			if @errorCheck <> 0
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end
             

-- (5) Add Passenger Summary Record
INSERT INTO [dbo].[tbl_Passenger_Summary]
           ([Ticket_Serial]
           ,[Sale_ID]
           ,[NoOfAdultPax]
           ,[NoOfChildPax]
           ,[NoOfConcessionaryPax]
           ,[NoOfNX2Pax]
           ,[NoOfYPPax]
           ,[NoOfAdv50Pax]
           ,[NoOfOtherDiscountPax]
           ,[NoOfGhostPax]
           ,[NoOfUnknownPax]
           ,[Over60])
     SELECT 
			@ticket
           ,@sale_id
           ,sum(case consumer_type_id 
				when 1 then 1
				else 0
				end)
           ,sum(case consumer_type_id 
				when 2 then 1
				else 0
				end )
           ,sum(case consumer_type_id 
				when 3 then 1
				else 0
				end) 
           ,sum(case consumer_type_id 
				when 4 then 1
				else 0
				end) 
           ,sum(case consumer_type_id 
				when 7 then 1
				else 0
				end)
           ,sum(case consumer_type_id 
				when 8 then 1
				else 0
				end)
           ,sum(case consumer_type_id 
				when 9 then 1
				else 0
				end)
           ,sum(case consumer_type_id 
				when 5 then 1
				else 0
				end)
           ,sum(case consumer_type_id 
				when 0 then 1
				else 0
				end)
           ,@Over60Count
	fROM @Pax

	-- error check
	Set @errorCheck = @@error
	if @errorCheck <> 0
		begin
			EXEC sp_xml_removedocument @docHandle
			return @errorCheck
		end
		
	--6. Discount details
--print @sale_id

declare @DiscountCode varchar(50)
declare @CampaignCode varchar(50)
declare @Value decimal(10,2)
declare @productSKU char(7)
declare @campaignID int 

	
	
	select 
			@DiscountCode = discountCode,
			@CampaignCode = campaignCode,
			@Value = (value / 100)
			FROM Openxml( @docHandle , 'Ticket/Discounts/Discount' ) 
	WITH ( 
			discountCode char(50) '@discountCode',
			campaignCode		char(50)	'@campaignCode',
			value			decimal(10,2)		'@value'
			
		   )
		   
		   if (@DiscountCode is not null and @CampaignCode is not null and @Value is not null) -- must have values on Discount
				 BEGIN
				 INSERT INTO dbo.tbl_Discounts_Applied
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
			END

						 --Close Basket
			EXECUTE @RC = [dbo] .[cp_Add_Sale_Transaction_V2]
			   @sale_id
			  ,10

			-- error check
			Set @errorCheck = @@error
			if (@errorCheck <> 0 or @RC <> 0)
				begin
					EXEC sp_xml_removedocument @docHandle
					return @errorCheck
				end
			--

------- 7. tbl_Consumers_Additional_Details  Insertion  =========================
--------------------- ESBS-673 by Urvashi Trivedi
 
	declare @AccessibilityRequirement INT
	 
	select  @AccessibilityRequirement = accessibilityRequirement
	FROM Openxml( @docHandle , 'Ticket' ) 
	WITH ( 
			accessibilityRequirement INT '@accessibilityRequirement' 
		   )

	IF (@AccessibilityRequirement IS NOT NULL and  @leadPaxID not in  (0,1,2,3,4,5,5445592,5445601,5445609)) -- ECR8635  added agent code as additional condition
	BEGIN

		INSERT INTO tbl_Consumers_Additional_Details
		(
			 accessibilityRequirement
			,Consumer_ID
		) 
		VALUES ( 
				 @accessibilityRequirement
				,@leadPaxID
			)
	END

-- error check
	Set @errorCheck = @@error
	if (@errorCheck <> 0 or @RC <> 0)
	begin
		EXEC sp_xml_removedocument @docHandle
		return @errorCheck
	end
-------============================================================================
 
EXEC sp_xml_removedocument @docHandle

set @saleid = @SALE_ID
set @TicketNo = @Ticket

return 0
END






GO


