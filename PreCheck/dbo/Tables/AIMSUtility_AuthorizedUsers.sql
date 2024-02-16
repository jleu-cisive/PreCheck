CREATE TABLE [dbo].[AIMSUtility_AuthorizedUsers] (
    [AuthorizedUsersId] INT            IDENTITY (1, 1) NOT NULL,
    [AuthorizedUserId]  VARCHAR (1000) NULL,
    [IsActive]          BIT            DEFAULT ((1)) NULL
);

