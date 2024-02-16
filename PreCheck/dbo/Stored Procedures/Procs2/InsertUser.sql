CREATE PROCEDURE InsertUser
  @UserID varchar(8),
  @Passwd varchar(15),
  @Name varchar(20),
  @SecLevel smallint,
  @Disabled bit
AS
  set nocount on
  insert into users
    (UserID, Passwd, Name, SecLevel, Disabled)
  values
    (@UserID, @Passwd, @Name, @SecLevel, @Disabled)
