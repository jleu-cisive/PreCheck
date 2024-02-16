CREATE TABLE [dbo].[ClientGroup] (
    [CLNO]       INT           NOT NULL,
    [GroupCode]  INT           NOT NULL,
    [IsActive]   BIT           DEFAULT ((0)) NOT NULL,
    [CreateBy]   VARCHAR (100) DEFAULT ('sa') NOT NULL,
    [CreateDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifyBy]   VARCHAR (100) DEFAULT ('sa') NOT NULL,
    [ModifyDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ClientGroup] PRIMARY KEY CLUSTERED ([CLNO] ASC, [GroupCode] ASC) WITH (FILLFACTOR = 50)
);

