CREATE TABLE [dbo].[InvDetailsParallel] (
    [ID]             INT            IDENTITY (1000, 1) NOT NULL,
    [APNO]           INT            NOT NULL,
    [CLNO]           INT            NOT NULL,
    [ServiceType]    INT            NOT NULL,
    [SubKey]         INT            NULL,
    [SubKeyChar]     NVARCHAR (50)  NULL,
    [CreateDate]     DATETIME2 (7)  DEFAULT (getdate()) NOT NULL,
    [LastUpdateDate] DATETIME2 (7)  NULL,
    [FeeDescription] NVARCHAR (MAX) NOT NULL,
    [Amount]         SMALLMONEY     NOT NULL,
    [IsDeleted]      BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [APNO_Includes]
    ON [dbo].[InvDetailsParallel]([APNO] ASC)
    INCLUDE([Amount]) WITH (FILLFACTOR = 100);

