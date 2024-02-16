CREATE TABLE [dbo].[SearchAppl] (
    [APNO]     INT          NOT NULL,
    [Last]     VARCHAR (20) NOT NULL,
    [First]    VARCHAR (20) NOT NULL,
    [Middle]   VARCHAR (20) NULL,
    [SSN]      VARCHAR (11) NULL,
    [ApDate]   DATETIME     NULL,
    [ApStatus] CHAR (1)     NOT NULL
) ON [PRIMARY];

