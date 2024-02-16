CREATE TABLE [dbo].[Integration_VendorOrder_Submitted] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [EmplID]      INT           NOT NULL,
    [OrderID]     INT           NOT NULL,
    [SubmittedTo] VARCHAR (50)  NULL,
    [CreatedDate] SMALLDATETIME NULL,
    CONSTRAINT [PK_Integration_VendorOrder_Submitted] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_Integration_VendorOrder_Submitted_OrderID_SubmittedTo]
    ON [dbo].[Integration_VendorOrder_Submitted]([OrderID] ASC, [SubmittedTo] ASC)
    ON [PRIMARY];

