CREATE PROCEDURE InsertLicType
  @Lic_Type varchar(30)
as
  set nocount on
  insert into lictypes
    (lic_type)
  values
    (@lic_type)
