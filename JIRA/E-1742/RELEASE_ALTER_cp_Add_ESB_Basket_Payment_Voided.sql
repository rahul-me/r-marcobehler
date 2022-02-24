USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_Add_ESB_Basket_Payment_Voided]    Script Date: 10/31/2021 9:54:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- Modified by    : Rahul Chauhan
-- Modified date  : 31/10/2021   
-- Description    : To record void payment
-- ===========================================================

-- Sample: -- EXEC cp_Add_ESB_Basket_Payment_Voided '<Ticket ticketNumber="E5JE7142" agentCode="NXDSK" agentUser="webDTU" salesChannel="Web"><Payment payment_value="0" payment_type="CARD" payment_provider="Barclays" payment_provider_transaction_id="8616356807484320A"/></Ticket>'

ALTER procedure [dbo].[cp_Add_ESB_Basket_Payment_Voided]

@TicketXML ntext

AS

DECLARE @docHandle int

EXEC sp_xml_preparedocument @docHandle OUTPUT, @TicketXML

-- Internal Variables
declare @agent char(5)
declare @user char(8)
declare @agent_user_id int
declare @sale_id int
declare @RC int
declare @ticket char(8)
declare @channel char(15)
declare @ticket_id int


-- retrieve agent user ID
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


-- get last sale ID
select @Sale_ID= max( sale_id)
from
      dbo .tbl_Sales_Items SI
       join dbo. tbl_Item_Serial_Link ISL
             on ISL. item_serial_id = si .item_serial_id
       join dbo. tbl_Tickets T
             on T. ticket_id = ISL .ticket_id
                   and ticket_serial = @ticket

-- Extract from XML

declare @PaymentValue money
declare @PaymentType char(20)
declare @PaymentProviderReference char(40)
declare @Payment_Provider_Record_id int
declare @payment_type_id int
declare @Payment_Provider_id int
declare @card_type_id int
declare @payment_provider char(20)

DECLARE @tId uniqueidentifier
SET @tId = newid()

set @card_type_id = 0

-- Get payment provider from XML
select @payment_provider = payment_provider
FROM OPENXML ( @docHandle,'Ticket/Payment')
WITH
		(
			payment_provider char(20) '@payment_provider'
		)

Select 
	@Payment_Provider_id = id
from
	NXLookUp.dbo.tbl_Payment_Providers
where
	description	 = 'Barclaycard'
	
	
IF(UPPER(@payment_provider) = 'ADYEN')
	BEGIN
		SELECT @Payment_Provider_id = id
		FROM NXLookUp.dbo.tbl_Payment_Providers
		WHERE UPPER(name) = 'ADYEN';

		SELECT @PaymentProviderReference = payment_provider_transaction_id
		FROM OPENXML ( @docHandle,'Ticket/Payment')
		WITH
		(
			payment_provider_transaction_id char(40) '@payment_provider_transaction_id'
		)
	END
ELSE
	BEGIN
		SELECT @PaymentProviderReference = payment_provider_transaction_id
		FROM OPENXML ( @docHandle,'Ticket/Payment/CardPayment')
		WITH
		(
			payment_provider_transaction_id char(40) '@payment_provider_transaction_id'
		)
	END
	
-- If @PaymentProviderReference is null or empty assign payment provider transaction id from Ticket/Payment
IF (ISNULL(@PaymentProviderReference, '') = '')
	BEGIN
		SELECT @PaymentProviderReference = payment_provider_transaction_id
		FROM OPENXML ( @docHandle,'Ticket/Payment')
		WITH
		(
			payment_provider_transaction_id char(40) '@payment_provider_transaction_id'
		)
	END		
	
select  @PaymentValue = cast(payment_value as money)/100
		,@PaymentType = payment_type
from OPENXML ( @docHandle,'Ticket/Payment')
With (
		payment_value int '@payment_value'
		,payment_type char(20) '@payment_type'
	  )

select @payment_type_id = payment_type_id  from dbo.tbl_Payment_Types where payment_type = @PaymentType

-- insrt record for void transaction

-- CODE FOR ADDITING payment Transaction 

exec cp_insert_payment_provider_transaction_v3 @Payment_Provider_id,@tId,@PaymentProviderReference,@card_type_id,0,'','','',@ticket,@Payment_Provider_Record_id OUT
-- print 'OUT'
-- print @Payment_Provider_Record_id
		
-- update existing record with Sale_id
	update dbo.tbl_Payment_Provider_Transactions
	set sale_id = @Sale_id
	where id = @Payment_Provider_Record_id
						
-- mark previous instance of payment as voided. 

update dbo.tbl_Payment_Provider_Transactions
set void = 1
where id = @Payment_Provider_Record_id;
	
				




	

EXEC sp_xml_removedocument @docHandle

return 0


GO

