USE [Titan]
GO

/****** Object:  Table [dbo].[tbl_Tickets]    Script Date: 7/28/2021 7:55:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_Tickets_2](
	[ticket_id] [int] IDENTITY(0,1) NOT FOR REPLICATION NOT NULL,
	[ticket_serial] [char](8) NOT NULL,
	[date_created] [datetime] NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL CONSTRAINT [DF__tbl_Ticke__msrep__7E1AF0C1]  DEFAULT (newid()),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL DEFAULT (newid()),
 CONSTRAINT [PK_tbl_Tickets_temp2] PRIMARY KEY CLUSTERED 
(
	[ticket_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [IndexData]
) ON [IndexData]

GO

SET ANSI_PADDING OFF
GO

