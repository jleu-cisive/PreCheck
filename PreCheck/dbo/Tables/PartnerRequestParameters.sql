CREATE TABLE [dbo].[PartnerRequestParameters] (
    [RequestParameterId] INT           IDENTITY (1, 1) NOT NULL,
    [RequestPayload]     VARCHAR (MAX) NULL,
    [PartnerOperation]   VARCHAR (100) NULL,
    [CreateDate]         DATETIME      NULL,
    [ResponsePayload]    VARCHAR (MAX) NULL,
    [HttpResponseCode]   INT           NULL,
    [RequestId]          INT           DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PartnerRequestParameters] PRIMARY KEY CLUSTERED ([RequestParameterId] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

