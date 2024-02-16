
--[dbo].[PrecheckFramework_GetApplicationByFilter] @RecordLimit='1000',@Last='Shade''',@ClientOperation='Contains',@DebugQ=0
--@first = 'Doug',@firstoperation='Begins With',@EnteredVia='XML',


-- =============================================  
-- Author:  Douglas DeGenaro  
-- Create date: 10/12/2012  
-- Description: procedure to get application information by filters  
-- =============================================  
CREATE PROCEDURE [dbo].[PrecheckFramework_GetApplicationByFilter]  
 -- Add the parameters for the stored procedure here  
  @RecordLimit varchar(30) = '100'   
 ,@First varchar(20) = null  
 ,@FirstOperation varchar(30) = 'Begins With'   
 ,@FirstComparison varchar(10) = 'and'  
  
 ,@Last varchar(20) = null  
 ,@LastOperation varchar(30) = 'Begins With'   
 ,@LastComparison varchar(10) = 'and'  
  
, @SSN varchar(20) = null  
, @SSNOperation varchar(30) = 'Is Equal To'  
, @SSNComparison varchar(10) = 'and'  
  
, @Client varchar(20) = null  
, @ClientOperation varchar(30) = 'Contains'  
, @ClientComparison varchar(10) = 'and'  
  
, @Param varchar(100) = null  
, @ParamValue varchar(100) = null  
, @ParamOperation varchar(30) = 'Is Equal To'  
, @ParamComparison varchar(10) = 'and'  
, @EnteredVia varchar(30) = 'All' 
,@DebugQ bit = 0 
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  --[PrecheckFramework_GetApplicationByFilter_20121114]  @DebugQ = 1 
  
  
declare @FirstWhere varchar(100)  
declare @LastWhere varchar(100)  
declare @SSNWhere varchar(100)  
declare @ClientWhere varchar(100)  
declare @ParamWhere varchar(100)  
declare @totalWhere varchar(1000)  
declare @Sql varchar(1000)  
declare @countsql varchar(1000)  
declare @clientParam varchar(10)

IF (ISNULL(@Client,'') <> '')
	BEGIN
		--IF (ISNUMERIC(@Client) = 0) 
		IF TRY_PARSE(@Client as int) IS NULL  --@Client is not numeric
			BEGIN
				SET @clientParam = ' c.Name '
			END	
		ELSE  --@Client is numeric
			BEGIN
				SET @clientParam = ' A.CLNO '
				SET @ClientOperation = 'Is Equal To' 
			END
	
	END
  
--if (IsNull(@First,'') = '' and IsNull(@Last,'') = '' and IsNull(@SSN,'') = '' and IsNull(@ParamValue,'') = '' and IsNull(@Client,'') = '')
--Begin	
	--select 
	--select 0 as Count 
--end
--else
--BEGIN
--IF @RecordLimit <> '' AND @RecordLimit <> 'All'    
SET @SQl = 'SELECT TOP ' + @RecordLimit    
-- ELSE    
--  SET @SQL = 'SELECT'    
   
 IF (IsNull(@First,'') <> '')   
 BEGIN 
 Set @First = Replace(@First,'''','''''')  
  IF  @FirstOperation = 'Begins With'    
  SET @FirstWhere = ' A.First Like ''' + @First + '%'''    
 ELSE IF  @FirstOperation = 'Contains'    
  SET @FirstWhere = ' A.First Like ''%' + @First + '%'''    
 ELSE IF  @FirstOperation = 'Ends With'    
  SET @FirstWhere = ' A.First Like ''%' + @First + ''''    
 ELSE IF  @FirstOperation = 'Is Equal To'    
  SET @FirstWhere = ' A.First = ''' + @First + ''''        
   
 END  
   
 IF (IsNull(@Last,'') <> '')   
 BEGIN   
  Set @Last = Replace(@Last,'''','''''')    
  IF  @LastOperation = 'Begins With'    
  SET @LastWhere = 'A.Last Like ''' + @Last + '%'''    
 ELSE IF  @LastOperation = 'Contains'    
  SET @LastWhere = 'A.Last Like ''%' + @Last + '%'''    
 ELSE IF  @LastOperation = 'Ends With'    
  SET @LastWhere = 'A.Last Like ''%' + @Last + ''''    
 ELSE IF  @LastOperation = 'Is Equal To'    
  SET @LastWhere = 'A.Last = ''' + @Last + ''''        
 END  
   
 IF (IsNull(@SSN,'') <> '')   
 BEGIN   
  IF  @SSNOperation = 'Begins With'    
  SET @SSNWhere = 'replace(A.SSN,''-'','''') Like ''' + replace(@SSN,'-','') + '%'''    
 ELSE IF  @SSNOperation = 'Contains'    
  SET @SSNWhere = 'replace(A.SSN,''-'','''') Like ''%' + replace(@SSN,'-','') + '%'''    
 ELSE IF  @SSNOperation = 'Ends With'    
  SET @SSNWhere = 'replace(A.SSN,''-'','''') Like ''%' + replace(@SSN,'-','') + ''''    
 ELSE IF  @SSNOperation = 'Is Equal To'    
  SET @SSNWhere = 'replace(A.SSN,''-'','''') = ''' + replace(@SSN,'-','') + ''''       
 END  
   
 IF (IsNull(@Client,'') <> '')   
 BEGIN    
  Set @Client = Replace(@Client,'''','''''')
  IF  @ClientOperation = 'Begins With'    
  SET @ClientWhere = @clientParam + ' Like ''' + @Client + '%'''    
 ELSE IF  @ClientOperation = 'Contains'    
  SET @ClientWhere = @clientParam + '  Like ''%' + @Client + '%'''    
 ELSE IF  @ClientOperation = 'Ends With'    
  SET @ClientWhere = @clientParam + '  Like ''%' + @Client + ''''    
 ELSE IF  @ClientOperation = 'Is Equal To'    
  SET @ClientWhere = @clientParam + '  = ''' + @Client + ''''      
 END  
   
 IF (IsNull(@Param,'') <> '')   
 BEGIN   
  if (@Param = 'Clients CAM') Set @Param = 'A.UserID'    
  if (@Param = 'ElapseDays') Set @Param = 'DATEDIFF(day, A.ApDate, getdate())'  
  If (@Param = 'Application#') set @Param = 'A.Apno'
  If (@Param = 'Status') set @Param='A.ApStatus'
  If (@Param = 'Data Entry Specialist') set @Param = 'EnteredBy'
  If (@Param = 'DOB') 
  Begin
	Set @ParamValue = Replace(@ParamValue,'''','''''')
	If (@ParamOperation = 'Begins With' or @ParamOperation = 'Contains' or @ParamOperation = 'Ends With')
		Set @ParamOperation = 'Is Equal To'
    
	If (@ParamOperation = 'Is Equal To')
		SET @ParamWhere = 'convert(varchar,A.DOB,101) = ''' + @ParamValue + ''''    
	If (@ParamOperation = 'Is Greater Than')
		Set @ParamWhere = 'A.DOB > cast(''' + @ParamValue + ''' as datetime)' 
	If (@ParamOperation = 'Is Less Than')
		--Set @ParamWhere = 'convert(varchar,A.DOB,101) < ''' + @ParamValue + ''''     
		Set @ParamWhere = 'A.DOB < cast(''' + @ParamValue + ''' as datetime)' 
  End
  
  ELSE
  --    SET @ParamWhere = 'convert(varchar,A.DOB,101) = ''' + @ParamValue + ''''      
 
 --set @ParamWhere = 'DATEDIFF(day, A.ApDate, getdate()) = ' + @ParamValue     
  IF  @ParamOperation = 'Begins With'    
  SET @ParamWhere = @Param + ' Like ''' + @ParamValue + '%'''    
 ELSE IF  @ParamOperation = 'Contains'    
  SET @ParamWhere = @Param + ' Like ''%' + @ParamValue + '%'''    
 ELSE IF  @ParamOperation = 'Ends With'    
  SET @ParamWhere = @Param + ' Like ''%' + @ParamValue + ''''    
 ELSE IF  @ParamOperation = 'Is Equal To'    
  SET @ParamWhere = @Param + ' = ''' + @ParamValue + ''''   
   ELSE IF  @ParamOperation = 'Is Greater Than'    
  SET @ParamWhere = @Param + ' > ''' + @ParamValue + ''''     
 ELSE IF  @ParamOperation = 'Is Less Than'    
  SET @ParamWhere = @Param + ' < ''' + @ParamValue + ''''    
    
 END  
           
   
 BEGIN    
  
if IsNull(@FirstWhere,'') <> ''  
  set @FirstWhere = @FirstWhere + ' ' + @FirstComparison  
    
if IsNull(@LastWhere,'') <> ''  
  set @LastWhere = @LastWhere + ' ' + @LastComparison  
    
if IsNull(@SSNWhere,'') <> ''  
  set @SSNWhere = @SSNWhere + ' ' + @SSNComparison  
    
if IsNull(@ClientWhere,'') <> ''  
  set @ClientWhere = @ClientWhere + ' ' + @ClientComparison   
  
if IsNull(@ParamWhere,'') <> ''  
  set @ParamWhere = @ParamWhere + ' ' + @ParamComparison     
        
--set @totalWhere = ' 1 =1 '   
  
if (charindex('Data Entry',@EnteredVia) > 0)
 set @totalWhere =  '  (EnteredVia = ''DEMI'' or IsNull(EnteredVia,'''') = '''') and '    
else if @EnteredVia <> 'All'  
	set @totalWhere =  '  Lower(EnteredVia) = ''' + Lower(@EnteredVia) + ''' and '  
else
	set @totalWhere = ''   
set @totalWhere = @totalWhere +  IsNull(@FirstWhere,'') + ' ' + IsNull(@LastWhere,'') + ' ' + IsNull(@SSNWhere,'') + ' ' + IsNull(@ClientWhere,'') + ' ' + IsNull(@ParamWhere,'')   
  
  
   
--select @totalWhere  
declare @temp varchar(10)  
  
set @temp = RIGHT(RTRIM(LTRIM(@totalWhere)),3)   
--select @temp  
if RTRIM(LTRIM(@temp)) = 'or' or RTRIM(LTRIM(@temp)) = 'and'  
Begin  
 Set @totalWhere = LEFT(@totalWhere,Len(@totalWhere) - 3)   
End  

SET @SQL = @SQL + ' IsNull(Investigator,'''') as Investigator,A.ApStatus,A.APNO,cast(A.DOB as varchar) DOB, A.ApDate ,cast(ReopenDate as varchar) as ReOpenDate,null as AvailableDate,a.EnteredBy as EnteredBy, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, Replace(A.Last,'''','''''''') as Last, Replace(A.First,'''','''''''') as First, Replace(C.Name,'''','''''''') AS ClientName, A.UserID AS ClientCAM    
   FROM dbo.Appl A (NOLOCK)     
   INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO '

set @countsql =  'select count(1) as Count  
   FROM dbo.Appl A (NOLOCK)     
   INNER JOIN dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO  '

 If (IsNull(@totalWhere,'') <> '')
 BEGIN    
   SET @SQL = @SQL +   ' WHERE ' + @totalWhere  
   SET @countsql = @countsql  +   ' WHERE ' + @totalWhere  
 END
 
SET @SQL = @SQL +  ' Order by A.ApDate desc' 
 
 END    
 
    
 
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
END 
