-- =============================================  
-- Author:  Dongmei He  
-- Create date: 04/06/2022  
-- Description: To return all the section statuses of a report/APNO.  
-- SELECT * from [dbo].[GetReportOverallStatus]   
-- ((SELECT ApplSectionID, SectStat, SectSubStatusID, Clno from [GetReportSectionStatus] (322467))) 
-- updated by Lalit for #103189 on 6-sep-2023
-- =============================================  
CREATE FUNCTION [dbo].[GetReportOverallStatus]   
(  
    @CLNO INT,   
 @ReportSections dbo.ReportSection READONLY   
)  
RETURNS  INT  
AS  
BEGIN  
 DECLARE @OverallStatus INT = 1  
  
 DECLARE @PARENTCLNO INT   
 SELECT @PARENTCLNO  = ISNULL(ParentId, ClientId) FROM dbo.vwClient WHERE ClientId=@CLNO  
  
     SELECT @OverallStatus =   
            MAX(CASE WHEN ISNULL(co.OverallStatus, ISNULL(ss.OverallStatus, ISNULL(s.OverallStatus,0))) >   
          ISNULL(cco.OverallStatus, ISNULL(cs.OverallStatus, 0))  
             THEN ISNULL(co.OverallStatus, ISNULL(ss.OverallStatus, ISNULL(s.OverallStatus,0)))   
    ELSE ISNULL(cco.OverallStatus, ISNULL(cs.OverallStatus, 0))  
          END)  
    FROM @ReportSections RS  
    
  LEFT JOIN SectStat s   
      ON ISNULL(s.Code, 0) = RS.SectStat  
  AND RS.ApplSection <> 'Crim'  
  LEFT JOIN SectSubStatus ss  
   ON ISNULL(ss.SectStatusCode, RS.SectStat)  = RS.SectStat  
  AND ISNULL(ss.SectSubStatusId, ISNULL(RS.SectSubStatusId, 0))   
    = ISNULL(RS.SectSubStatusId, 0)  
        AND ISNULL(ss.ApplSectionID, 0) = RS.ApplSectionID  
  LEFT JOIN ClientOverallStatus co  
   ON ISNULL(co.SectStatusCode, RS.SectStat) = RS.SectStat  
  AND ISNULL(co.SectSubStatusId, ISNULL(RS.SectSubStatusID, 0)) = ISNULL(RS.SectSubStatusID, 0)  
  AND (CO.CLNO=@PARENTCLNO  OR CO.CLNO=@CLNO)  
  AND RS.ApplSectionID=co.SectionId  
  
     --AND (ISNULL(co.CLNO, @CLNO) = @CLNO OR ISNULL(co.CLNO, @PARENTCLNO) = @PARENTCLNO)  
  LEFT JOIN CrimSectStat cs   
      ON ISNULL(cs.crimsect, 0) = RS.SectStat  
  AND RS.ApplSection = 'Crim'  
  LEFT JOIN ClientCrimOverallStatus cco  
   ON ISNULL(cco.StatusCode, 0) = RS.SectStat   
  AND (cco.CLNO=@PARENTCLNO  OR cco.CLNO=@CLNO)  
  AND RS.ApplSection = 'Crim'  
    ---------------- update ----------
if(@parentclno=7519 and @OverallStatus=0)
   begin 
	   declare @pid int
	   declare @medint int
	   declare @count int
	   SELECT @pid=ApplSectionID FROM @ReportSections WHERE ApplSectionID=9
	   SELECT @medint=ApplSectionID FROM @ReportSections WHERE ApplSectionID=7
	   SELECT @count=COUNT(*) FROM @ReportSections
	   IF (@pid=9 AND @medint=7 AND @count=2)
	    BEGIN
	      SET @OverallStatus=1
	    end
		 IF (@count>2 and @OverallStatus=0)
	    BEGIN
	      SET @OverallStatus=3
	    end
  end
  ----------------
  RETURN @OverallStatus  
END 