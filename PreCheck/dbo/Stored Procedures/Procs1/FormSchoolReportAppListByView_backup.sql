CREATE PROCEDURE [DBO].[FormSchoolReportAppListByView_backup] 
@ClientID varchar(10),
  @SSN varchar(11) = '',
  @First varchar(20)= '',
  @Last varchar(20)= '',
  @FirstDate varchar(10)= '',
  @EndDate varchar(10)= '',
  @ClientType int= ''
 AS
Declare @MySql varchar(500)

if @ClientType = '4'
 begin
  set @MySql = ' SELECT a.APNO, a.ApDate, a.ApStatus, a.First, a.Last , a.SSN,c.name,s.StudentActionID
  FROM Appl a inner join Client c on a.CLNO = c.CLNO  left join ApplStudentAction s on  a.APNO = s.APNO and s.clno_hospital =   ' + @ClientID + ' WHERE a.APNO in  (  Select APNO  FROM dbo.ApplStudentAction  Where CLNO_Hospital = '+ @ClientID +')'

  if  (@SSN <>  ' ' )
    begin
     set   @MySql = @MySql +  ' and a.SSN = ''' + @SSN + ''''
    end
  if (@First <> '' )
    begin
    set   @MySql = @MySql + ' and a.first = ''' + @first + ''''
    end
 if ( @Last <> '')
    begin
    set   @MySql = @MySql + ' and a.Last = ''' + @Last + ''''
    end

  if (@FirstDate <> '' and @EndDate <> '' )
    begin
    set   @MySql = @MySql + ' and (a.Apdate Between ''' + @FirstDate + ''' and ''' + @EndDate + ''')'
    end
end


if @ClientTYpe = '6'
 Begin
---  set @MySql = 'SELECT c.name,  c.DescriptiveName, a.APNO, a.ApStatus, a.APDate, a.First,a.Last,''xxx-xx-'' + SUBSTRING(a.SSN,8,4) as   SSN,
--		dbo.GetAssignedHospitalsByAppNo (a.ApNo)  AssignedHospitals
--   FROM dbo.Client c, dbo.Appl a WHERE a.CLNO = c.CLNO and a.Clno = ' + @ClientID 

set @MySql = 'SELECT  c.name,  c.DescriptiveName, a.APNO, a.ApStatus, a.APDate, a.First,a.Last,''xxx-xx-'' + SUBSTRING(a.SSN,8,4) as   SSN,
		dbo.GetAssignedHospitalsByAppNo (a.ApNo)  AssignedHospitals
		   FROM dbo.Appl a 
		Join Client c On a.clno=c.clno
			WHERE  a.Clno = ' + @ClientID + ' or c.WebOrderParentCLNO=' + @ClientID


 if  (@SSN <>  ' ' )
 begin
 set   @MySql = @MySql +  ' and a.SSN = ''' + @SSN + ''''
 end

 if (@First <> '' )
    begin
    set   @MySql = @MySql + ' and a.first = ''' + @First + ''''
    end
 if ( @Last <> '')
    begin
    set   @MySql = @MySql + ' and a.Last = ''' + @Last + ''''
    end
 if (@FirstDate <> '' and @EndDate <> '' )
   begin
   set @MySql = @MySql + ' and (a.Apdate Between ''' + @FirstDate + ''' and ''' + @EndDate + ''')'
   end

End
--PRint @MySQL
exec(@MySql)