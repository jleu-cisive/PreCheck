CREATE PROCEDURE [dbo].[PendingCrims_GetPreviousRecord]
	@county varchar (200),
	@ssn varchar(11),
	@apno int = null,
	@CountOnly bit = 0
AS
BEGIN
--[PendingCrims_GetPreviousRecord] '**Statewide**, AL','987-65-4123',2465207,0
--[PendingCrims_GetPreviousRecord] '**Statewide**, AL','987-65-4123',2465207,1
	
IF @CountOnly = 0
 
	--Transferred Records
	select a.apno,c.IrisOrdered apdate,c.crimid, a.inuse, c.county, c.offense,c.caseNo,'T' RecordType,0 TransferredRecordCount, 0 PreviousRecordCount
	from dbo.appl a with (nolock)
	inner join dbo.crim c with (nolock) on a.apno = c.apno
	where isnull(a.apstatus,'P') in ('P','W')
	and c.ishidden = 0
	and isnull(c.clear,'') = 'i'
	and ( c.county = @county and a.apno=@apno)  --and a.SSN = @ssn )
	UNION ALL
	--Previous Records
	select a.apno,c.IrisOrdered apdate,c.crimid, a.inuse, c.county, c.offense,c.caseNo,'P' RecordType,0 TransferredRecordCount, 0 PreviousRecordCount
	from dbo.appl a with (nolock)
	inner join dbo.crim c with (nolock) on a.apno = c.apno
	where --c.ishidden = 0 and
	 isnull(c.clear,'') in ('F','P')
	and ( c.county = @county and a.SSN = @ssn and a.apno<>isnull(@apno,0))
ELSE
 BEGIN
	Declare @TransferredRecordCount int, @PreviousRecordCount int
	--Transferred Records
	select @TransferredRecordCount = count(crimid)
	from  dbo.crim c with (nolock) 
	where c.ishidden = 0
	and isnull(c.clear,'') = 'i'
	and ( c.county = @county and c.apno=@apno)

	--Previous Records
	select @PreviousRecordCount = count(crimid) 
	from dbo.appl a with (nolock)
	inner join dbo.crim c with (nolock) on a.apno = c.apno
	where --c.ishidden = 0 and
	 isnull(c.clear,'') in ('F','P')
	and ( c.county = @county and a.SSN = @ssn and a.apno<>isnull(@apno,0))	

	Select @apno apno,cast('1/1/1900' as datetime) apdate,0 crimid, '' inuse,@county county, '' offense,'' caseNo,'' RecordType,@TransferredRecordCount TransferredRecordCount, @PreviousRecordCount PreviousRecordCount
  END



END