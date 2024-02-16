CREATE TABLE [dbo].[WeborderPrefs] (
    [WebOrderPrefsID]     INT           IDENTITY (1, 1) NOT NULL,
    [Clno]                INT           NOT NULL,
    [Fax]                 VARCHAR (20)  NULL,
    [callfax]             BIT           CONSTRAINT [DF_WeborderPrefs_callfax] DEFAULT (0) NOT NULL,
    [faxoremail]          VARCHAR (10)  NULL,
    [Email]               VARCHAR (100) NULL,
    [criminalbackground]  BIT           CONSTRAINT [DF_WeborderPrefs_criminalbackground] DEFAULT (0) NULL,
    [socialsecurity]      BIT           CONSTRAINT [DF_WeborderPrefs_socialsecurity] DEFAULT (0) NOT NULL,
    [medicaid]            BIT           CONSTRAINT [DF_WeborderPrefs_medicaid] DEFAULT (0) NOT NULL,
    [motorvehicle]        BIT           CONSTRAINT [DF_WeborderPrefs_motorvehicle] DEFAULT (0) NOT NULL,
    [personalreferences]  BIT           CONSTRAINT [DF_WeborderPrefs_personalreferences] DEFAULT (0) NOT NULL,
    [licenseverification] BIT           CONSTRAINT [DF_WeborderPrefs_licenseverification] DEFAULT (0) NOT NULL,
    [education]           BIT           CONSTRAINT [DF_WeborderPrefs_education] DEFAULT (0) NOT NULL,
    [employment]          BIT           CONSTRAINT [DF_WeborderPrefs_employment] DEFAULT (0) NOT NULL,
    [creditreport]        BIT           CONSTRAINT [DF_WeborderPrefs_creditreport] DEFAULT (0) NOT NULL,
    [PreferenceCounty1]   VARCHAR (50)  NULL,
    [PreferenceCounty2]   VARCHAR (50)  NULL,
    [PreferenceState1]    VARCHAR (2)   NULL,
    [PreferenceState2]    VARCHAR (2)   NULL,
    [PreferenceStatewide] VARCHAR (2)   NULL,
    [OtherAreas]          BIT           CONSTRAINT [DF_WeborderPrefs_OtherAreas] DEFAULT (0) NOT NULL,
    [Service900]          BIT           CONSTRAINT [DF_WeborderPrefs_Service900] DEFAULT (0) NOT NULL,
    [homehealth]          BIT           CONSTRAINT [DF_Client_homehealth] DEFAULT (0) NULL,
    [childcare]           BIT           CONSTRAINT [DF_Client_childcare] DEFAULT (0) NOT NULL,
    [socialworker]        BIT           CONSTRAINT [DF_Client_socialworker] DEFAULT (0) NOT NULL,
    [mentalhealth]        BIT           CONSTRAINT [DF_Client_mentalhealth] DEFAULT (0) NOT NULL,
    [teacher]             BIT           CONSTRAINT [DF_Client_teacher] DEFAULT (0) NOT NULL,
    [skillednursing]      BIT           CONSTRAINT [DF_Client_skillednursing] DEFAULT (0) NOT NULL,
    [Rehabilitation]      BIT           CONSTRAINT [DF_Client_Rehabilitation] DEFAULT (0) NULL,
    [Longtermcare]        BIT           CONSTRAINT [DF_Client_Longtermcare] DEFAULT (0) NULL,
    [CrimPreview]         BIT           CONSTRAINT [DF_WeborderPrefs_CrimPreview] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_WeborderPrefs] PRIMARY KEY CLUSTERED ([WebOrderPrefsID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_WeborderPrefs_CLNO]
    ON [dbo].[WeborderPrefs]([Clno] ASC)
    INCLUDE([CrimPreview]) WITH (FILLFACTOR = 70);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WeborderPrefs', @level2type = N'COLUMN', @level2name = N'CrimPreview';

