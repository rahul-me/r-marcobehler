USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_Queue_Add_M_Ticket]    Script Date: 7/28/2021 11:25:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[cp_Queue_Add_M_Ticket]
	
@sale_id int,
@ticket_number char (8),
@telephone_number varchar (15),
@transaction_type char (1)

AS

IF not @transaction_type = 'A'
BEGIN
	INSERT INTO [dbo].[tbl_Ticket_Queue_M_Tickets]
			   ([Sale_ID]
			   ,[TicketNo]
			   ,[TelephoneNo])
		 VALUES
			   (@sale_id
			   ,@ticket_number
			   ,@telephone_number)
END

GO

