USE [Titan]
GO

/****** Object:  Table [dbo].[tbl_Consumers]    Script Date: 7/28/2021 7:58:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_Consumers](
	[consumer_id] [int] IDENTITY(0,1) NOT NULL,
	[consumer_type_id] [int] NOT NULL,
	[title_id] [int] NOT NULL,
	[forename] [varchar](40) NOT NULL,
	[surname] [varchar](40) NOT NULL,
	[suffix] [int] NOT NULL CONSTRAINT [DF_tbl_Consumers_suffix]  DEFAULT (0),
	[coachcard_id] [int] NOT NULL,
	[age_range_id] [int] NOT NULL,
	[date_created] [datetime] NOT NULL,
	[related_consumer_id] [int] NOT NULL CONSTRAINT [DF_tbl_Consumers_related_consumer_id]  DEFAULT (0),
	[relation_type_id] [int] NOT NULL CONSTRAINT [DF_tbl_Consumers_relation_type_id]  DEFAULT (0),
	[initials] [char](5) NOT NULL CONSTRAINT [DF_tbl_Consumers_initials]  DEFAULT (''),
	[msrepl_tran_version] [uniqueidentifier] NOT NULL CONSTRAINT [DF__tbl_Consu__msrep__61BEA935]  DEFAULT (newid()),
	[GUID] [uniqueidentifier] NULL,
	[DeleteFlag] [char](1) NULL,
	[Consumer_Role_id] [int] NULL,
	[Sale_id] [int] NULL,
	[gender] [varchar](10) NULL,
	[dateOfBirth] [varchar](10) NULL,
 CONSTRAINT [PK__tbl_Passengers__ggutvuut2] PRIMARY KEY CLUSTERED 
(
	[consumer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [IndexData]
) ON [IndexData]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tbl_Consumers]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Consumers_tbl_Age_Ranges] FOREIGN KEY([age_range_id])
REFERENCES [dbo].[tbl_Age_Ranges] ([age_range_id])
GO

ALTER TABLE [dbo].[tbl_Consumers] CHECK CONSTRAINT [FK_tbl_Consumers_tbl_Age_Ranges]
GO

ALTER TABLE [dbo].[tbl_Consumers]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Consumers_tbl_Consumer_Types] FOREIGN KEY([consumer_type_id])
REFERENCES [dbo].[tbl_Consumer_Types] ([consumer_type_id])
GO

ALTER TABLE [dbo].[tbl_Consumers] CHECK CONSTRAINT [FK_tbl_Consumers_tbl_Consumer_Types]
GO

ALTER TABLE [dbo].[tbl_Consumers]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Consumers_tbl_Consumers] FOREIGN KEY([related_consumer_id])
REFERENCES [dbo].[tbl_Consumers] ([consumer_id])
GO

ALTER TABLE [dbo].[tbl_Consumers] CHECK CONSTRAINT [FK_tbl_Consumers_tbl_Consumers]
GO

ALTER TABLE [dbo].[tbl_Consumers]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Consumers_tbl_Titles] FOREIGN KEY([title_id])
REFERENCES [dbo].[tbl_Titles] ([title_id])
GO

ALTER TABLE [dbo].[tbl_Consumers] CHECK CONSTRAINT [FK_tbl_Consumers_tbl_Titles]
GO

