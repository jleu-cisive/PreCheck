CREATE TABLE [dbo].[temp3] (
    [Apno]               INT            NOT NULL,
    [ApStatus]           CHAR (1)       NOT NULL,
    [UserID]             VARCHAR (8)    NULL,
    [Investigator]       VARCHAR (8)    NULL,
    [ApDate]             DATETIME       NULL,
    [Last]               VARCHAR (20)   NOT NULL,
    [First]              VARCHAR (20)   NOT NULL,
    [Middle]             VARCHAR (20)   NULL,
    [reopendate]         DATETIME       NULL,
    [Client_Name]        VARCHAR (100)  NULL,
    [Affiliate]          NVARCHAR (50)  NULL,
    [Elapsed]            NUMERIC (7, 2) NULL,
    [InProgressReviewed] VARCHAR (5)    NOT NULL,
    [Crim_Count]         INT            NULL
);

