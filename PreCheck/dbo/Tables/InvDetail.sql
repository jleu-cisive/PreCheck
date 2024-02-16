CREATE TABLE [dbo].[InvDetail] (
    [InvDetID]      INT           IDENTITY (1, 1) NOT NULL,
    [APNO]          INT           NOT NULL,
    [Type]          SMALLINT      NOT NULL,
    [Subkey]        INT           NULL,
    [SubKeyChar]    VARCHAR (50)  NULL,
    [Billed]        BIT           CONSTRAINT [DF_InvDetail_Billed] DEFAULT (0) NOT NULL,
    [InvoiceNumber] INT           NULL,
    [CreateDate]    DATETIME      NOT NULL,
    [Description]   VARCHAR (100) NULL,
    [Amount]        SMALLMONEY    NULL,
    CONSTRAINT [PK_InvDetail] PRIMARY KEY CLUSTERED ([InvDetID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_InvDetail_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_InvDetail_InvMaster] FOREIGN KEY ([InvoiceNumber]) REFERENCES [dbo].[InvMaster] ([InvoiceNumber])
);


GO
CREATE NONCLUSTERED INDEX [IX_InvDetail_APNO]
    ON [dbo].[InvDetail]([APNO] ASC)
    INCLUDE([InvDetID], [Type], [Subkey], [SubKeyChar], [Billed], [InvoiceNumber], [CreateDate], [Description], [Amount]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_InvDetail_InvoiceNumber]
    ON [dbo].[InvDetail]([InvoiceNumber] ASC)
    INCLUDE([APNO], [Type], [Description], [Amount]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [APNO_Type_Includes]
    ON [dbo].[InvDetail]([APNO] ASC, [Type] ASC)
    INCLUDE([Amount]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210810-063606]
    ON [dbo].[InvDetail]([CreateDate] ASC)
    INCLUDE([APNO], [Description], [Amount]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_InvDetail_Billed_Description]
    ON [dbo].[InvDetail]([Billed] ASC, [Description] ASC)
    INCLUDE([APNO], [InvoiceNumber])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_InvDetail_Amount]
    ON [dbo].[InvDetail]([Amount] ASC)
    INCLUDE([APNO], [Description]);


GO
CREATE TRIGGER [dbo].[InvDetail_Update_Logging]
On [dbo].[InvDetail]
For UPDATE
As

Declare @OldDesc varchar(100)
Declare @NewDesc varchar(100)
Declare @OldAmount smallmoney
Declare @NewAmount smallmoney
Declare @UpdatedID int
Declare @APNO int
if (Select Count(*) FROM Deleted) = 1
BEGIN
Select @OldDesc = (Select Description From Deleted)
SELECT @NewDesc = (Select Description From Inserted)
SELECT @OldAmount = (Select Amount From Deleted)
SELECT @NewAmount = (Select Amount From Inserted)
SELECT @UpdatedId = (Select InvDetID FROM Inserted)
SELECT @APNO = (Select apno FROM Inserted)

INSERT INTO InvDetailLogging (UpdatedID,apno,OldDesc,NewDesc,OldAmount,NewAmount,ModifiedDate)
VALUES (@UpdatedID,@APNO,@OldDesc,@NewDesc,@OldAmount,@NewAmount,getdate())
END


GO
DISABLE TRIGGER [dbo].[InvDetail_Update_Logging]
    ON [dbo].[InvDetail];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Descr', @value = N'0=Package; 1=Aditional Fees; 2=Crim; 3=civil; 4=Credit,Social; 5=MVR; 6=Empl; 7=Edu; 8=ProfLic; 9=PersRef', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvDetail', @level2type = N'COLUMN', @level2name = N'Type';

