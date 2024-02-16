CREATE TABLE [dbo].[Billing_EmailContent] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [BillingCycle] CHAR (10)      NOT NULL,
    [EmailSubject] VARCHAR (3000) NOT NULL,
    [EmailHeader]  VARCHAR (3000) NOT NULL,
    [EmailBody]    VARCHAR (3000) NOT NULL,
    [EmailFooter]  VARCHAR (3000) NOT NULL
);

