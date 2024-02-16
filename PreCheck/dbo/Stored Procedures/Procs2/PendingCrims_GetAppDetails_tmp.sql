create PROCEDURE [dbo].[PendingCrims_GetAppDetails_tmp]
	-- Add the parameters for the stored procedure here
@Apno int

AS
BEGIN
	
select a.apno,a.apdate,a.SSN,a.last,a.first,
cl.clno, cl.name + ', <b>' + cl.state + '</b>' as 'name', a.DOB, a.pos_sought as 'position', 
(isnull(a.Addr_Street,'-') + ', ' + isnull(a.City,'-') + ', ' + isnull(a.State,'-') + ', Zipcode: ' + isnull(a.Zip, '-')) as 'address',

isnull(nullif(a.DL_Number,''), '-') + ', State:' + isnull(nullif(a.DL_State, ''), '-') as 'dl',
(select count(1) from dbo.crim where clear = 'I' and apno = @Apno and ishidden=0 ) TrasferredRecordCount


from appl a with (nolock)
inner join client cl on a.clno = cl.clno

where a.apno = @Apno
END


--exec [PendingCrims_GetAppDetails] 2216169