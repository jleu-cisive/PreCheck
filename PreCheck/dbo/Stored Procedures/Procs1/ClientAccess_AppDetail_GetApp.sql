



-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets app Details for the client in Check Reports
--Modified By: Santosh Chapyala on 07/03/2017
-- To include the Package Ordered and Applied
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetApp]
@apno int,
@clno int 
AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Insert into ClientAccess_TMPLog
Select 0,@clno,@apno


DECLARE @PackageID INT,@Package_Ordered VARCHAR(100)

Declare @Appl Table (APNO Int,PackageID int,CLNO int,ApStatus char(1),First varchar(20),Last varchar(20),Middle varchar(20),SSN varchar(11),EnteredVia VARCHAR(8),Pub_Notes varchar(max),ClientNotes varchar(max))

Insert into @Appl
Select A.APNO, A.PackageID,A.CLNO,A.ApStatus,A.First,A.Last,A.Middle,A.ssn,A.EnteredVia, A.Pub_Notes, A.ClientNotes
FROM  dbo.Appl A 
Where Apno = @apno


IF ((SELECT EnteredVia FROM @Appl) = 'CIC')
	BEGIN
		SELECT @PackageID = BusinessPackageId             
		FROM Enterprise.dbo.Applicant A INNER JOIN	Enterprise.dbo.orderservice OS ON OS.OrderId = A.OrderId
		WHERE ApplicantNumber =  @apno  
		AND BusinessServiceId = 1 --Background service


		IF @PackageID IS NOT NULL
			SELECT @Package_Ordered = ISNULL(CP.ClientPackageDesc,P.PackageDesc)
			From  dbo.ClientPackages CP 
			INNER JOIN dbo.PackageMain P ON CP.PackageID = P.PackageID 
			WHERE CP.PackageID =  @PackageID 
			AND  CP.CLNO = @clno
	END  
ELSE	        
	BEGIN
		SELECT @PackageID = Request.value('(/Application/NewApplicant/PackageId)[1]', 'int')             
		FROM dbo.PrecheckServiceLog             
		WHERE servicename ='PrecheckWebService'    
		AND apno =@apno 

		IF @PackageID IS NOT NULL
			SELECT @Package_Ordered = ISNULL(CP.ClientPackageDesc,P.PackageDesc)
			From  dbo.ClientPackages CP 
			INNER JOIN dbo.PackageMain P ON CP.PackageID = P.PackageID 
			WHERE CP.PackageID =  @PackageID 
			AND  CP.CLNO = @clno
	END     



SELECT A.ApStatus,A.APNO,A.First,A.Last,A.Middle,A.ssn,W.CrimPreview, REPLACE(A.pub_notes,';;',';<br><br>') Pub_Notes, A.ClientNotes,ISNULL(CP.ClientPackageDesc,P.PackageDesc) Package_Applied, @Package_Ordered Package_Ordered, A.PackageID
FROM  Appl A 
INNER JOIN Client ON A.CLNO = Client.CLNO 
LEFT OUTER JOIN WeborderPrefs W ON Client.CLNO = W.Clno 
LEFT JOIN dbo.ClientPackages CP ON A.PackageID = CP.PackageID and A.clno = CP.CLNO
LEFT JOIN dbo.PackageMain P ON CP.PackageID = P.PackageID
WHERE A.APNO = @apno
and
(Client.CLNO = @clno
or
Client.WebOrderParentCLNO = @clno
)


SET ANSI_NULLS ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SET NOCOUNT OFF


