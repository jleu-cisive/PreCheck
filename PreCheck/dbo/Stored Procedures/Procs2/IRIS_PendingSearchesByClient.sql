CREATE Procedure [dbo].[IRIS_PendingSearchesByClient] @CLNO int AS
Begin
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select a.CLNO,Client.[Name] Client,c.crimid,c.apno,c.county,c.clear,c.ordered
 from crim c with (nolock) inner join appl a with (nolock) on c.apno = a.apno
inner join Client with (nolock) on a.clno = client.clno
left join ClientHierarchyByService Hierarchy with (nolock) on a.clno = Hierarchy.clno
where c.clear in ('O','W')
and ((Hierarchy.ParentCLNO = (Select  ParentCLNO from ClientHierarchyByService where CLNO = @CLNO)) or a.clno  = @CLNO)
order by c.apno asc;
End

