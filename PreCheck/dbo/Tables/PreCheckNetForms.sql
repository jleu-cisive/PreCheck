CREATE TABLE [dbo].[PreCheckNetForms] (
    [FormID]     INT           IDENTITY (1, 1) NOT NULL,
    [NameOnWeb]  VARCHAR (200) NULL,
    [UsedFor]    VARCHAR (50)  NULL,
    [NameOfFile] VARCHAR (200) NULL
) ON [PRIMARY];

