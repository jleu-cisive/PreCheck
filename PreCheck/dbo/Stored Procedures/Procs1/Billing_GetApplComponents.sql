-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetApplComponents]
	@APNO int
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Select  null Credit,em.Employer,null Lic_Type,null School,null Name,null CNTY_NO,null Civil,null DLCount FROM
	Empl em
WHERE em.APNO = @APNO AND em.IsOnReport = 1 AND em.IsHidden = 0
union all
Select null Credit,null Employer, Lic_Type,null School,null Name,null CNTY_NO,null Civil,null DLCount
From ProfLic l where APNO = @APNO AND IsOnReport = 1 AND IsHidden = 0
union all
Select null Credit, null Employer,null Lic_Type,ed.School,null Name,null CNTY_NO,null Civil,null DLCount
From Educat ed where APNO = @APNO AND IsOnReport = 1 AND IsHidden = 0
union all
Select null Credit, null Employer,null Lic_Type,null School,pr.Name,null CNTY_NO,null Civil,null DLCount
From PersRef pr where APNO = @APNO AND IsOnReport = 1 AND IsHidden = 0
union all
select Distinct null Credit, null Employer,null Lic_Type,null School,null Name,CNTY_NO,null Civil,null DLCount from Crim where Apno = @Apno AND IsHidden = 0
union all
select Distinct null Credit, null Employer,null Lic_Type,null School,null Name,null CNTY_NO,CNTY_NO As Civil,null DLCount from Civil where Apno = @Apno
union all
select null Credit, null Employer,null Lic_Type,null School,null Name,null CNTY_NO,null Civil,Count(*) As DLCount from DL where Apno = @Apno AND IsHidden = 0
union all
select (Vendor + RepType) As Credit,null Employer,null Lic_Type,null School,null Name,null CNTY_NO,null Civil,null DLCount from Credit where Apno = @Apno AND IsHidden = 0


SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END




set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
