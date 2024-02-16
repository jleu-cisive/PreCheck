





--[FormSchoolReportAppListByView]  6085



CREATE PROCEDURE [dbo].[FormSchoolReportAppListByView] 
  @ClientID varchar(10) = '',
  @Program varchar(10) = '',
  @SSN varchar(11) = '',
  @First varchar(20)= '',
  @Last varchar(20)= '',
  @FirstDate varchar(10)= '',
  @EndDate varchar(10)= '',
  @ClientType int= '0'
 AS
Declare @MySql varchar(8000)
Declare @AppCount int
if @ClientType = '0'
	Select @ClientType = ClientTypeID 
	From   Client 
	Where  CLNO = @ClientID
--- @AppCount is used to apply date condition or leave the dates empty 
select @AppCount = Count(APNO ) FROM dbo.ApplStudentAction Where CLNO_Hospital = @ClientID

if (@AppCount > '1000')
	begin

		if (@FirstDate = '' and @EndDate = '' )
		begin 
			if (@First<>'' or @Last<>'' or @Program <>'' or @SSN <>'')
				begin
					set @FirstDate =  ''
					set @EndDate =  ''
				end
				else
				begin
					set @FirstDate =  CONVERT(varchar,dateadd(year,-2,getdate()),1)--'01/01/2007'
					set @EndDate =   CONVERT(varchar, getdate()+1, 1)
					
				end

	
		end
	end
else
	begin
	if (@FirstDate = '' and @EndDate = '' )
		begin 
		set @FirstDate =  ''
		set @EndDate =  ''
		end
	end

	--select @FirstDate,@EndDate
if (@ClientTYpe = '6' OR @ClientTYpe = '11')
 Begin
---  set @MySql = 'SELECT c.name,  c.DescriptiveName, a.APNO, a.ApStatus, a.APDate, a.First,a.Last,''xxx-xx-'' + SUBSTRING(a.SSN,8,4) as   SSN,
--		dbo.GetAssignedHospitalsByAppNo (a.ApNo)  AssignedHospitals
--   FROM dbo.Client c, dbo.Appl a WHERE a.CLNO = c.CLNO and a.Clno = ' + @ClientID 


--
set @MySql = 'SELECT  a.APNO, a.ApStatus, CONVERT(CHAR(23),a.ApDate,22) APDate, a.First,a.Last, ''' + 'xxx-xx-' + '''  + SUBSTRING(a.SSN ,8,4) as SSN , cp.Name as prog,
		  dbo.GetAssignedHospitalsByAppNo (a.ApNo)  AssignedHospitals
		   FROM dbo.Appl a 
		   Inner JOIN Client c On a.clno=c.clno 
		   left join dbo.ClientProgram cp on a.ClientProgramID = cp.ClientProgramID
		   WHERE  a.Clno = ''' + @ClientID + ''''
--took 
--' or c.WebOrderParentCLNO= ' + @ClientID+
 if  (@Program <>  '' )
 begin
 set   @MySql = @MySql +  ' and a.ClientProgramID = ''' + @Program + ''''
 end

 if  (@SSN <>  '' )
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

--Print @MySQL
end

if @ClientType = '12'  --HGC School
	Begin

		set @MySql = 'SELECT max(isnull(cast(ClientFlag as int),0)) ClientFlag,a.APNO, CONVERT(CHAR(23),a.APDate,22) ApDate, a.ApStatus, 
		a.First, a.Last , ''' + 'xxx-xx-' + '''  + SUBSTRING(a.SSN ,8,4) as SSN ,
		c.Name, s.StudentActionID, (c.name +  ''' + ' - ' + ''' + cp.Name) as prog,
		isnull(af.FlagStatus,0) as FlagStatus 
		FROM Appl a  
		inner join Client c on a.CLNO = c.CLNO  
		left join ApplStudentAction s on  a.APNO = s.APNO and s.clno_hospital = ' + @ClientID + '
		left join dbo.ClientProgram cp on a.ClientProgramID = cp.ClientProgramID 
		left Join Crim Cr on a.apno = cr.apno
		left join applflagstatus af on af.apno = a.apno
		left join (Select CLNO_School,CrimStatusCode StatusCode,ClientFlag
		from dbo.ClientFlagSelection CFS inner join clientcrimstatus	CCS 
		on CFS.SectionStatusID = CCS.ClientCrimStatusID
		inner join ClientSchoolHospital CSH on CFS.CLNO=CSH.CLNO_Hospital 
		Where CFS.CLNO = ' + @ClientID + ') query
		on a.CLNO = query.CLNO_School and Cr.Clear = StatusCode 
		Where 1 = 1 and S.IsActive = 1 '

		 if (@SSN = '' and @First = '' and @Last = '' and  @FirstDate = '' AND @EndDate = '')
			begin
			 set @MySql = @MySql + ' AND (s.DateStatusSet >= dateadd(d,-60,getdate()) OR s.DateStatusSet is null OR StudentActionID = 0) '
			end

		 if  (@Program <>  '' )
			 begin
				set   @MySql = @MySql +  ' and a.ClientProgramID = ''' + @Program + ''''
			 end

		  if  (@SSN <>  '' )
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

		set @MySql = @MySql + ' Group By a.APNO, a.APDate , a.ApStatus, a.First, a.Last ,  a.SSN  ,c.Name, s.StudentActionID, (c.name +  ''' + ' - ' + ''' + cp.Name),af.FlagStatus '

		set @MySql = @MySql + ' Having  a.APNO in (Select APNO  	FROM dbo.ApplStudentAction Where CLNO_Hospital = ' + @ClientID + ') '

		set @MySql = @MySql + ' UNION ALL ' 

		set @MySql = @MySql + ' Select 0 ClientFlag,0 APNO,CONVERT(CHAR(23),DateHospitalAssigned,22) ApDate, null ApStatus, firstname First,lastname Last , ''xxx-xx-''  + SUBSTRING(SSN ,8,4) as SSN ,
								lastname + '', '' + firstname AS Name, s.StudentActionID, '''' as prog,'''' as FlagStatus
								From ApplStudentAction s 
								Where  APNO is NULL and IsActive = 1 and CLNO_Hospital = ' + @ClientID 

		set @MySql = @MySql + ' Order By ClientFlag Desc, ApDate'


	End

if @ClientType = '4' -- Hospital Login
 begin

set @MySql = 'SELECT a.APNO, CONVERT(CHAR(23),a.APDate,22) ApDate, a.ApStatus, a.First, 
a.Last , ''' + 'xxx-xx-' + '''  + SUBSTRING(a.SSN ,8,4) as SSN ,c.Name, s.StudentActionID, 
(c.name +  ''' + ' - ' + ''' + cp.Name) as prog, isnull(af.FlagStatus,0) as FlagStatus
FROM Appl a  inner join Client c on a.CLNO = c.CLNO  left join ApplStudentAction s on  a.APNO = s.APNO and s.clno_hospital = ' + @ClientID + '
left join dbo.ClientProgram cp on a.ClientProgramID = cp.ClientProgramID left join applflagstatus af on af.apno = a.apno WHERE  a.APNO in  
(Select APNO  	FROM dbo.ApplStudentAction Where CLNO_Hospital = ' + @ClientID + ') '  


 if (@SSN = '' and @First = '' and @Last = '' and  @FirstDate = '' AND @EndDate = '')
	begin
     set @MySql = @MySql + ' AND (s.DateStatusSet >= dateadd(d,-60,getdate()) OR s.DateStatusSet is null OR StudentActionID = 0) '
	end

 if  (@Program <>  '' )
	 begin
		set   @MySql = @MySql +  ' and a.ClientProgramID = ''' + @Program + ''''
	 end

  if  (@SSN <>  '' )
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


 set   @MySql = @MySql  + ' ORDER BY s.StudentActionID,a.APNO DESC'
end


Print @MySQL
exec(@MySql)









