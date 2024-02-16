CREATE TABLE [Velocity].[ClaimedCredentialsLog] (
    [ClaimedCredentialsLogID] INT            IDENTITY (1, 1) NOT NULL,
    [APNO]                    INT            NOT NULL,
    [SectionID]               INT            NOT NULL,
    [SectionKeyID]            INT            NOT NULL,
    [VelocityWalletID]        INT            NULL,
    [IsIssued]                BIT            DEFAULT ((0)) NOT NULL,
    [CreateBy]                INT            NOT NULL,
    [CreateDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              INT            NOT NULL,
    [ModifyDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [BuOfferKeys]             NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([ClaimedCredentialsLogID] ASC)
);

