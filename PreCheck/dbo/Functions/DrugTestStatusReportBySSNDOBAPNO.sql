	
-- ===============================================================================
-- Created By: Dongmei He
-- Date: 01/23/2020
-- Description: copy from ClientAccess_DrugTestStatusReportByClient and modified
-- ===============================================================================
-- SELECT * FROM [DrugTestStatusReportBySSNDOBAPNO] ('Galicia','Katherine','625-74-5406',null,null)

  CREATE FUNCTION [dbo].[DrugTestStatusReportBySSNDOBAPNO]
   (@LastName VARCHAR(50)=null,
	@FirstName VARCHAR(50)=null,
	@SSN VARCHAR(11)=NULL,
	@TID INT = NULL,
	@APNO INT = NULL
	)
  RETURNS @Temp TABLE(TID INT, OrderStatus VARCHAR(50), 
  APNO INT, OrderId INT, FirstName VARCHAR(50), LastName VARCHAR(50), SSN VARCHAR(11), DOB DateTime)
  AS
  BEGIN
	
	BEGIN
	   -- DECLARE @OrderID VARCHAR(25) = null


		DECLARE @tmpResults TABLE(
		RowID INT,
		--CLNO int, 
		LastName varchar(50), 
		FirstName varchar(50), 
		Middle varchar(20),  
		--ClientIdent varchar(100), 
		--CostCenter varchar(50),
		CreatedDate datetime, 
		ExpirationDate datetime, 
		--ScheduledByID INT,
		TID  INT,
		OrderIDOrApno VARCHAR(25),
		OrderStatus varchar(25), 
		StatusDate datetime, 
		TestResult varchar(25),
		CandidateID int, 
		APNO INT,
		SSNorOtherID VARCHAR(25),
		COC VARCHAR(25),
		ReasonforTest VARCHAR(25),
		TestResultDate DATETIME
		)

		INSERT INTO @tmpResults
		SELECT row_number() over (order by CreatedDate ) ,* FROM (
		SELECT 
		       --C.CLNO,
		       C.LastName,
			   C.FirstName, 
			   C.Middle,
			   --C.ClientIdent,
			   --CostCenter,
			   MAX(CS.CreatedDate) AS CreatedDate ,
			   MAX(CS.ExpirationDate) AS ExpirationDate ,
			   --ScheduledByID,
			   TID,
			   R.OrderIDOrApno,
		       OrderStatus,
		       MAX(R.LastUpdate) LastUpdate, 
			   R.TestResult,
			   c.OCHS_CandidateInfoID,
			   c.APNO ,
			   R.SSNOrOtherID,
			   MAX(R.CoC) COC,
			   MAX(R.ReasonForTest) 
			   ReasonForTest,
			   MAX(R.TestResultDate) TestResultDate
		FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C 
		LEFT JOIN dbo.OCHS_CandidateSchedule CS ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
		LEFT JOIN dbo.OCHS_ResultDetails R ON (CAST(C.OCHS_CandidateInfoID AS VARCHAR(25)) =  R.OrderIDOrApno)
		Where  ISNULL(orderIDOrApno,'0') <> '0' 
		  AND  C.LastName = ISNULL(@LastName, C.LastName)
		  AND  C.FirstName= ISNULL(@FirstName,C.FirstName) 
		  AND (
		       RIGHT(R.SSNOrOtherID,4) = CASE WHEN @SSN IS NULL THEN	'' ELSE	RIGHT(@SSN,4) END 
				OR REPLACE(R.SSNOrOtherID,'-','') = ISNULL(REPLACE(@SSN,'-',''), REPLACE(R.SSNOrOtherID,'-',''))
				OR R.OrderIDOrApno = ISNULL(@APNO, R.OrderIDOrApno)
			  )
		GROUP BY C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus, R.TestResult,c.OCHS_CandidateInfoID,c.APNO ,R.SSNOrOtherID
		UNION ALL
		SELECT 
		    
			  C.LastName,
			  C.FirstName,
			  C.Middle,
			
			  MIN(CS.CreatedDate) AS CreatedDate,
			  MIN(CS.ExpirationDate) AS ExpirationDate,
		
			  TID,
			  R.OrderIDOrApno,
		      OrderStatus,
			  MIN(R.LastUpdate) LastUpdate, 
			  R.TestResult,
			  MIN(c.OCHS_CandidateInfoID) OCHS_CandidateInfoID,
			  c.APNO ,
			  R.SSNOrOtherID,
			  MIN(R.CoC) COC,
			  MIN(R.ReasonForTest) ReasonForTest,
			  MIN(R.TestResultDate)  TestResultDate
		FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C 
		LEFT JOIN dbo.OCHS_CandidateSchedule CS ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
		LEFT JOIN dbo.OCHS_ResultDetails R ON (CAST(C.apno AS VARCHAR(25)) =  R.OrderIDOrApno)
		WHERE   ISNULL(orderIDOrApno,'0') <> '0' 
		  AND 	C.LastName = ISNULL(@LastName, C.LastName) 
				AND C.FirstName = ISNULL(@FirstName, C.FirstName)

				AND (
				RIGHT(R.SSNOrOtherID,4) = CASE WHEN @SSN IS NULL THEN	'' ELSE	RIGHT(@SSN,4) END
				OR REPLACE(R.SSNOrOtherID,'-','') = ISNULl(REPLACE(@SSN,'-',''), REPLACE(R.SSNOrOtherID,'-',''))
				OR R.OrderIDOrApno = ISNUll(@APNO, R.OrderIDOrApno))
			

		GROUP BY C.CLNO,C.LastName,C.FirstName,C.Middle,C.ClientIdent,CostCenter,ScheduledByID,TID,R.OrderIDOrApno,
		OrderStatus, R.TestResult,c.APNO ,R.SSNOrOtherID

	
		) Qry


		
		--Only return the latest status records per Order per candidate
		DELETE @tmpResults WHERE TID NOT  IN (SELECT MAX(TID) FROM @tmpResults GROUP BY OrderIDOrApno)

		DECLARE @tmpMain TABLE (RowID INT,
		         --CLNO int, 
				 LastName varchar(50), 
				 FirstName varchar(50), 
				 Middle varchar(20), 
		         OrderID_Or_Apno varchar(25), 
				 --CostCenter varchar(50),
				 --ClientIdent varchar(100), 
				 CreatedDate datetime, 
				 ExpirationDate datetime, 
			     OrderStatus varchar(25), 
				 StatusDate datetime, 
				 TestResult varchar(25),
			     CandidateID int, 
				 APNO int,
				 COC VARCHAR(25),
				 ReasonforTest VARCHAR(25),
				 TestResultDate DATETIME,
				 TID INT
				 )

		INSERT INTO @tmpMain
		SELECT DISTINCT  RowID,
		                 --C.CLNO,
						 C.LastName,
						 C.FirstName,
						 C.Middle,
		                 C.OrderIDOrApno  OrderID_Or_Apno,
		                 --C.CostCenter PL,
		                -- C.ClientIdent,
						 C.CreatedDate,
						 C.ExpirationDate LinkExpirationDate,
		                 OrderStatus,  
						 StatusDate, 
						 TestResult,
		                 c.CandidateID,
						 c.APNO,
						 C.COC,
						 C.ReasonforTest,
						 C.TestResultDate,
						 C.TID
		FROM  @tmpResults C
		
		BEGIN --ReOrders typically are based on OCHS_CandidateID and not the APNO. This logic will handle any reorders done in the old way where APNO was inserted as ORderid
		DECLARE @tmpReorders TABLE (RowID INT,APNO INT)
	
		INSERT INTO @tmpReorders
		SELECT MIN(RowID) RowID,OrderID_Or_Apno 
		FROM @tmpMain 
		GROUP BY OrderID_Or_Apno HAVING COUNT(1)>1

		-- SELECT 4,* FROM #tmpReorders
		IF (SELECT COUNT(1) FROM @tmpReorders)>0
		BEGIN	
			UPDATE @tmpMain SET APNO = 0 
			WHERE RowID not IN (SELECT RowID FROM @tmpReorders) 
			AND APNO IN (SELECT APNO FROM @tmpReorders)

			UPDATE M SET OrderStatus = t.OrderStatus,StatusDate=t.StatusDate,
			TestResult = t.TestResult,
			M.OrderID_Or_Apno=CASE WHEN M.APNO =0 THEN M.candidateID ELSE M.APNO END,M.TestResultDate = t.TestResultDate,M.COC = t.COC,m.ReasonforTest = t.ReasonforTest
			
			FROM @tmpMain M INNER JOIN @tmpresults t ON CAST(M.CandidateID AS VARCHAR) = t.OrderIDOrApno AND M.Apno=0 

			
		END
	END --ReOrders typically are based on OCHS_CandidateID and not the APNO. This logic will handle any reorders done in the old way where APNO was inserted as ORderid

		
		INSERT INTO @Temp
			SELECT TID, (CASE WHEN RTRIM(LTRIM(TestResult)) = 'x:Expired' THEN 'Passport Expired' ELSE OrderStatus END),
			APNO, CandidateID, FirstName, LastName, @SSN, null	
			FROM @tmpMain  
			WHERE ISNULL(OrderID_Or_Apno,'')<>''
			ORDER BY StatusDate, LastName,firstname,expirationDate    
END
	RETURN
END
