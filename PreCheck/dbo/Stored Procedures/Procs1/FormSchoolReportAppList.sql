




CREATE PROCEDURE [dbo].[FormSchoolReportAppList]
  @ClientID int,
  @ProgramID int,
  @SSN varchar(11) = '',
  @First varchar(50)= '',
  @Last varchar(50)= '',
  @FirstDate varchar(100)='',
  @EndDate varchar(100)='',
  @IsHidden bit,--three values: null, 0, 1
  @IsArchived bit--three values: null, 0, 1
 AS
IF LEN(@SSN)>0
	BEGIN
		SET @SSN=REPLACE(@SSN, 'x', '')
		SET @SSN=REPLACE(@SSN, '-', '')
		IF LEN(@SSN)=9
			SET @SSN=SUBSTRING(@SSN, 1, 3) + '-' + SUBSTRING(@SSN, 4, 2) + '-' + SUBSTRING(@SSN, 6, 4)
	END
if (@FirstDate = '' and @EndDate = '' )
begin 
		if (@First<>'' or @Last<>'' or @ProgramID IS NOT NULL or @SSN <>'')
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

		
	SELECT     
		AP.APNO, 
		AP.ApStatus, 
		ISNULL(AP.CreatedDate, AP.ApDate) AS APDate,
		AP.First, 
		AP.Last, 
		AP.SSN, 
		CP.ClientProgramID,
		CP.Name AS ClientProgram, 
		APSC.IsHidden,
		APSC.HideUnHideDateTime,
		NULL AS IsArchived	--must be set to null at this time
	   ,ISNULL(AF.FlagStatus,0) as FlagStatus
--, (CASE AF.FlagStatus WHEN 1 THEN 'Clear' ELSE 'NeedsReview' END) as FlagStatus 
	INTO #tempSchoolReportTable
	FROM        
		Appl AS AP INNER JOIN
		Client AS CL ON AP.CLNO = CL.CLNO LEFT OUTER JOIN
		ApplStudentCheck AS APSC ON AP.APNO = APSC.APNOStudentCheck
		LEFT OUTER JOIN ClientProgram AS CP ON AP.ClientProgramID = CP.ClientProgramID
	    LEFT OUTER JOIN applFlagStatus AF ON AP.APNO = AF.APNO
	WHERE (CASE WHEN @ClientID IS NOT NULL AND AP.CLNO<>@ClientID THEN 0 ELSE 1 END) = 1	
		--AND AP.EnteredVia='StuWeb'
	
	--If no ApplStudentCheck data, the IsHidden and HideUnHideDateTime will be null, 
	--Use ApDate if it is not null
	--Observed, the ApDate and CreatedDate will not both empty
	UPDATE #tempSchoolReportTable 
	SET HideUnHideDateTime=ApDate
	WHERE HideUnHideDateTime IS NULL
		AND ApDate IS NOT NULL
	
	--If no ApplStudentCheck data, the IsHidden will be null, 
	--in such case, by default, we think it is hidden when HideAndUnhideDateTime is over 1 year ago
	--such case happens only those before 8/28/2007
	--this is optional case, up to decision
	DECLARE @AutoHideThoseRecordsOverOneYear BIT
	SET @AutoHideThoseRecordsOverOneYear=0
	IF @AutoHideThoseRecordsOverOneYear=1
		UPDATE #tempSchoolReportTable 
		SET IsHidden=1
		WHERE IsHidden IS NULL
			AND HideUnHideDateTime IS NOT NULL
			AND DATEADD(YEAR, 1, HideUnHideDateTime)<GETDATE()

	--If no ApplStudentCheck data, the IsHidden will be null, 
	--For all the others, set to false
	UPDATE #tempSchoolReportTable 
	SET IsHidden=0
	WHERE IsHidden IS NULL

	--If Hidden and 1 year ago, taken to be archived
	UPDATE #tempSchoolReportTable 
	SET IsArchived=1
	WHERE IsHidden=1 
		AND HideUnHideDateTime IS NOT NULL
		AND DATEADD(YEAR, 1, HideUnHideDateTime)<GETDATE()

	--If IsArchived is not set from last step, taken to be non archived
	UPDATE #tempSchoolReportTable 
	SET IsArchived=0
	WHERE IsArchived IS NULL
	 
	DECLARE @Filter VARCHAR(8000)
	SET @Filter=' (1=1) '

	if(@IsHidden is null AND @IsArchived is null) --show all
		SET @Filter=@Filter+' AND (1=1) '
	if(@IsHidden is null AND @IsArchived is not null)
		SET @Filter=@Filter+' AND (SRT.IsArchived='+CAST(@IsArchived AS VARCHAR(10))+') '
	if(@IsHidden is not null AND @IsArchived is null)
		SET @Filter=@Filter+' AND (SRT.IsHidden='+CAST(@IsHidden AS VARCHAR(10))+') '
	if(@IsHidden is not null AND @IsArchived is not null)
		SET @Filter=@Filter+' AND (SRT.IsHidden='+CAST(@IsHidden AS VARCHAR(10))+') '+' AND (SRT.IsArchived='+CAST(@IsArchived AS VARCHAR(10))+') '

	if  (@ProgramID IS NOT NULL )
		set @Filter = @Filter +  ' AND (SRT.ClientProgramID = ' + CAST(@ProgramID AS VARCHAR(50))+ ') '
	if  (@SSN <>  '' )--equal or LIKE (from latter part)
		set @Filter = @Filter +  ' AND (SRT.SSN = ''' + @SSN + ''' OR SRT.SSN LIKE ''%' + @SSN + ''') '
	if (@First <> '' )
		set @Filter = @Filter + ' AND (SRT.First = ''' + @First + ''') '
	if ( @Last <> '' )
		set @Filter = @Filter + ' AND (SRT.Last = ''' + @Last + ''') '
	if (@FirstDate <> '' )
		set @Filter = @Filter + ' AND (SRT.ApDate >= ''' + @FirstDate + ''') '
	if (@EndDate <> '' )
		set @Filter = @Filter + ' AND (SRT.ApDate <= ''' + @EndDate + ''') '

	Declare @Sql varchar(8000)
	set @Sql = ' SELECT *  FROM #tempSchoolReportTable AS SRT WHERE '+@Filter+ 'Order By APDate DESC'
	--print @Sql

	exec(@Sql)
	drop table #tempSchoolReportTable




