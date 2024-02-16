CREATE TABLE [dbo].[Partner_FromProd10242022] (
    [PartnerId]          INT           NOT NULL,
    [PartnerName]        VARCHAR (100) NOT NULL,
    [PartnerDescription] VARCHAR (200) NULL,
    [IsActive]           BIT           NOT NULL,
    [CreateDate]         DATETIME      NOT NULL,
    [CreateBy]           INT           NOT NULL,
    [ModifyDate]         DATETIME      NOT NULL,
    [ModifyBy]           INT           NOT NULL,
    [PartnerGroupingId]  INT           NULL
);

