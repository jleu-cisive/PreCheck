CREATE TABLE [dbo].[MvrStateFees] (
    [MvrStateFeesId] INT            IDENTITY (1, 1) NOT NULL,
    [StateName]      VARCHAR (30)   NOT NULL,
    [StateCode]      VARCHAR (10)   NOT NULL,
    [Country]        VARCHAR (10)   NOT NULL,
    [PassThroughFee] SMALLMONEY     DEFAULT ((0)) NULL,
    [Isactive]       BIT            DEFAULT ((1)) NULL,
    [Comments]       VARCHAR (1000) NULL,
    [CreateDate]     DATETIME       DEFAULT (getdate()) NULL,
    [CreateBy]       INT            DEFAULT ((0)) NULL,
    [ModifyDate]     DATETIME       DEFAULT (getdate()) NULL,
    [ModifyBy]       INT            DEFAULT ((0)) NULL,
    [SectionId]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([MvrStateFeesId] ASC) ON [PRIMARY]
) ON [PRIMARY];

