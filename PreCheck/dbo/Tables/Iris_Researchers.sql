CREATE TABLE [dbo].[Iris_Researchers] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [R_id]                 INT            NULL,
    [R_Name]               NVARCHAR (50)  NULL,
    [R_Password]           NVARCHAR (50)  NULL,
    [R_Email_Address]      NVARCHAR (100) NULL,
    [R_Address]            NVARCHAR (50)  NULL,
    [R_Address2]           NVARCHAR (50)  NULL,
    [R_City]               NVARCHAR (50)  NULL,
    [R_State_Province]     NVARCHAR (50)  NULL,
    [R_Country]            NVARCHAR (50)  NULL,
    [R_Zip]                NVARCHAR (50)  NULL,
    [R_Phone]              NVARCHAR (50)  CONSTRAINT [DF_Iris_Researchers_R_Phone] DEFAULT (713 - 369 - 580) NULL,
    [R_Alternate_Phone]    NVARCHAR (50)  NULL,
    [R_Fax]                NVARCHAR (50)  NULL,
    [R_Active]             NVARCHAR (3)   NULL,
    [R_Delivery]           NVARCHAR (50)  NULL,
    [R_Levelof_Conf]       NVARCHAR (50)  NULL,
    [weburl]               NVARCHAR (100) NULL,
    [R_Vendortype]         NVARCHAR (20)  NULL,
    [R_VendorNotes]        NTEXT          NULL,
    [R_Firstname]          NVARCHAR (50)  NULL,
    [R_Lastname]           NVARCHAR (50)  NULL,
    [R_Middlename]         NVARCHAR (50)  NULL,
    [altfirst]             NVARCHAR (50)  NULL,
    [altlast]              NVARCHAR (50)  NULL,
    [altmiddle]            NVARCHAR (50)  NULL,
    [R_PaymentMethod]      NVARCHAR (50)  NULL,
    [Tax]                  NVARCHAR (10)  NULL,
    [contact_name]         NVARCHAR (50)  NULL,
    [R_Alias_Charge]       NVARCHAR (5)   NULL,
    [Inactive_notes]       NVARCHAR (240) NULL,
    [Avg_turnaround]       NVARCHAR (20)  NULL,
    [vendorruleid]         INT            NULL,
    [vendorruleactive]     VARCHAR (4)    NULL,
    [vendorrulestartdate]  DATETIME       NULL,
    [vendorruleenddate]    DATETIME       NULL,
    [vendorrulenotes]      NVARCHAR (240) NULL,
    [Iris_AutoSender]      BIT            NULL,
    [Cutoff]               DATETIME       NULL,
    [CrimPublicNotes]      NVARCHAR (240) NULL,
    [R_AvgTurnAround]      INT            NULL,
    [Investigator]         VARCHAR (8)    NULL,
    [UserID]               VARCHAR (8)    NULL,
    [Password]             VARCHAR (15)   NULL,
    [web_service_id]       BIGINT         NULL,
    [Temp_R_ID]            INT            NULL,
    [R_VendorConfirmation] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Iris_Researchers] PRIMARY KEY NONCLUSTERED ([id] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA]
) ON [FG_INDEX] TEXTIMAGE_ON [PRIMARY];


GO
CREATE UNIQUE CLUSTERED INDEX [ak_iris_researchers]
    ON [dbo].[Iris_Researchers]([R_id] ASC) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Iris_Researchers_1]
    ON [dbo].[Iris_Researchers]([R_Delivery] ASC)
    INCLUDE([R_id], [R_Name]) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

