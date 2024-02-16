CREATE PROCEDURE InsertrefAttention
  @name varchar(50)
 as
  set nocount on
  insert into refAttention
    (name)
  values
    (@name)