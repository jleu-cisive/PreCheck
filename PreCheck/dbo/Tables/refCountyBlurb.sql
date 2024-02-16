CREATE TABLE [dbo].[refCountyBlurb] (
    [refCountyBlurbID]            INT            IDENTITY (1, 1) NOT NULL,
    [CNTY_NO]                     INT            NULL,
    [CountyState]                 CHAR (2)       NULL,
    [CountyBlurb]                 VARCHAR (5000) NOT NULL,
    [ExcludeStateWide]            BIT            CONSTRAINT [DF_refCountyBlurb_ExcludeStateWide] DEFAULT ((0)) NOT NULL,
    [RefCountyTypeID]             INT            NULL,
    [IsBusinessContinuityRelated] BIT            CONSTRAINT [DF_refCountyBlurb_IsBusinessContinuityRelated] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_refCountyBlurb] PRIMARY KEY CLUSTERED ([refCountyBlurbID] ASC) WITH (FILLFACTOR = 50)
);

