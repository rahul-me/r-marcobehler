USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_ReIssue_Ticket_Retail]    Script Date: 1/13/2022 9:23:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* ===============================================================
-- Author		:	Urvashi Parmar
-- Create date	:	23-06-2020
-- Description	: SMAREP -1421 Created new stored procedure to requeue ticket in respective queue table
==================================================================
-- Modified bt : Kinnal Parmar
-- Modified Date : 26-06-2020
-- Description  : added 

validation for Agent code available in master table or not SMAREP-1420
*/

--declare @Message varchar(100)
--exec cp_ReIssue_Ticket_Retail 'P2A03972','D085',@message output
--select @Message

ALTER PROCEDURE [dbo].[cp_ReIssue_Ticket_Retail] 

 @ticket_number char(8)

,@agent_code char(5)

,@Message varchar(100) OUTPUT	

AS
Begin
	  DECLARE @ticket_id INT 
	  DECLARE @sale_Id INT   
	  DECLARE @distribution_type_Id INT
	  DECLARE @consumer_Id INT
	  DECLARE @sale_item_id INT
	  
	  BEGIN TRAN

      SELECT TOP 1 @ticket_id = T.[ticket_id] 
      FROM   [dbo].[tbl_tickets] T 
      WHERE  ticket_serial = @ticket_number 
	  

	  SET @sale_Id = 0
	  SELECT top 1 @sale_Id= b.sale_id 
	  FROM   [dbo].[tbl_item_serial_link] AS ISL 
             INNER JOIN dbo.[tbl_sales_items] AS BI 
                     ON BI.item_serial_id = ISL.item_serial_id 
                        AND ISL.[ticket_id] = @ticket_id 
						INNER JOIN dbo.tbl_sales AS B 
                     ON B.sale_id = BI.sale_id 
					 order by B.sale_id DESC

	 If @sale_Id  = 0 
	  BEGIN
		SET @Message = 'Ticket Number does not exist'

		RAISERROR('Ticket Number does not exist',10,1)

		GOTO ErrorDetetcted
	  END


	  DECLARE @Count INT

	  SELECT @Count = Count(*) FROM dbo.tbl_Sales_Items WHERE sale_item_type_id in(4,5) AND sale_id in (Select sale_id from dbo.tbl_Basket_Summary where TicketNo = @ticket_number)

			IF (@Count > 0)

			BEGIN

				SET @Message = 'This Ticket is not active'

				RAISERROR('This Ticket is not active',10,1)

				GOTO ErrorDetetcted

			END	

      DECLARE @agentCode char(8)

      SELECT @agentCode =  agent_code FROM tbl_Agents WHERE agent_code = @agent_code ORDER BY agent_id DESC

		IF (@agentCode = '' or @agentCode is NULL)

			BEGIN

				SET @Message = 'Agent Code does not exist'

				RAISERROR('Agent Code does not exist',10,1)

				GOTO ErrorDetetcted

			END 

	  SELECT @distribution_type_Id= distribution_type_id             
      FROM   dbo.tbl_ticket_distribution where sale_id  = @sale_Id

	  SELECT @sale_item_id = sales_item_id FROM tbl_Sales_Items where sale_id= @sale_Id and product_id = 1

	  SELECT @consumer_Id = consumer_id from tbl_Consumers where 
	  Sale_id = @sale_Id and Consumer_Role_id=6 AND consumer_id NOT IN ( 0, 1, 2, 3,4, 5, 5445592, 5445601, 5445609 ) 


	  if(@distribution_type_Id=3) -- M-Ticket
		  begin
		
		  DECLARE @phone VARCHAR(15)
		  SELECT @phone = number from dbo.tbl_phone_contacts where consumer_id = @consumer_Id
		  DELETE FROM tbl_Ticket_Queue_M_Tickets where Sale_ID = @sale_Id

		  EXEC cp_Queue_Add_M_Ticket @sale_id = @sale_Id, @ticket_number= @ticket_number, @telephone_number = @phone , @transaction_type = ''
		  if @@error <> 0
		  begin
			
			SET @Message = 'Failed to add ticket to M-Ticket Queue'
			RAISERROR('Failed to add ticket to M-Ticket Queue',11,1)
			GOTO ErrorDetetcted
		  end
	  end

	  If(@distribution_type_Id=1) -- Local post out
		  BEGIN
		  DECLARE @TotalAdditionalProduct int
		  Declare @fromLocation char(5)
		  Declare @toLocation char(5)
		   Declare @isAdditionProduct char(5)
	  
		  SELECT @TotalAdditionalProduct  = COUNT(1) from tbl_Sales_Items where sale_id = @sale_Id and product_id <> 1 
		  if @TotalAdditionalProduct > 0 
			set @isAdditionProduct = 1
		  else 
			set @isAdditionProduct = 0
	  
		select @fromLocation = from_location_code from tbl_SmartJourneyLegs where sales_item_id=@sale_item_id and leg_number = 0
		select top 1 @toLocation = to_location_code from tbl_SmartJourneyLegs where sales_item_id=@sale_item_id and leg_direction = 'O' order by leg_number DESC

		DELETE FROM tbl_Ticket_Queue_Local_Postout where Sale_ID = @sale_Id

		EXEC cp_Queue_Add_Post_Out @sale_id= @sale_Id, @ticket_number = @ticket_number, @agent_code = @agent_code , @additional_products = @isAdditionProduct,
		@from_location= @fromLocation, @to_location = @toLocation, @transaction_type= ''

		 if @@error <> 0
		  begin		
		
			SET @Message = 'Failed to add ticket to Local post out Queue'
			RAISERROR('Failed to add ticket to  Local post out Queue',11,1)
			GOTO ErrorDetetcted
		  end

	  END

	   If(@distribution_type_Id=7) -- Remote Collect
	   BEGIN
	   declare @departure_date_time datetime 		
	  
		select @departure_date_time =dateadd(s,  L.departure_date + (L.departure_time * 60), '01-Jan-1970 00:00:00' ) from tbl_SmartJourneyLegs L JOIN tbl_Sales_Items SI on  L.sales_item_id = SI.sales_item_id
	    and SI.sale_id = @sale_Id and L.leg_number = 0
		

		DELETE FROM tbl_Ticket_Queue_Remote_Collect where Sale_ID = @sale_Id

		EXEC cp_Queue_Add_Remote_Collect @sale_id= @sale_Id, @ticket_number = @ticket_number, @collection_location = '', @departure_date_time =@departure_date_time, @transaction_type = ''
		 if @@error <> 0
		  begin			
			SET @Message = 'Failed to add ticket to remote collect Queue'
			RAISERROR('Failed to add ticket to remote collect Queue',11,1)
			GOTO ErrorDetetcted
		  end

	  END

	  EXEC cp_Add_Sale_Transaction_v2 @sale_id = @sale_Id, @transaction_type = 8   
	  GOTO NoError
	  
ErrorDetetcted:

		ROLLBACK TRAN
		GOTO Ending

NoError:	

		COMMIT TRAN

		SET @Message = ''
		
		GOTO Ending
Ending:  	  
	  
End

GO

