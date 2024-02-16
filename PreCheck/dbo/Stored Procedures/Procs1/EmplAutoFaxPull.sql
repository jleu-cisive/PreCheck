













-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EmplAutoFaxPull]
	
AS
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Select Appl.SSN,
 Appl.Last,Appl.First,
 'PRECHECK' As Investigator,Appl.Alias1_First,Appl.Alias1_Middle,Appl.Alias1_Last,
 Empl.Apno,
 ClientEmployer.Company,
 ClientEmployer.ClientEmployerID,
 ClientEmployer.CLNO,
 ClientEmployer.Fax,
 ClientEmployer.Phone,
 ClientEmployer.FirstName,
 ClientEmployer.LastName,
 Empl.From_A,
 Empl.To_A,
 Empl.EmplID 
FROM Empl WITH (NOLOCK) INNER JOIN ClientEmployer WITH (NOLOCK)
ON ClientEmployer.ClientEmployerID = Empl.ClientEmployerID 
INNER JOIN Appl WITH (NOLOCK) ON Empl.Apno = Appl.APNO
WHERE ClientEmployer.EmplContactMethod = 1
AND Appl.InUse is null 
and appl.apstatus = 'P'
--AND not ClientEmployer.EmplReleaseRequired = 1
AND (Empl.SectStat = '9' OR Empl.SectStat = '0')
AND Empl.AutoFaxStatus is null
AND not Empl.ClientEmployerID is null
--AND Empl.APNO = 841838 --For Testing

		

    
SET NOCOUNT OFF;
END
















