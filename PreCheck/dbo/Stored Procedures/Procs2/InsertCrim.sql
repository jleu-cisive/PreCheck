CREATE PROCEDURE [dbo].[InsertCrim]
  @CrimID int,
  @Apno int,
  @County varchar(25),
  @Clear varchar(1),
  @Ordered varchar(14),
  @Name varchar(30),
  @DOB datetime,
  @SSN varchar(11),
  @CaseNo varchar(50),
  @Date_Filed datetime,
  @Degree varchar(1),
  @Offense varchar(50),
  @Disposition varchar(50),
  @Sentence varchar(50),
  @Fine varchar(50),
  @Disp_Date datetime,
  @Pub_Notes text,
  @Priv_Notes text
as
  set nocount on
  insert into Crim
    (CrimID, Apno, County, Clear, Ordered, Name,
      DOB, SSN, CaseNo, Date_Filed, Degree,
      Offense, Disposition, Sentence, Fine, Disp_Date,
      Pub_Notes, Priv_Notes)
  values
    (@CrimID, @Apno, @County, @Clear, @Ordered, @Name,
      @DOB, @SSN, @CaseNo, @Date_Filed, @Degree,
      @Offense, @Disposition, @Sentence, @Fine, @Disp_Date,
      @Pub_Notes, @Priv_Notes)