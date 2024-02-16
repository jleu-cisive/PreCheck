

--[PrecheckFramework_GetReleaseByFilter] @First='Test',@FirstOperation='Begins With',@CLNO = 'MD',@CLNOOperation='Begins With',@DebugQ = 1 



--[PrecheckFramework_GetReleaseByFilter] @First='Test',@CLNO = 'MD',@DebugQ = 0 ,@PDFOnly=0
 --[PrecheckFramework_GetReleaseByFilter] @First='carolina',@Last='Lopez',@CLNO = '8424',@SSN='462-99-5368',@DebugQ = 1 ,@PDFOnly=0


--[PrecheckFramework_GetReleaseByFilter] @Last='Johnson',@DebugQ = 0 ,@PDFOnly=1,@RecordLimit=1



-- =============================================  

-- Author:  Douglas DeGenaro  

-- Create date: 10/12/2012  

-- Description: procedure to get release information by filters  

-- =============================================  

-- =============================================  

-- Author:  Santosh Chapyala  

-- Modified date: 12/28/2012  

-- Description: 

--1)Added a default recordlimit of 100 percent.

--2)Added a new parameter to return PDF only

--3)Used by intranet asp page to pull the specific online release based on First,last,ssn and clno - used by DEMI

--4)Added Transaction ISolation level to handle Locking

-- ============================================= 

-- Author: Douglas DeGenaro

-- Modified Date : 03/25/2014

-- Description

--1)Added trimming on First and Last

-- ================================================
-- ============================================= 

-- Author: Santosh Chapyala

-- Modified Date : 11/23/2015

-- Description

--1)Added logic to look at the primary first and based on the count, switch to retrieve from Release_Archive

-- ================================================

CREATE PROCEDURE [dbo].[PrecheckFramework_GetReleaseByFilter]  

 -- Add the parameters for the stored procedure here  

  @RecordLimit varchar(30) = '100 Percent '   

 ,@First varchar(20) = null  

 ,@FirstOperation varchar(30) = 'Begins With'   

 ,@FirstComparison varchar(10) = 'and'  

  

 ,@Last varchar(20) = null  

 ,@LastOperation varchar(30) = 'Begins With'   

 ,@LastComparison varchar(10) = 'and'  

  

, @SSN varchar(20) = null  

, @SSNOperation varchar(30) = 'Is Equal To'  

, @SSNComparison varchar(10) = 'and'  

  

, @CLNO varchar(100) = null  

, @CLNOOperation varchar(30) = 'Contains'  

, @CLNOComparison varchar(10) = 'and'  

  

--, @Param varchar(100) = null  

--, @ParamValue varchar(100) = null  

--, @ParamOperation varchar(30) = 'Is Equal To'  

--, @ParamComparison varchar(10) = 'and'  

--, @EnteredVia varchar(30) = 'All' 

,@PDFOnly bit = 0

,@DebugQ bit = 0 

,@AuthOnly bit = 0 

AS  

BEGIN  

 -- SET NOCOUNT ON added to prevent extra result sets from  

 -- interfering with SELECT statements.  

 SET NOCOUNT ON;  

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  --[PrecheckFramework_GetApplicationByFilter_20121114]  @DebugQ = 1 

  

  

declare @FirstWhere varchar(100)  

declare @LastWhere varchar(100)  

declare @SSNWhere varchar(100)  

declare @CLNOWhere varchar(100)

declare @ParamWhere varchar(100)  

declare @totalWhere varchar(1000)  

declare @Sql varchar(1000) 

declare @clientParam varchar(100)



  

IF (ISNULL(@CLNO,'') <> '')

	BEGIN

		--IF (ISNUMERIC(@CLNO) = 0)

		IF TRY_PARSE(@CLNO as int) IS NULL --@CLNO is not numeric

			BEGIN

				SET @clientParam = ' c.Name '

			END	

		ELSE ----@CLNO is numeric

			BEGIN

				SET @clientParam = ' rf.CLNO '

				SET @CLNOOperation = 'Is Equal To' 

			END

	

	END

  



SET @SQl = 'SELECT TOP ' + @RecordLimit    

-- ELSE    

--SET @SQL = 'SELECT '    

   

 IF (IsNull(@First,'') <> '')   

 BEGIN   
  DECLARE @FirstTrimmed varchar(20)
  SET @FirstTrimmed = RTRIM(LTRIM(@First))
  IF  @FirstOperation = 'Begins With'    

  SET @FirstWhere = ' RTRIM(LTRIM(First)) Like ''' + @FirstTrimmed + '%'''    

 ELSE IF  @FirstOperation = 'Contains'    

  SET @FirstWhere = ' RTRIM(LTRIM(First)) Like ''%' + @FirstTrimmed + '%'''    

 ELSE IF  @FirstOperation = 'Ends With'    

  SET @FirstWhere = ' RTRIM(LTRIM(First)) Like ''%' + @FirstTrimmed + ''''    

 ELSE IF  @FirstOperation = 'Is Equal To'    

  SET @FirstWhere = ' RTRIM(LTRIM(First)) = ''' + @FirstTrimmed + ''''        

   

 END  

   

 IF (IsNull(@Last,'') <> '')   

 BEGIN   
    DECLARE @LastTrimmed varchar(20)
  SET @LastTrimmed = RTRIM(LTRIM(@Last))
  IF  @LastOperation = 'Begins With'    

  SET @LastWhere = ' RTRIM(LTRIM(Last)) Like ''' + @LastTrimmed + '%'''    

 ELSE IF  @LastOperation = 'Contains'    

  SET @LastWhere = ' RTRIM(LTRIM(Last)) Like ''%' + @LastTrimmed + '%'''    

 ELSE IF  @LastOperation = 'Ends With'    

  SET @LastWhere = ' RTRIM(LTRIM(Last)) Like ''%' + @LastTrimmed + ''''    

 ELSE IF  @LastOperation = 'Is Equal To'    

  SET @LastWhere = ' RTRIM(LTRIM(Last)) = ''' + @LastTrimmed + ''''        

 END  

   

 IF (IsNull(@SSN,'') <> '')   

 BEGIN   
 DECLARE @SSNTrimmed varchar(20)
  SET @SSNTrimmed = RTRIM(LTRIM(@SSN))
  IF  @SSNOperation = 'Begins With'    

  SET @SSNWhere = 'replace(RTRIM(LTRIM(SSN)),''-'','''') Like ''' + replace(@SSNTrimmed,'-','') + '%'''    

 ELSE IF  @SSNOperation = 'Contains'    

  SET @SSNWhere = 'replace(RTRIM(LTRIM(SSN)),''-'','''') Like ''%' + replace(@SSNTrimmed,'-','') + '%'''    

 ELSE IF  @SSNOperation = 'Ends With'    

  SET @SSNWhere = 'replace(RTRIM(LTRIM(SSN)),''-'','''') Like ''%' + replace(@SSNTrimmed,'-','') + ''''    

 ELSE IF  @SSNOperation = 'Is Equal To'    

  SET @SSNWhere = 'replace(RTRIM(LTRIM(SSN)),''-'','''') = ''' + replace(@SSNTrimmed,'-','') + ''''       

 END  

   

 IF (IsNull(@CLNO,'') <> '')   

 BEGIN     

  

  IF  @CLNOOperation = 'Begins With'    

  SET @CLNOWhere = @clientParam + ' Like ''' + Cast(@CLNO as varchar) + '%'''    

 ELSE IF  @CLNOOperation = 'Contains'    

  SET @CLNOWhere = @clientParam + ' Like ''%' + Cast(@CLNO as varchar) + '%'''    

 ELSE IF  @CLNOOperation = 'Ends With'    

  SET @CLNOWhere = @clientParam + ' Like ''%' + Cast(@CLNO as varchar) + ''''    

 ELSE IF  @CLNOOperation = 'Is Equal To'    

  SET @CLNOWhere = @clientParam + ' = ' + @CLNO + ''      

 END  

   

 --IF (IsNull(@Param,'') <> '')   

 --BEGIN   

 -- if (@Param = 'Clients CAM') Set @Param = 'A.UserID'    

 -- if (@Param = 'ElapseDays') Set @Param = 'DATEDIFF(day, A.ApDate, getdate())'  

 -- If (@Param = 'Application#') set @Param = 'A.Apno'

 -- If (@Param = 'Status') set @Param='A.ApStatus'

 -- If (@Param = 'Data Entry Specialist') set @Param = 'EnteredBy'

 -- If (@Param = 'DOB') 

 -- Begin

	--If (@ParamOperation = 'Begins With' or @ParamOperation = 'Contains' or @ParamOperation = 'Ends With')

	--	Set @ParamOperation = 'Is Equal To'

    

	--If (@ParamOperation = 'Is Equal To')

	--	SET @ParamWhere = 'convert(varchar,A.DOB,101) = ''' + @ParamValue + ''''    

	--If (@ParamOperation = 'Is Greater Than')

	--	Set @ParamWhere = 'A.DOB > cast(''' + @ParamValue + ''' as datetime)' 

	--If (@ParamOperation = 'Is Less Than')

	--	--Set @ParamWhere = 'convert(varchar,A.DOB,101) < ''' + @ParamValue + ''''     

	--	Set @ParamWhere = 'A.DOB < cast(''' + @ParamValue + ''' as datetime)' 

 -- End

  

 -- ELSE

 -- --    SET @ParamWhere = 'convert(varchar,A.DOB,101) = ''' + @ParamValue + ''''      

 

 ----set @ParamWhere = 'DATEDIFF(day, A.ApDate, getdate()) = ' + @ParamValue     

 -- IF  @ParamOperation = 'Begins With'    

 -- SET @ParamWhere = @Param + ' Like ''' + @ParamValue + '%'''    

 --ELSE IF  @ParamOperation = 'Contains'    

 -- SET @ParamWhere = @Param + ' Like ''%' + @ParamValue + '%'''    

 --ELSE IF  @ParamOperation = 'Ends With'    

 -- SET @ParamWhere = @Param + ' Like ''%' + @ParamValue + ''''    

 --ELSE IF  @ParamOperation = 'Is Equal To'    

 -- SET @ParamWhere = @Param + ' = ''' + @ParamValue + ''''   

 --  ELSE IF  @ParamOperation = 'Is Greater Than'    

 -- SET @ParamWhere = @Param + ' > ''' + @ParamValue + ''''     

 --ELSE IF  @ParamOperation = 'Is Less Than'    

 -- SET @ParamWhere = @Param + ' < ''' + @ParamValue + ''''    

    

 --END  

           

   

  

  

if IsNull(@FirstWhere,'') <> ''  

  set @FirstWhere = @FirstWhere + ' ' + @FirstComparison  

    

if IsNull(@LastWhere,'') <> ''  

  set @LastWhere = @LastWhere + ' ' + @LastComparison  

    

if IsNull(@SSNWhere,'') <> ''  

  set @SSNWhere = @SSNWhere + ' ' + @SSNComparison  

    

if IsNull(@CLNOWhere,'') <> ''  

  set @CLNOWhere = @CLNOWhere + ' ' + @CLNOComparison   

  

--if IsNull(@ParamWhere,'') <> ''  

--  set @ParamWhere = @ParamWhere + ' ' + @ParamComparison     

        

--set @totalWhere = ' 1 =1 '   

  

--if (charindex('Data Entry',@EnteredVia) > 0)

-- set @totalWhere =  '  (EnteredVia = ''DEMI'' or IsNull(EnteredVia,'''') = '''') and '    

--else if @EnteredVia <> 'All'  

--	set @totalWhere =  '  Lower(EnteredVia) = ''' + Lower(@EnteredVia) + ''' and '  

--else

--	set @totalWhere = ''   





set @totalWhere = IsNull(@totalWhere,'') +  IsNull(@FirstWhere,'') + ' ' + IsNull(@LastWhere,'') + ' ' + IsNull(@SSNWhere,'') + ' ' + IsNull(@CLNOWhere,'') --+ ' ' + IsNull(@ParamWhere,'')   

  

   

--select @totalWhere  

declare @temp varchar(10)  

  

set @temp = RIGHT(RTRIM(LTRIM(@totalWhere)),3)   

--select @temp  

if RTRIM(LTRIM(@temp)) = 'or' or RTRIM(LTRIM(@temp)) = 'and'  

Begin  

 Set @totalWhere = LEFT(@totalWhere,Len(@totalWhere) - 3)   

End  






if @PDFOnly = 0

BEGIN

 If (IsNull(@totalWhere,'') <> '')

	 BEGIN    

	 --SET @SQL = @SQL + ' DISTINCT ReleaseFormId, IsNull(SSN,'''') as SSN,IsNull(First,'''') as First,IsNull(Last,'''') as Last,CLNO,Date    

	 --  FROM dbo.ReleaseForm rf with (NOLOCK) join dbo.Appl a with (NOLOCK) on Replace(rf.SSN,'-','') = Replace(a.SSN,'-','')

	 --  JOIN dbo.Client c with (NOLOCK) on a.CLNO = c.CLNO

	 --  WHERE ' + @totalWhere + ' Order by date desc'   

	   SET @SQL = @SQL + ' ReleaseFormId,IsNull(rf.SSN,'''') as SSN,IsNull(rf.First,'''') as First,IsNull(rf.Last,'''') as Last,rf.CLNO,c.Name as ClientName,rf.Date as Date

	   FROM dbo.ReleaseForm rf 

	   inner JOIN dbo.Client c  on rf.CLNO = c.CLNO

		WHERE ' + @totalWhere + 

		--' Group by ReleaseFormId,rf.SSN,rf.First,rf.Last,rf.CLNO,c.Name,rf.Date

		' Order by rf.Date desc'   

	 END

 ELSE

	 BEGIN

	  SET @SQL = @SQL + ' ReleaseFormId,IsNull(rf.SSN,'''') as SSN,IsNull(rf.First,'''') as First,IsNull(rf.Last,'''') as Last,rf.CLNO,c.Name as ClientName,rf.Date as Date

	   FROM dbo.ReleaseForm rf    

	   JOIN dbo.Client c  on rf.CLNO = c.CLNO

	   Group by ReleaseFormId,rf.SSN,rf.First,rf.Last,rf.CLNO,c.Name,rf.Date

	   Order by rf.Date desc'   

	  --SET @SQL = @SQL + ' ReleaseFormId, IsNull(SSN,'''') as SSN,IsNull(First,'''') as First,IsNull(Last,'''') as Last,CLNO,Date    

	  -- FROM dbo.ReleaseForm with (NOLOCK) Order by date desc'   

	 END



  

 

   
   --moved count query from here to handle archive lookup based on condition - schapyala 11/23/2015


END 

else -- @PDFOnly = 1
	Begin 
		If @AuthOnly = 0
			Set  @SQL = @SQL + ' isnull(ApplicantInfo_pdf,pdf) as pdf, SSN '
		else
			Set  @SQL = @SQL + ' pdf , SSN '

	   Set  @SQL = @SQL + ' FROM dbo.ReleaseForm rf    

		   JOIN dbo.Client c  on rf.CLNO = c.CLNO 

		WHERE ' + @totalWhere +    

	   ' Order by rf.Date desc' 
	End
   
	
	 declare @countsql varchar(1000)  
	 declare @tmpcount table (counts int)

	 if (IsNull(@totalWhere,'') <> '')
		set @countsql =  'select count(1) as Count 
		FROM dbo.ReleaseForm  rf   inner JOIN dbo.Client c  on rf.CLNO = c.CLNO	
		WHERE ' + @totalWhere    
	 else
		set @countsql =  'select count(1) as Count  
		FROM dbo.ReleaseForm '  	

	insert @tmpcount
	exec (@countsql)

	if (Select counts from @tmpcount) = 0 --check if release exists in the primary. if not, the system switches over to check in the archive
	Begin
		set @countsql  =  replace(@countsql,'dbo.ReleaseForm','Precheck_MainArchive.dbo.ReleaseForm_Archive')
		Set @SQL = replace(@SQL,'dbo.ReleaseForm','Precheck_MainArchive.dbo.ReleaseForm_Archive')
	End

		
        

 --print @countsql

 if (@DebugQ = 1)

 begin

	--select @SQL as QueryDebug

	print @SQL

 end

 else

 execute (@SQL) 

 execute (@countsql) 

 

 --execute @SQL  

--END 



SET NOCOUNT OFF

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END 