CREATE TABLE [dbo].[OmniStatus] (
    [CrimID]      INT      NOT NULL,
    [ResultData]  XML      NOT NULL,
    [LastUpdated] DATETIME CONSTRAINT [DF_OmniStatus_LastUpdated] DEFAULT (getdate()) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

