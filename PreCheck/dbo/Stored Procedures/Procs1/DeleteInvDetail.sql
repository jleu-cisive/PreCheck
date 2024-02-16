CREATE PROCEDURE DeleteInvDetail
  @InvDetID int
as
  set nocount on
  delete from InvDetail where InvDetID = @InvDetID
