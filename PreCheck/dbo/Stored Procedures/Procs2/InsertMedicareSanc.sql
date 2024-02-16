CREATE PROCEDURE InsertMedicareSanc
  @MedicareSancId int,
  @LastSoundex char(4),
  @LastName varchar(20),
  @FirstName varchar(15),
  @MidName varchar(15),
  @BusName varchar(30),
  @General varchar(20),
  @Specialty varchar(20),
  @UPIN varchar(6),
  @DOB datetime,
  @Address varchar(30),
  @City varchar(20),
  @State varchar(2),
  @Zip varchar(5),
  @SancType varchar(9),
  @SancDate datetime,
  @ReinDate datetime
as
  set nocount on
  insert into MedicareSanc
    (MedicareSancID, LastSoundex, LastName, FirstName,
      MidName, BusName, General, Specialty, UPIN,
      DOB, Address, City, State, Zip, SancType, SancDate, 
      ReinDate)
  values
    (@MedicareSancID, @LastSoundex, @LastName, @FirstName,
      @MidName, @BusName, @General, @Specialty, @UPIN,
      @DOB, @Address, @City, @State, @Zip, @SancType, @SancDate,
      @ReinDate)
