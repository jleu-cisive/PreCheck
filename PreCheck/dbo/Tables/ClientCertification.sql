CREATE TABLE [dbo].[ClientCertification] (
    [ClientCertificationId] INT           IDENTITY (1, 1) NOT NULL,
    [APNO]                  INT           NULL,
    [ClientCertReceived]    VARCHAR (5)   NULL,
    [ClientCertBy]          VARCHAR (500) NULL,
    [ClientCertUpdated]     DATETIME      NULL,
    [ClientICertByPAddress] VARCHAR (50)  NULL,
    [IsInLieuOnlineRelease] BIT           NULL,
    CONSTRAINT [PK_ClientCertification] PRIMARY KEY CLUSTERED ([ClientCertificationId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_APNO_ClientCertReceived]
    ON [dbo].[ClientCertification]([APNO] ASC)
    INCLUDE([ClientCertReceived], [ClientCertBy]);

