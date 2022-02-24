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
CONSTRAINT [PK_tbl_Phone_Contacts_temp2] PRIMARY KEY CLUSTERED
(
	[contacts_country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [IndexData]
) ON [IndexData]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts_Country_Code]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Phone_Contacts_Country_Code_tbl_Phone_Contacts] FOREIGN KEY([phone_contacts_id])
REFERENCES [dbo].[tbl_Phone_Contacts] ([phone_contacts_id])
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts_Country_Code] CHECK CONSTRAINT [FK_tbl_Phone_Contacts_Country_Code_tbl_Phone_Contacts]
GO