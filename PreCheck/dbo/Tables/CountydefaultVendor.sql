CREATE TABLE [dbo].[CountydefaultVendor] (
    [countyid]      INT            IDENTITY (1, 1) NOT NULL,
    [County]        NVARCHAR (50)  NULL,
    [State]         NVARCHAR (20)  NULL,
    [VendorCompany] NVARCHAR (100) NULL,
    [FirstName]     NVARCHAR (20)  NULL,
    [johndo]        NVARCHAR (72)  NULL,
    [LastName]      NVARCHAR (30)  NULL,
    [VendorPhone]   NVARCHAR (20)  NULL,
    [VendorFax]     NVARCHAR (20)  NULL,
    [VendorEmail]   NVARCHAR (50)  NULL,
    [VendorID]      INT            NULL,
    [vendortype]    CHAR (2)       NULL,
    [type]          CHAR (2)       NULL,
    [vendornotes]   VARCHAR (200)  NULL,
    CONSTRAINT [PK_CountydefaultVendor] PRIMARY KEY CLUSTERED ([countyid] ASC) WITH (FILLFACTOR = 50)
);

