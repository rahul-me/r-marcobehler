USE [Titan]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_Phone_Contacts](
	[phone_contacts_id] [int] IDENTITY(0,1) NOT FOR REPLICATION NOT NULL,
	[consumer_id] [int] NOT NULL,
	[number] [varchar](15) NOT NULL,
	[number_type] [char](1) NOT NULL,
	[marketing_consent] [bit] NOT NULL CONSTRAINT [DF_tbl_Phone_Contacts_marketing_consent]  DEFAULT (0),
	[preferred] [bit] NOT NULL,
	[active] [bit] NOT NULL CONSTRAINT [DF_tbl_Phone_Contacts_active]  DEFAULT (1),
	[msrepl_tran_version] [uniqueidentifier] NOT NULL CONSTRAINT [DF__tbl_Phone__msrep__1D7E8D81]  DEFAULT (newid()),
	[DeleteFlag] [char](1) NULL,
	[PhoneTypeID] [bigint] NULL,
 CONSTRAINT [PK_tbl_Phone_Contacts_temp2] PRIMARY KEY CLUSTERED 
(
	[phone_contacts_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [IndexData]
) ON [IndexData]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Phone_Contacts_tbl_Consumers] FOREIGN KEY([consumer_id])
REFERENCES [dbo].[tbl_Consumers] ([consumer_id])
GO

ALTER TABLE [dbo].[tbl_Phone_Contacts] CHECK CONSTRAINT [FK_tbl_Phone_Contacts_tbl_Consumers]
GO

