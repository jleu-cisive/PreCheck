CREATE TABLE [dbo].[MedicareSanc] (
    [MedicareSancID] INT          IDENTITY (19284, 1) NOT NULL,
    [LastSoundex]    CHAR (4)     NULL,
    [LastName]       VARCHAR (20) NULL,
    [FirstName]      VARCHAR (15) NULL,
    [MidName]        VARCHAR (15) NULL,
    [BusName]        VARCHAR (30) NULL,
    [General]        VARCHAR (20) NULL,
    [Specialty]      VARCHAR (20) NULL,
    [UPIN]           VARCHAR (6)  NULL,
    [DOB]            DATETIME     NULL,
    [Address]        VARCHAR (30) NULL,
    [City]           VARCHAR (20) NULL,
    [State]          VARCHAR (2)  NULL,
    [Zip]            VARCHAR (5)  NULL,
    [SancType]       VARCHAR (9)  NULL,
    [SancDate]       DATETIME     NULL,
    [ReinDate]       DATETIME     NULL,
    [Agency]         VARCHAR (30) NULL,
    CONSTRAINT [PK_MedicareSanc] PRIMARY KEY NONCLUSTERED ([MedicareSancID] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA]
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_MedicareSanc_Name]
    ON [dbo].[MedicareSanc]([LastName] ASC, [FirstName] ASC, [MidName] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_MedicareSanc_Soundex]
    ON [dbo].[MedicareSanc]([LastSoundex] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

