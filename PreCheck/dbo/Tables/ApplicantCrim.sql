CREATE TABLE [dbo].[ApplicantCrim] (
    [ApplicantCrimID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]            INT          NULL,
    [City]            VARCHAR (50) NULL,
    [State]           VARCHAR (50) NULL,
    [Country]         VARCHAR (50) NULL,
    [CrimDate]        VARCHAR (50) NULL,
    [Offense]         VARCHAR (50) NULL,
    [Source]          VARCHAR (20) NULL,
    [SSN]             VARCHAR (20) NULL,
    [CLNO]            INT          NULL,
    CONSTRAINT [PK_ApplicantCrim] PRIMARY KEY CLUSTERED ([ApplicantCrimID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [ApplicantCrim_Apno_City_State]
    ON [dbo].[ApplicantCrim]([APNO] ASC, [City] ASC, [State] ASC) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplicantCrim_APNO]
    ON [dbo].[ApplicantCrim]([APNO] ASC)
    INCLUDE([ApplicantCrimID], [City], [State], [Country], [CrimDate], [SSN]) WITH (FILLFACTOR = 70);

