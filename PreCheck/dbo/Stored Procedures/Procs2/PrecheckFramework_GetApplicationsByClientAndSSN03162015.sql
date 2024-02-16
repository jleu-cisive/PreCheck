--dbo.PrecheckFramework_GetApplicationsByClientAndSSN 2270,'239-67-6921','','',0,0
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN 3068,'111-11-1111','','',0, 1140655
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN 2223,'','Lopez','Lillian',0,0
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN 2223,'','Test','Test',0, 0
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN '','633-50-3167','','',1, 1234
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN '','528065102','','',1
--dbo.PrecheckFramework_GetApplicationsByClientAndSSN '','','','',1

--select * from dbo.Appl with (nolock) where Replace(SSN,'-','') = '528065102' and Apdate >= DateAdd(m,-1,Current_TimeStamp) or First = 'Tami' and Last='Hirschi'
-- update dbo.Appl set SSN = '528-06-5103' where apno = 2281625
--Select DateAdd(m,-1,Current_TimeStamp)
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

create PROCEDURE [dbo].[PrecheckFramework_GetApplicationsByClientAndSSN03162015]
	-- Add the parameters for the stored procedure here
	@clno int = null,
	@ssn varchar(11),
	@lastname varchar(50) = '',
	@firstname varchar(50) = '',
	@includehistory bit = 0,
	@apno int = null
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	Declare @CutOffDate Date, @historycount1 int, @historycount2 int, @historycount3 int
    --==========================================================================================================
    Select @CutOffDate = DateAdd(m,-1,Current_TimeStamp) --Modify if business needs to change timeframe
	--if @apno = 0 
	--SET @apno = null
   IF @includehistory = 0
	BEGIN
   --==========================================================================================================
   if(len(isnull(REPLACE(@ssn, '-', ''), '')) = 9)
   BEGIN
   SELECT A.APNO, A.ApDate, A.Last, A.First, A.ApStatus, C.Name,cast(0 as Bit) HasMoreHistory 
	  FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
	 WHERE REPLACE(A.SSN,'-','') = REPLACE(@ssn, '-', '') 
	   AND C.CLNO = @clno
	   AND A.APNO <> @apno
	   AND len(@ssn) > 0 
	   AND cast(A.ApDate as Date) >= @CutOffDate 
	END
	ELSE
	BEGIN
	SELECT * FROM
    (
		--==========================================================================================================
	SELECT A.APNO, A.ApDate, A.Last, A.First, A.ApStatus, C.Name,cast(0 as Bit) HasMoreHistory 
	FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
	WHERE RTRIM(LTRIM(lower(A.Last))) = lower(@lastname) and RTRIM(LTRIM(lower(A.First))) = lower(@firstname) 
      AND  C.CLNO = @clno
      AND A.APNO <> @apno
      AND  cast(A.ApDate as Date) >= @CutOffDate 
	UNION
	--==========================================================================================================
	SELECT A.APNO, A.ApDate, A.Last, A.First, A.ApStatus, C.Name,cast(0 as Bit) HasMoreHistory 
      FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
     WHERE RTRIM(LTRIM(lower(A.Last))) = lower(@firstname) and RTRIM(LTRIM(lower(A.First))) =lower(@lastname)
	   AND C.CLNO = @clno
	   AND A.APNO <> @apno
	   AND cast(A.ApDate as Date) >= @CutOffDate )B
    
    ORDER BY B.APNO DESC
	END
	---=====================================================================================================
	END
    ELSE
    	BEGIN
		    if @apno = 0 
	        SET @apno = null
    	    SELECT  A.APNO AS APNO, A.ApDate AS ApDate, A.Last AS [Last], A.First AS [First], A.ApStatus AS ApStatus, C.Name AS [Name], 0 HasMoreHistory --INTO #tmp1
	          FROM dbo.Appl A INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
	         WHERE REPLACE(A.SSN,'-','') = REPLACE(@ssn, '-', '') 
	           AND C.CLNO <> 0 
	           AND C.CLNO <> 3468
	           AND C.CLNO <> 2135
	           AND LEN(A.First) > 0
	           AND LEN(A.Last) > 0
	           AND A.APNO <> @apno
	           AND len(@ssn) > 0 
	        ORDER BY A.APNO DESC       
             
	 
	  
	      --SELECT 0 APNO, null ApDate, 'History' Last, 'History' First, 'P' ApStatus, 'History' Name,Case When isnull(@@ROWCOUNT,0)>0 then cast(1 as bit) else cast(0 as bit) end HasMoreHistory
	     
	          
	
			--Select @historycount = count(1) 
			--From dbo.Appl A
			--WHERE (REPLACE(A.SSN,'-','') = REPLACE(@ssn, '-', '')
					
			--Select @historycount = count(1) 
			--From dbo.Appl A
			--WHERE RTRIM(LTRIM(lower(A.Last))) = lower(@lastname) and RTRIM(LTRIM(lower(A.First))) = lower(@firstname) 
			
			--Select @historycount = count(1) 
			--From dbo.Appl A
			--WHERE RTRIM(LTRIM(lower(A.Last))) = lower(@firstname) and RTRIM(LTRIM(lower(A.First))) = lower(@lastname)				
					
			--Insert into #tmp1

			--SELECT 0 APNO, null ApDate, 'History' Last, 'History' First, 'P' ApStatus, 'History' Name,Case When isnull('1',0)>0 then cast(1 as bit) else cast(0 as bit) end HasMoreHistory
    	    
    	    --SELECT @historycount1 = count(1) FROM #tmp1
    	    --SELECT @historycount2 = count(2) FROM #tmp2
    	    --SELECT @historycount3 = count(3) FROM #tmp3
    	    
    	    --if(@historycount1 + @historycount2 + @historycount3 >1)
    	    --      INSERT INTO #tmp1
    	  	 --     SELECT 0 APNO, null ApDate, 'History' Last, 'History' First, 'P' ApStatus, 'History' Name, cast(1 as bit)  HasMoreHistory

	        --SELECT APNO,ApDate,Last,First,ApStatus,Name,HasMoreHistory FROM #tmp1
	        --UNION
	        --SELECT APNO,ApDate,Last,First,ApStatus,Name,HasMoreHistory FROM #tmp2
	        --UNION
	        --SELECT APNO,ApDate,Last,First,ApStatus,Name,HasMoreHistory FROM #tmp3
	        
	        --IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
         --   BEGIN
         --   DROP TABLE #tmp1
         --   END
         --   IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL
         --   BEGIN
         --   DROP TABLE #tmp2
         --   END
         --   IF OBJECT_ID('tempdb..#tmp3') IS NOT NULL
         --   BEGIN
         --   DROP TABLE #tmp3
         --   END
	        
	END
END
