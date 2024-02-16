CREATE PROCEDURE [dbo].[InsertCivil]
  @CivilID int,
  @Apno int,
  @County varchar(25),
  @Clear varchar(1),
  @Ordered varchar(14),
  @Name varchar(30),
  @Plaintiff varchar(30),
  @CaseNo varchar(50),
  @Date_Filed datetime,
  @CaseType varchar(30),
  @Disp_Date datetime,
  @Pub_Notes text,
  @Priv_Notes text
as
  set nocount on
  insert into Civil
    (CivilID, Apno, County, Clear, Ordered,
      Name, Plaintiff, CaseNo, Date_Filed,
      CaseType, Disp_Date, Pub_Notes, Priv_Notes)
  values
    (@CivilID, @Apno, @County, @Clear, @Ordered,
      @Name, @Plaintiff, @CaseNo, @Date_Filed,
      @CaseType, @Disp_Date, @Pub_Notes, @Priv_Notes)
