-- ==================================================================================================================
-- Author		:	Rahul Chauhan
-- Create date	:	28 July 2021
-- Description	:	Created new table to store country code for consumer contacts as existing table tbl_Phone_Contacts will have problem in replication
-- ==================================================================================================================

USE [Titan]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_Phone_Contacts_Country_Code](
	[contacts_country_id] [int] IDENTITY(0,1) NOT NULL,
	[phone_contacts_id] [int] NOT NULL,
	[country_code] varchar(5) NOT NULL,
 CONSTRAINT [PK_tbl_Phone_Contacts_Country_Code] PRIMARY KEY CLUSTERED ( [contacts_country_id] ASC )
)ON [IndexData]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts_Country_Code]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Phone_Contacts_Country_Code_tbl_Phone_Contacts] FOREIGN KEY([phone_contacts_id])
REFERENCES [dbo].[tbl_Phone_Contacts] ([phone_contacts_id])
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts_Country_Code] CHECK CONSTRAINT [FK_tbl_Phone_Contacts_Country_Code_tbl_Phone_Contacts]
GO

