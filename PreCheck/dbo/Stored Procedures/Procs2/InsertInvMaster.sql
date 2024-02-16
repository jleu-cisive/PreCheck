CREATE PROCEDURE InsertInvMaster
  @InvoiceNumber int,
  @Clno smallint,
  @Printed bit,
  @InvDate datetime,
  @Sale smallmoney,
  @Tax smallmoney
as
  set nocount on
  insert into InvMaster
    (InvoiceNumber, Clno, Printed, InvDate,
      Sale, Tax)
  values
    (@InvoiceNumber, @Clno, @Printed, @InvDate,
      @Sale, @Tax)
