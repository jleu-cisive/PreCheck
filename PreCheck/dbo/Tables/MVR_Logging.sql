CREATE TABLE [dbo].[MVR_Logging] (
    [APNO]        INT          NOT NULL,
    [BatchID]     INT          NOT NULL,
    [Request]     XML          NULL,
    [Response]    XML          NULL,
    [LastUpdated] DATETIME     NULL,
    [Created]     DATETIME     NULL,
    [CreatedBy]   VARCHAR (30) NULL,
    CONSTRAINT [PK_MVR_Logging] PRIMARY KEY CLUSTERED ([APNO] ASC, [BatchID] ASC)
);

