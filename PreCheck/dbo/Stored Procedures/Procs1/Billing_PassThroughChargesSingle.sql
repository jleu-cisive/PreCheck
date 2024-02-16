-- Alter Procedure Billing_PassThroughChargesSingle

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified By: Radhika Dereddy
-- Modified Date: 04/06/2018
-- Reason: It has come to the attention of Eddie Kemp that the additional court fees are not being charged per name being researched for criminal searches. 
-- Eddie estimates that monthly losses are approximately $50K per month. 
-- Each Pass Through fee must be multiplied by the total number of names searched via the research method, researcher, etc. 
-- Alias Name Logic must be used to determine the number of names being submitted via the research method.
-- The total costs associated with the Pass Through Charge(s) must be added to the invoice per the client manager settings.

-- Modified by Radhika Dereddy on 05/08/2018 -  add the group by clause for ApplAliasID for not charging for duplicate names

--- Modified by Radhika Dereddy on 10/17/2018 - to remove applAliasid and include sectionkeyid, since the Alias automation logic fixed the duplicate entries in the system.
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PassThroughChargesSingle]
	(@CLNO smallint
	, @APNO int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT Z.APNO, Z.CNTY_NO, MIN(C.A_County) + ', ' + MIN(C.State) + ' Court Access Fee' as 'Description', (ISNULL(Max(Z.NoOfNames), 1) *  MIN(C.PassThroughCharge)) as 'Amount' 
into #tempAliasCourtFee
FROM dbo.TblCounties AS C(NOLOCK)
INNER JOIN (
				SELECT DISTINCT C2.apno,c2.CNTY_NO, X.NoOfNames from dbo.Crim AS C2(NOLOCK) 
				INNER JOIN dbo.Appl AS A(NOLOCK) ON C2.APNO = A.APNO and A.ApStatus = 'F'
				INNER JOIN  
				(
					SELECT AA.APNO, S.SectionKeyID, COUNT(S.SectionKeyID) AS NoOfNames 
					--COUNT( AA.ApplAliasID) AS NoOfNames  --Commented by Radhika Dereddy on 10/17/2018(to remove Count(ApplAliasID)
					FROM appl A (NOLOCK)  inner join 
					ApplAlias AS AA(NOLOCK)  on A.apno = aa.APNO
					INNER JOIN dbo.ApplAlias_Sections AS S(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID AND S.IsActive = 1 AND S.ApplSectionID = 5 
					WHERE AA.IsPublicRecordQualified = 1 
					AND AA.IsActive = 1 and A.Billed = 0 AND A.CLNO = @CLNO AND A.APNO = @APNO
					GROUP BY AA.APNO, S.SectionKeyID 
					--, AA.ApplAliasID         --Commented by Radhika Dereddy on 10/17/2018(to remove ApplAliasID)  --Addded ApplAliasID by Radhika Dereddy on 05/08/2018                      
				) AS X
				 ON C2.CrimID = X.SectionKeyID
           WHERE A.Billed = 0 AND C2.IsHidden = 0 AND A.CLNO = @CLNO AND A.APNO = @APNO
           ) Z  on C.CNTY_NO = Z.CNTY_NO AND C.PassThroughCharge > 0  
GROUP BY Z.APNO, Z.CNTY_NO, Z.NoOfNames
ORDER BY apno 

SELECT C2.APNO, C.CNTY_NO, MIN(C.A_County) + ', ' + MIN(C.State) + ' Court Access Fee' as 'Description', MIN(C.PassThroughCharge) as 'Amount', t.apno as Tapno
into #tempCharges
FROM   dbo.TblCounties C
              INNER JOIN dbo.Crim C2 ON C.CNTY_NO = C2.CNTY_NO AND C.PassThroughCharge > 0 AND C2.IsHidden = 0                    
              INNER JOIN dbo.Appl A ON C2.APNO = A.APNO and A.ApStatus = 'F'
              INNER JOIN dbo.Client Cl ON Cl.CLNO = A.CLNO  AND A.Billed = 0 AND Cl.CLNO = @CLNO AND A.APNO =@APNO
              LEFT JOIN #tempAliasCourtFee t on c2.apno = t.apno and c2.CNTY_NO = t.CNTY_NO                      
GROUP BY C2.APNO, C.CNTY_NO, t.APNO
ORDER BY c2.apno



INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT DISTINCT X.APNO, 2, NULL, NULL, 0, NULL, getdate(), Description, Amount
FROM (
		SELECT DISTINCT APNO, Description,Amount from #tempAliasCourtFee
		UNION ALL
		SELECT DISTINCT APNO, Description, Amount from #tempCharges where Tapno is null
	 ) x
order by  x.apno 

drop table #tempAliasCourtFee
drop table #tempCharges



--Commented by Radhika Dereddy on 04/20/2018
/*
INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT	C2.APNO, 2, NULL, NULL, 0, NULL, getdate(), MIN(C.A_County) + ', ' + MIN(C.State) + ' Service Charge', MIN(C.PassThroughCharge)
FROM	dbo.Counties C
		INNER JOIN dbo.Crim C2 ON C.CNTY_NO = C2.CNTY_NO
			AND C.PassThroughCharge > 0 AND C2.IsHidden = 0
			--AND C2.IrisOrdered >= @StartDate AND C2.IrisOrdered < @EndDate
		INNER JOIN dbo.Appl A ON C2.APNO = A.APNO
		INNER JOIN dbo.Client Cl ON Cl.CLNO = A.CLNO
			--AND Cl.BillCycle <> 'P'
			--AND Cl.BillingCycleID <> 6
			AND Cl.CLNO = @CLNO
			AND A.APNO = @APNO
			AND A.Billed = 0
GROUP BY C2.APNO, C2.CNTY_NO

*/

--add package surcharge
EXEC Billing_PackageSurcharge 3,@APNO,@CLNO


SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
