






CREATE PROCEDURE [dbo].[SearchReleaseForms] 

@isAll bit,
@FirstName varchar(30),
@LastName varchar(30),
@ssn varchar(20),
@clno int,
@StartDate datetime = null,
@EndDate datetime = null

AS
DECLARE @sql Varchar(8000)
DECLARE @strWhere nvarchar(500)
SET @ssn = REPLACE(@ssn,'-','') 
Set @strWhere=' 1=1 '

if @LastName <> ''
	BEGIN
	set @strWhere =@strWhere+ ' and [last] LIKE ''' + @LastName + '%'''
	END
if @FirstName <> ''
	BEGIN
	set @strWhere =@strWhere+ ' and [first] LIKE ''' + @FirstName+ '%'''
	END
if @clno <> 0
	BEGIN
	set @strWhere =@strWhere + ' and (ReleaseForm.clno =' + Convert(varchar,@clno) + ' ' + 	
'or ReleaseForm.clno in (Select clno from ClientHierarchyByService where parentclno=(select parentclno from ClientHierarchyByService where clno ='+ Convert(varchar,@clno) + ' and refHierarchyServiceID=2) and refHierarchyServiceID=2))'
	
	END
if @ssn <> ''
	BEGIN
	--set @strWhere =@strWhere + ' and SSN LIKE ''' + @ssn + '%'''
set @strWhere =@strWhere + ' and REPLACE(SSN,''-'','''') LIKE ''' + @ssn + '%'''
   --set @sql=@sql + ' and REPLACE(e.SSN,''-'','''')='''+ @ssn + '''' 
	END
if @StartDate is not null AND @EndDate is not null
	BEGIN
	set @strWhere = @strWhere + ' and date >= ''' + CONVERT(char(20),@StartDate,101) + ''' and date < DATEADD(d,1,''' + CONVERT(char(20),@EndDate,101) + ''')'
	END



--print @strWhere


if @isAll=0
begin
	set @sql='SELECT TOP 500 ReleaseFormID, ssn, [date], [first], [last], ReleaseForm.CLNO FROM ReleaseForm (NOLOCK) left outer join ClientHierarchyByService (NOLOCK) on ClientHierarchyByService.CLNO=ReleaseForm.CLNO  and ClientHierarchyByService.refHierarchyServiceID=2 where ' + @strWhere + ' order by date DESC'
end
else
begin
	set @sql='SELECT  ReleaseFormID, ssn, [date], [first], [last], ReleaseForm.CLNO FROM ReleaseForm (NOLOCK) left outer join ClientHierarchyByService (NOLOCK) on ClientHierarchyByService.CLNO=ReleaseForm.CLNO and ClientHierarchyByService.refHierarchyServiceID=2 where releaseform.clno = 0'
end

--print @sql
exec  (@sql)











