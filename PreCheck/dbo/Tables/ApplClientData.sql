CREATE TABLE [dbo].[ApplClientData] (
    [ApplClientDataID]     INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NULL,
    [CLNO]                 INT          NULL,
    [ClientAPNO]           VARCHAR (50) NULL,
    [XMLD]                 XML          NULL,
    [Updated]              DATETIME     NULL,
    [LastSyncUTC]          DATETIME     NULL,
    [DateAcknowledged]     DATETIME     NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_ApplClientData_CreatedDate] DEFAULT (getdate()) NULL,
    [OCHS_CandidateInfoID] INT          NULL,
    CONSTRAINT [PK_ApplClientData] PRIMARY KEY CLUSTERED ([ApplClientDataID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [ApplClientData_APNO]
    ON [dbo].[ApplClientData]([APNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [CLNO_ClientAPNO]
    ON [dbo].[ApplClientData]([CLNO] ASC, [ClientAPNO] ASC) WITH (FILLFACTOR = 100);


GO
-- =============================================
-- Author:		Santosh Chapyala
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[ApplClientData_ProcessCallback_update] on [dbo].[ApplClientData]
FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--resend acknowledgement when the clientdata is updated after initial acknowledgement and report completion is not sent
IF update(	XMLD)  
	 UPDATE IOR SET  IOR.DateAcknowledged = null 
	 FROM dbo.ApplClientData IOR INNER JOIN INSERTED I 
	 ON IOR.apno = I.apno INNER JOIN DELETED D
	 ON I.APNO = D.APNO
	 WHERE 	cast(I.XMLD as varchar(1000)) <> cast(D.XMLD as varchar(1000)) AND I.DateAcknowledged is not null and I.LastSyncUTC is Null 

END