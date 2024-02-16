	
-- =============================================
-- Created By: Santosh Chapyala
-- Date: 05/17/2017
-- Description: This report provides the historical perspective of orders for a given client within a stipulated period of time
-- =============================================
-- EXEC [ClientAccess_DrugTestStatusReportByClient] 7519,0,null,null,null,null,268118,3789677,1

  CREATE PROCEDURE [dbo].[ClientAccess_DrugTestStatusReportByClient]
   (@CLNO INT = 7519,
    @NumberOfDays INT = 0,
	@IsOneHR BIT = NULL,
	@LastName VARCHAR(50)=null,
	@FirstName VARCHAR(50)=null,
	@SSN VARCHAR(11)=NULL,
	@TID INT = NULL,
	@APNO INT = NULL,
	@CurrentStatusRecord Bit = 0)
  AS
  BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  -- Step 1: Execute the stored procedure.
  -- This is to update the link expirations right before the 
  -- client report is generated. Without this, it is dependent on a transaction for this to be updated.
	IF @CurrentStatusRecord =1 
	BEGIN 
			SELECT DISTINCT R.CLNO, R.LastName, R.FirstName, Middle, OrderIDOrApno OrderID_Or_Apno, CostCenter,
			 Division,  ClientFacilityGroup, ClientIdent, C.CreatedDate,  ExpirationDate, 
			(CASE WHEN RTRIM(LTRIM(TestResult)) = 'x:Expired' THEN 'Passport Expired' ELSE OrderStatus END) as 'OrderStatus', 
			LastUpdate StatusDate,OCHS_CandidateInfoScheduleByName  ScheduledByName,COC,ReasonforTest,TestResultDate,TestResult ,TID
			FROM OCHS_ResultDetails R Left join OCHS_CandidateInfo C on (R.OrderIDOrApno = cast(apno as varchar) or R.OrderIDOrApno = cast(OCHS_candidateInfoId as varchar))
			LEFT JOIN Hevn..Facility F ON C.CostCenter=F.FacilityNum AND F.ParentEmployerID=R.CLNO 
			LEFT JOIN dbo.OCHS_CandidateSchedule CS ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
			LEFT JOIN dbo.refOCHS_CandidateInfoSchedule CSref ON CS.ScheduledByID = CSref.refOCHS_CandidateInfoScheduleByID  
			Where TID = @TID	
	END
	ELSE
	BEGIN
	/*Modified By: Gaurav 
			Modified Date: 5/15/2019
			Modification Reason: The procedure 'DBO.DrugTestStatusUpdate_LinkExpirations' is executed through new SSIS job (JobMaster) 
			every 5 mins. The need for calling it as/on event should not exist any more.
	*/
		--EXEC DBO.DrugTestStatusUpdate_LinkExpirations

	  --Step 2: Create a Temp Table #tmpResults 
		DECLARE @CutOffDate DATE,@OrderID VARCHAR(25) = null

		IF @APNO IS NOT NULL
			SELECT @LastName = [Last], @FirstName = [First], @SSN = SSN
			FROM dbo.APPL
			WHERE APNO = @APNO

		IF @TID IS NOT NULL
			SELECT @OrderID = OrderIDOrApno,  @SSN = Case When @SSN is NULL then SSNOrOtherID else @SSN END,@LastName = Case When @LastName is NULL then LastName else @LastName END,@FirstName = Case When @FirstName is NULL then FirstName else @FirstName END
			FROM dbo.OCHS_ResultDetails
			WHERE TID = @TID

		IF @CLNO = 7519 AND ISNULL(@IsOneHR,1) = 1
			SET @IsOneHR = 1
		ELSE
			SET @IsOneHR = 0

		IF @NumberOfDays >0 
			SET @CutOffDate = DATEADD(DAY,-@NumberOfDays,CAST(CURRENT_TIMESTAMP AS DATE))
		ELSE
			SET @CutOffDate = null

		--SELECT @CutOffDate


		CREATE TABLE #tmpResults (RowID INT,CLNO int, LastName varchar(50), FirstName varchar(50), Middle varchar(20),  ClientIdent varchar(100), CostCenter varchar(50),
							CreatedDate datetime, ExpirationDate datetime, ScheduledByID INT,TID  INT,OrderIDOrApno VARCHAR(25),
							OrderStatus varchar(25), StatusDate datetime, TestResult varchar(25),CandidateID int, APNO INT,SSNorOtherID VARCHAR(25),COC VARCHAR(25),ReasonforTest VARCHAR(25),TestResultDate DATETIME)

		INSERT INTO #tmpResults
		SELECT row_number() over (order by CreatedDate ) ,* FROM (
		SELECT C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,MAX(CS.CreatedDate) AS CreatedDate ,MAX(CS.ExpirationDate) AS ExpirationDate ,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus,MAX(R.LastUpdate) LastUpdate, R.TestResult,c.OCHS_CandidateInfoID,c.APNO ,R.SSNOrOtherID,MAX(R.CoC) COC,MAX(R.ReasonForTest) ReasonForTest,MAX(R.TestResultDate) TestResultDate
		FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C 
		LEFT JOIN dbo.OCHS_CandidateSchedule CS ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
		LEFT JOIN dbo.OCHS_ResultDetails R ON (CAST(C.OCHS_CandidateInfoID AS VARCHAR(25)) =  R.OrderIDOrApno)
		Where  ISNULL(orderIDOrApno,'0') <> '0'AND
		 (CAST(ISNULL(LastUpdate,'1/1/1900') AS DATETIME) >= @CutOffDate OR @CutOffDate IS NULL)
		GROUP BY C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus, R.TestResult,c.OCHS_CandidateInfoID,c.APNO ,R.SSNOrOtherID
		UNION ALL
		SELECT C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,MIN(CS.CreatedDate) AS CreatedDate,MIN(CS.ExpirationDate) AS ExpirationDate,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus,MIN(R.LastUpdate) LastUpdate, R.TestResult,MIN(c.OCHS_CandidateInfoID) OCHS_CandidateInfoID,c.APNO ,R.SSNOrOtherID,MIN(R.CoC) COC,MIN(R.ReasonForTest) ReasonForTest,MIN(R.TestResultDate)  TestResultDate
		FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C 
		LEFT JOIN dbo.OCHS_CandidateSchedule CS ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
		LEFT JOIN dbo.OCHS_ResultDetails R ON (CAST(C.apno AS VARCHAR(25)) =  R.OrderIDOrApno)
		Where   ISNULL(orderIDOrApno,'0') <> '0' AND
		(CAST(ISNULL(LastUpdate,'1/1/1900') AS DATETIME) >= @CutOffDate OR @CutOffDate IS NULL)  
		GROUP BY C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus, R.TestResult,c.APNO ,R.SSNOrOtherID
		) Qry
		Where  ( 
				((LastName = @LastName or  @LastName IS NULL) AND   (FirstName= @FirstName or @FirstName IS NULL) AND ((RIGHT(Qry.SSNOrOtherID,4) = CASE WHEN @SSN IS NULL THEN	'' ELSE	RIGHT(@SSN,4) END) OR (REPLACE(Qry.SSNOrOtherID,'-','') = REPLACE(@SSN,'-','') OR @SSN IS NULL  )))
				OR (REPLACE(Qry.SSNOrOtherID,'-','') = REPLACE(@SSN,'-','') AND @SSN IS NOT NULL  )
				OR (Qry.SSNOrOtherID LIKE ('0%' + @OrderID) AND @OrderID IS NOT NULL)
				OR (Qry.OrderIDOrApno = @OrderID  AND @OrderID IS NOT NULL)
				OR (Qry.OrderIDOrApno = @APNO  AND @APNO IS NOT NULL)
			  )

		--SELECT 0,* FROM #tmpResults

		--Only return the latest status records per Order per candidate
		DELETE #tmpResults WHERE TID NOT  IN (SELECT MAX(TID) FROM #tmpResults GROUP BY OrderIDOrApno)

		--SELECT 1,* FROM #tmpresults

		CREATE TABLE #tmpMain (RowID INT,CLNO int, LastName varchar(50), FirstName varchar(50), Middle varchar(20), OrderID_Or_Apno varchar(25), CostCenter varchar(50),
			Division varchar(50), ClientFacilityGroup varchar(50), ClientIdent varchar(100), CreatedDate datetime, ExpirationDate datetime, 
			OrderStatus varchar(25), StatusDate datetime, TestResult varchar(25), ScheduledByName varchar(50),CandidateID int, APNO int,COC VARCHAR(25),ReasonforTest VARCHAR(25),TestResultDate DATETIME,TID INT)

		INSERT INTO #tmpMain
		SELECT DISTINCT  RowID,
		C.CLNO,C.LastName,C.FirstName,C.Middle,
		C.OrderIDOrApno  OrderID_Or_Apno,
		C.CostCenter PL,F.Division,F.ClientFacilityGroup,C.ClientIdent,C.CreatedDate,C.ExpirationDate LinkExpirationDate,
		 OrderStatus,  StatusDate, TestResult,
		CSref.OCHS_CandidateInfoScheduleByName ScheduledBy,c.CandidateID,c.APNO,C.COC,C.ReasonforTest,C.TestResultDate,C.TID
		FROM  #tmpResults C
		LEFT JOIN Hevn..Facility F ON C.CostCenter=F.FacilityNum AND F.ParentEmployerID=@CLNO
		LEFT JOIN dbo.refOCHS_CandidateInfoSchedule CSref ON C.ScheduledByID = CSref.refOCHS_CandidateInfoScheduleByID
		WHERE ( (C.CLNO IN (SELECT F1.FacilityCLNO FROM HEVN..Facility F1 WHERE ISNULL(F1.IsOneHR,0)=@IsOneHR AND ISNULL(F.ParentEmployerID,@CLNO) = @CLNO)  AND ISNULL(F.IsOneHR,0)=@IsOneHR)
		OR (C.clno =@CLNO)
		OR (@IsOneHR =0 AND C.CLNO IN (SELECT CLNO FROM Client WHERE WebOrderParentCLNO =  @CLNO) )
		) 

		--BEGIN --ReOrders typically are based on OCHS_CandidateID and not the APNO. This logic will handle any reorders done in the old way where APNO was inserted as ORderid
		DECLARE @tmpReorders TABLE (RowID INT,APNO INT)
	
		INSERT INTO @tmpReorders
		SELECT MIN(RowID) RowID,OrderID_Or_Apno 
		FROM #tmpMain 
		GROUP BY OrderID_Or_Apno HAVING COUNT(1)>1

		-- SELECT 4,* FROM #tmpReorders
		IF (SELECT COUNT(1) FROM @tmpReorders)>0
		BEGIN	
			UPDATE #tmpMain SET APNO = 0 
			WHERE RowID not IN (SELECT RowID FROM @tmpReorders) 
			AND APNO IN (SELECT APNO FROM @tmpReorders)

			UPDATE M SET OrderStatus = t.OrderStatus,StatusDate=t.StatusDate,TestResult = t.TestResult,M.OrderID_Or_Apno=CASE WHEN M.APNO =0 THEN M.candidateID ELSE M.APNO END,M.TestResultDate = t.TestResultDate,M.COC = t.COC,m.ReasonforTest = t.ReasonforTest
			--SELECT DISTINCT *
			FROM #tmpMain M INNER JOIN #tmpresults t ON CAST(M.CandidateID AS VARCHAR) = t.OrderIDOrApno AND M.Apno=0 

			--UPDATE M SET OrderStatus = t.OrderStatus,StatusDate=t.StatusDate,TestResult = t.TestResult,M.OrderID_Or_Apno =CASE WHEN M.APNO =0 THEN M.candidateID ELSE M.APNO end
			----SELECT *
			--FROM #tmpMain M INNER JOIN #tmpresults t ON  CAST(M.APNO AS VARCHAR) = t.OrderIDOrApno  AND  M.APNO >0
		END
	--END --ReOrders typically are based on OCHS_CandidateID and not the APNO. This logic will handle any reorders done in the old way where APNO was inserted as ORderid

		IF @TID IS NULL AND @APNO IS NULL
			SELECT DISTINCT CLNO, LastName, FirstName, Middle, OrderID_Or_Apno, CostCenter,
			Division, ClientFacilityGroup, ClientIdent, CreatedDate, ExpirationDate, 
			(CASE WHEN RTRIM(LTRIM(TestResult)) = 'x:Expired' THEN 'Passport Expired' ELSE OrderStatus END) as 'OrderStatus', 
			StatusDate, ScheduledByName 
			FROM #tmpMain  
			WHERE ISNULL(OrderID_Or_Apno,'')<>''
			ORDER BY StatusDate, LastName,firstname,expirationDate
		ELSE
			SELECT DISTINCT CLNO, LastName, FirstName, Middle, OrderID_Or_Apno, CostCenter,
			Division, ClientFacilityGroup, ClientIdent, CreatedDate, ExpirationDate, 
			(CASE WHEN RTRIM(LTRIM(TestResult)) = 'x:Expired' THEN 'Passport Expired' ELSE OrderStatus END) as 'OrderStatus', 
			StatusDate, ScheduledByName,COC,ReasonforTest,TestResultDate,TestResult ,TID
			FROM #tmpMain  
			WHERE ISNULL(OrderID_Or_Apno,'')<>''
			ORDER BY StatusDate, LastName,firstname,expirationDate    

		DROP TABLE #tmpMain
		DROP TABLE #tmpresults
	END

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END
