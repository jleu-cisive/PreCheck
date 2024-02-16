CREATE TABLE [dbo].[EmplAudit] (
    [EmplAuditId]  INT            IDENTITY (1, 1) NOT NULL,
    [CLNO]         INT            NULL,
    [APNO]         INT            NULL,
    [Employer]     VARCHAR (30)   NULL,
    [FirstName]    VARCHAR (50)   NULL,
    [LastName]     VARCHAR (50)   NULL,
    [PrivateNotes] VARCHAR (4000) NULL,
    [PublicNotes]  VARCHAR (4000) NULL,
    [Webstatus]    INT            NULL,
    [CreateDate]   DATETIME       NULL,
    [CreateBy]     VARCHAR (20)   NULL,
    [ModifyDate]   DATETIME       NULL,
    [ModifyBy]     VARCHAR (20)   NULL,
    [EmplID]       INT            NULL,
    CONSTRAINT [PK_EmplAuditId] PRIMARY KEY CLUSTERED ([EmplAuditId] ASC) WITH (FILLFACTOR = 90)
);

