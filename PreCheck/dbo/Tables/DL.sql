CREATE TABLE [dbo].[DL] (
    [APNO]                     INT           NOT NULL,
    [Ordered]                  VARCHAR (14)  NULL,
    [SectStat]                 CHAR (1)      CONSTRAINT [DF_DL_SectStat] DEFAULT ('0') NOT NULL,
    [Report]                   VARCHAR (MAX) NULL,
    [Web_status]               INT           NULL,
    [Time_in]                  DATETIME      CONSTRAINT [DF_DL_Time_int] DEFAULT (getdate()) NULL,
    [Last_Updated]             DATETIME      CONSTRAINT [DF_DL_LastUpdated] DEFAULT (getdate()) NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      CONSTRAINT [DF_DL_CreatedDate] DEFAULT (getdate()) NULL,
    [IsHidden]                 BIT           DEFAULT ((0)) NOT NULL,
    [IsCAMReview]              BIT           DEFAULT ((0)) NOT NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [Notes]                    VARCHAR (MAX) NULL,
    [IsReleaseNeeded]          BIT           CONSTRAINT [DF_DL_IsReleaseNeeded] DEFAULT ((0)) NOT NULL,
    [AttemptCounter]           INT           NULL,
    [DateOrdered]              DATETIME      NULL,
    [MVRLoggingId]             INT           NULL,
    CONSTRAINT [PK_DL] PRIMARY KEY CLUSTERED ([APNO] ASC) ON [PS1_DL] ([APNO]),
    CONSTRAINT [FK_DL_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
) ON [PS1_DL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_SectStat]
    ON [dbo].[DL]([SectStat] ASC, [APNO] ASC) WITH (FILLFACTOR = 75)
    ON [PS1_DL] ([APNO]);


GO
CREATE NONCLUSTERED INDEX [IX_DL_ApNo]
    ON [dbo].[DL]([APNO] ASC)
    INCLUDE([SectStat], [Last_Updated])
    ON [PS1_DL] ([APNO]);


GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Modified Date: 04/07/2014.
--Modified By: Schapyala
--Changes: Simplified the query and moved the activity log into a seperate trigger
-- =============================================
CREATE TRIGGER [dbo].[dl_status_update] on [dbo].[DL]
for update

AS 
BEGIN


if update(sectstat) 
	BEGIN

		--update null ordered dates when completed, simulates old bis2 functionality
		update d
		set ordered = Case When (isnull(d.ordered,'') = '' and del.sectstat = '9') then Convert(VARCHAR(14),Current_timestamp,1)  + ' ' + Convert(VARCHAR(5),Current_timestamp,108) else d.ordered end,
		Last_updated = Current_Timestamp
		from dl d inner join inserted i on d.apno = i.apno
		inner join deleted del on i.apno = del.apno
		where isnull(i.sectstat,'') <> isnull(del.sectstat,'')


	END

	if update(Report)
		update  d set Last_updated = Current_Timestamp
		FROM dbo.dl d inner join inserted i on d.apno = i.apno
		inner join deleted del on i.apno = del.apno
		where isnull(i.Report,'') <> isnull(del.Report,'')
END

GO
/*
Author: schapyala
Created: 04/07/14
Purpose: To insert into activity log. Moved this from the main trigger to itself
*/
CREATE TRIGGER  [dbo].[dl_status_update_ActivityLog] on [dbo].[DL]
for update
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
if update(sectstat) 
		insert dbo.dlactivitylog(status,apno,username)
		select i.sectstat,i.apno,a.inuse
		from inserted i inner join dbo.appl a on i.apno=a.apno
		inner join deleted d on i.apno = d.apno
		where isnull(i.sectstat,'') <> isnull(d.sectstat,'')
END
