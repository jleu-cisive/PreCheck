-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetApplComponents_NP]
	@APNO int
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Select  'EMPL' AS Identifier,em.Employer As LineItemDescription
 FROM Empl em
WHERE em.APNO = @APNO
union all
Select 'PROF' AS Identifier, Lic_Type As LineItemDescription
From ProfLic l where APNO = @APNO
union all
Select 'EDUC' AS Identifier,ed.School As LineItemDescription
From Educat ed where APNO = @APNO
union all
Select 'PERS' AS Identifier,pr.Name As LineItemDescription
From PersRef pr where APNO = @APNO
union all
select Distinct 'CRIM' AS Identifier,'' + CAST(CNTY_NO AS varchar(20)) AS LineItemDescription
FROM Crim where Apno = @Apno
union all
select Distinct 'CIV' As Identifier,'' + CAST(CNTY_NO AS varchar(20)) As LineItemDescription
FROM Civil where Apno = @Apno
union all
select 'DL' AS Identifier,'DL' As LineItemDescription from DL where Apno = @Apno
union all
select 'CRED' AS Identifier,(Vendor + RepType) As LineItemDescription from Credit where Apno = @Apno AND RepType = 'C'
union all
select 'SOC' AS Identifier,(Vendor + RepType) As LineItemDescription from Credit where Apno = @Apno AND RepType = 'S'


SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END






