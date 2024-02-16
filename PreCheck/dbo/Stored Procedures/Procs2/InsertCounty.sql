-- Alter Procedure InsertCounty
CREATE  PROCEDURE dbo.InsertCounty
  @county varchar(25),
  @crim_source varchar(2),
  @crim_phone varchar(20),
  @crim_fax varchar(20),
  @crim_addr varchar(255),
  @crim_comment varchar(20),
	@Crim_DefaultRate smallmoney,
  @civ_source varchar(2),
  @civ_phone varchar(20),
  @civ_fax varchar(20),
  @civ_addr varchar(255),
  @civ_comment varchar(20)
as
  set nocount on
  insert into dbo.TblCounties
    (county, crim_source, crim_phone, crim_fax, crim_addr,
      crim_comment, Crim_DefaultRate, civ_source, civ_phone, civ_fax,
      civ_addr, civ_comment)
  values
    (@county, @crim_source, @crim_phone, @crim_fax, @crim_addr,
      @crim_comment, @Crim_DefaultRate, @civ_source, @civ_phone, @civ_fax,
      @civ_addr, @civ_comment)
