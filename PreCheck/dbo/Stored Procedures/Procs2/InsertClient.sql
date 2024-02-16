CREATE PROCEDURE InsertClient
  @Clno smallint,
  @Name varchar(25),
  @Addr1 varchar(25),
  @Addr2 varchar(25),
  @Addr3 varchar(25),
  @Phone varchar(20),
  @Fax varchar(20),
  @Contact varchar(25),
  @Email varchar(35),
  @TaxRate smallmoney,
  @Status char(1),
  @BillCycle char(1),
  @LastInvDate datetime,
  @LastInvAmount smallmoney
as
  set nocount on
  insert into Client
    (Clno, Name, Addr1, Addr2, Addr3, Phone, Fax, Contact,
      Email, TaxRate, Status, BillCycle, LastInvDate, LastInvAmount)
  values
    (@Clno, @Name, @Addr1, @Addr2, @Addr3, @Phone, @Fax, @Contact,
      @Email, @TaxRate, @Status, @BillCycle, @LastInvDate, @LastInvAmount)
