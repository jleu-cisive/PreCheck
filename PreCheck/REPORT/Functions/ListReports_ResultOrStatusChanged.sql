
-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 5/12/2020
-- Description:	Returns list of APNO's where results changed/impacted within time range specified
-- modified by lalit to add orphan records status update on 11 sep 2022
-- =============================================

CREATE  function [REPORT].[ListReports_ResultOrStatusChanged](@StartDate SMALLDATETIME,@EndDate SMALLDATETIME)
RETURNS @Result TABLE(APNO INT) 
AS	
BEGIN


;WITH BG_Change as
(
	SELECT
	s.Apno
	FROM dbo.Appl_StatusLog s  WITH(NOLOCK)
	INNER JOIN (SELECT apno, clno from dbo.Appl WITH(NOLOCK)) a ON s.Apno=a.APNO
	INNER JOIN dbo.Client c WITH (NOLOCK) ON a.CLNO=c.CLNO
	WHERE ChangeDate BETWEEN @StartDate  AND @EndDate
	AND c.ClientTypeID IN (6,8,11)
),
 DT_Change AS
(
	SELECT
	APNO=OrderNumber
    FROM Enterprise.vwDrugReportStatus ds  WITH(NOLOCK)
	INNER JOIN dbo.Client c  WITH(NOLOCK) ON ds.CLNO=c.CLNO
	WHERE ResultUpdateDate BETWEEN @StartDate AND @EndDate
	AND c.ClientTypeID IN (6,8,11)
	AND ds.OrderNumber>0
-----------------------------------------------------------------------------
    UNION ALL
    SELECT APNO=a.APNO
	FROM dbo.vwIndependentDrugResultCurrent idr
	INNER JOIN dbo.Appl a ON REPLACE(a.SSN, '-', '')=REPLACE(idr.SSN, '-', '') AND a.CLNO=idr.CLNO AND DATEADD(MONTH, 3, a.ApDate)>idr.LastUpdate
	INNER JOIN dbo.Client c WITH (NOLOCK) ON idr.CLNO = c.CLNO
	WHERE idr.LastUpdate BETWEEN @StartDate AND @EndDate
	AND c.ClientTypeID IN (6, 8, 11)
-----------------------------------------------------------------------------
),
 IMM_Change AS
(
	SELECT
	APNO=O.OrderNumber
    FROM Enterprise.Verify.OrderImmunization oi WITH(NOLOCK)
	 INNER JOIN Enterprise.dbo.[Order] o WITH(NOLOCK)
	  ON o.OrderId = oi.OrderId
	  INNER JOIN dbo.Client c ON o.ClientId=c.CLNO
	WHERE OI.ModifyDate BETWEEN @StartDate AND @EndDate
	AND c.ClientTypeID IN (6,8,11)
)

INSERT INTO @Result (APNO)
	SELECT APNO FROM BG_Change
	UNION
	SELECT APNO FROM DT_Change
	union
	SELECT APNO FROM IMM_Change

 RETURN
END
