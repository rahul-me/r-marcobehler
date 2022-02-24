USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_insert_payment_provider_transaction_v3]    Script Date: 10/31/2021 11:21:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[cp_insert_payment_provider_transaction_v3]   
 @payment_provider_id int,  
 @providers_payment_reference uniqueidentifier = null,  
 @unique_transaction_reference varchar(40),  
 @card_type_id int,  
 @is_refund bit,  
 @security_key varchar(50)=null,  
 @providers_authorisation_code varchar(15)=null,  
 @last_four_digits_of_card_number varchar(4)=null,  
 @transaction_label varchar(200)=null,  
 @payment_provider_transaction_id int OUTPUT  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  



		DECLARE @tNotification_id int
		DECLARE	@tcard_number varchar(20)
		DECLARE @tproviders_authorisation_code varchar(15)
		

-- FETCHING ALL THE DATA FOR LATEST CARD DETAIL ID
	   SELECT  @tNotification_id = coalesce(id,0),
			   @tcard_number =   last_four_digit_of_card_number,
			   @tproviders_authorisation_code = providers_authorisation_code
	   FROM    dbo.tbl_Temp_Notification
	   WHERE   unique_transaction_reference = Rtrim(@unique_transaction_reference)

-- Now update card detail need to be enter if notification is already arived

	if(@tNotification_id >0)
	begin
	  set @last_four_digits_of_card_number = @tcard_number
	  set @providers_authorisation_code  = @tproviders_authorisation_code
	end

-- In case of Barclays payment gateway Provider_payment_refrence will be null


if(@providers_payment_reference is null)
  set @providers_payment_reference = newid()
   
 INSERT INTO [dbo].[tbl_Payment_Provider_Transactions]  
           ([payment_provider_id]  
   ,[providers_payment_reference]  
   ,[unique_transaction_reference]  
   ,[card_type_id]  
   ,[is_refund]  
   ,[security_key]  
   ,[providers_authorisation_code]  
   ,[last_four_digits_of_card_number]  
   ,[transaction_label]  
   ,[date_created])  
     VALUES  
   (@payment_provider_id  
   ,@providers_payment_reference  
   ,@unique_transaction_reference  
   ,@card_type_id  
   ,@is_refund  
   ,@security_key  
   ,@providers_authorisation_code  
   ,@last_four_digits_of_card_number  
   ,@transaction_label  
   ,getdate())  
  SET @payment_provider_transaction_id = SCOPE_IDENTITY()  
END

GO


