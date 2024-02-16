CREATE PROCEDURE InsertInvDetail
  @Apno int,
  @Type smallint,
  @Subkey int,
  @SubkeyChar varchar(2),
  @Billed bit,
  @InvoiceNumber int,
  @CreateDate datetime,
  @Description varchar(50),
  @Amount smallmoney,
  @InvDetID int OUTPUT
AS
  set nocount on
  
  insert into InvDetail
    (Apno, Type, Subkey, SubkeyChar, Billed, InvoiceNumber,
      CreateDate, Description, Amount)
  values
    (@Apno, @Type, @Subkey, @SubkeyChar, @Billed, @InvoiceNumber,
      @CreateDate, @Description, @Amount)
  select @InvDetID = @@Identity
