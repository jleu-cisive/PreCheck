CREATE TABLE [dbo].[AppLockEscalation] (
    [APNO]      INT          NOT NULL,
    [UserID]    VARCHAR (50) NOT NULL,
    [LockLevel] INT          CONSTRAINT [DF_AppLockEscalation_LockLevel] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AppLockEscalation] PRIMARY KEY CLUSTERED ([APNO] ASC) WITH (FILLFACTOR = 50)
);

