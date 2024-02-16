-- Alter Procedure ClientAccess_AppDetail_pullCriminal_bkp03272020


-- [ClientAccess_AppDetail_pullCriminal] 22590178
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Criminal Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullCriminal_bkp03272020]
@crimID int 
AS



DECLARE @Apstatus varchar(1) 
Select @Apstatus = Apstatus From Appl where APNO = (select APNO from Crim where Crimid = @crimid)
If @Apstatus = 'F'
Begin

SELECT 
Crim.CrimID,
 Crim.APNO, 
Crim.[Clear], 
Crim.Ordered, 
Crim.Name, 
Crim.DOB, 
Crim.SSN, 
Crim.CaseNo, 
Crim.Date_Filed, 
Crim.Degree, 
Crim.Offense, 
Crim.Disposition, 
Crim.Sentence, 
Crim.Fine, 
Crim.Disp_Date,
--schapyala added the case statement to suppress the comments for Clears to avoid confusion to the client with regards to ETAs' etc when the search was in Pending. Potentialy need to show comments for registeries when moved to Public Records
Case When Crim.[Clear] = 'T' then '' else Crim.Pub_Notes end Pub_Notes,  
TblCounties.A_County + ', ' + TblCounties.State AS county 
FROM Crim 
INNER JOIN dbo.TblCounties ON Crim.CNTY_NO = TblCounties.CNTY_NO 
WHERE Crim.CrimID = @crimID

End
else
Begin
SELECT 
Crim.CrimID,
 Crim.APNO, 
Crim.[Clear], 
Crim.Ordered, 
Crim.Name, 
Crim.DOB, 
Crim.SSN, 
Crim.CaseNo, 
Crim.Date_Filed, 
Crim.Degree, 
Crim.Offense, 
Crim.Disposition, 
Crim.Sentence, 
Crim.Fine, 
Crim.Disp_Date,
--schapyala added the case statement to suppress the comments for Clears to avoid confusion to the client with regards to ETAs' etc when the search was in Pending. Potentialy need to show comments for registeries when moved to Public Records
Case When Crim.[Clear] in ('D','V','T') then '' else (case when 
crim.clear = 'F' and 
((Degree = 'O'or degree= 'U' or isnull(degree,'') = '' or  Degree in ('1','2','3','4','5','6','7','8','9','M') ) and (( (isnull(Disp_Date,'') = '' ) and (isnull(Date_Filed,'') = '' ))
 or ((isnull(Disp_Date,'') = '' ) and (CONVERT (date, Date_Filed) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP))))
 or ((CONVERT (date, Disp_Date)) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP)) and (CONVERT (date, Date_Filed) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP))))
  ))
  and CrimID not in (select Crimid from dbo.[Crim_ReviewReportabilityLog] where Crimid = @crimID) then '' else Crim.Pub_Notes end)end Pub_Notes, 
TblCounties.A_County + ', ' + TblCounties.State AS county 
FROM Crim 
INNER JOIN dbo.TblCounties ON Crim.CNTY_NO = TblCounties.CNTY_NO 
WHERE Crim.CrimID = @crimID

end
