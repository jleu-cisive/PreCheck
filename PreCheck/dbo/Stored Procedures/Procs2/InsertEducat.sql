CREATE PROCEDURE InsertEducat
  @EducatID int,
  @Apno int,
  @School varchar(25),
  @SectStat char(1),
  @Worksheet bit,
  @State varchar(2),
  @Phone varchar(20),
  @Degree_A varchar(25),
  @Studies_A varchar(25),
  @From_A varchar(8),
  @To_A varchar(8),
  @Name varchar(30),
  @Degree_V varchar(25),
  @Studies_V varchar(25),
  @From_V varchar(8),
  @To_V varchar(8),
  @contact_name varchar(30),
  @contact_Title varchar(30),
 @contact_date datetime,
 @investigator varchar(30),  
@Priv_Notes text,
  @Pub_Notes text
 
as
  set nocount on
  insert into educat
    (educatid, apno, school, sectstat, worksheet,
      state, phone, degree_a, studies_a, from_a, 
      to_a, name, degree_v, studies_v, from_v,
      to_v, contact_name, contact_Title, contact_date ,investigator, priv_notes, pub_notes)
  values
    (@educatid, @apno, @school, @sectstat, @worksheet,
      @state, @phone, @degree_a, @studies_a, @from_a,
      @to_a, @name, @degree_v, @studies_v, @from_v,
      @to_v, @contact_name, @contact_title,@contact_date,@investigator, @priv_notes, @pub_notes)