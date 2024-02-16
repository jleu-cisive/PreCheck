

CREATE procedure [dbo].[Integration_OrderMgmt_UpdateApplNotes]
(@apno int,@comments varchar(max),@packageid int = null,@ssn varchar(11) = null,@dob datetime = null,@hasDOB bit = null)
as

declare @existingcomments varchar(max)


if (@packageid is not null)
	update appl set packageid = @packageid where apno = @apno
	
if (@apno is not null)
begin
	set @existingcomments = (select IsNull(cast(priv_notes as varchar(max)),'') as priv_notes from appl where apno = @apno)	
	set @comments = @existingcomments + '; ' + @comments
	if (@hasdob = 0 or @hasdob is null)	
		update appl set priv_notes = cast(@comments as Text) where apno = @apno	
	else 
		update appl set priv_notes = cast(@comments as Text),ssn = @ssn,dob = @dob where apno = @apno
end



