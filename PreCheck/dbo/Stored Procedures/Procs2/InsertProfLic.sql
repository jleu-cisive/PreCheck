CREATE PROCEDURE InsertProfLic
  @proflicid int,
  @apno int,
  @sectstat char(1),
  @worksheet bit,
  @lic_type varchar(30),
  @lic_no varchar(12),
  @year varchar(4),
  @expire datetime,
  @state varchar(8),
  @status varchar(20),
  @priv_notes text,
  @pub_notes text,
  @Organization varchar(30),
  @Contact_Name varchar(30),
   @Contact_Title varchar(30),
  @contact_Date Datetime,
  @investigator varchar(30)

as
  set nocount on
  insert into proflic
    (proflicid, apno, sectstat, worksheet, lic_type, lic_no,
      year, expire, state, status, priv_notes, pub_notes,organization,contact_name,contact_title,contact_date,investigator)
  values
    (@proflicid, @apno, @sectstat, @worksheet, @lic_type, @lic_no,
      @year, @expire, @state, @status, @priv_notes, @pub_notes,@organization,@contact_name,@contact_title,@contact_date,@investigator)