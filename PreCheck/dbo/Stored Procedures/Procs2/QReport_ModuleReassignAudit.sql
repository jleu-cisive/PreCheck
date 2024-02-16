-- =============================================
-- Author:	Abhijit Awari
-- Create date: 07/20/2022
-- Description:	Qreport that shows userid that moved an education or employment report from one module to another module
-- =============================================
Create PROCEDURE [dbo].[QReport_ModuleReassignAudit] 
	-- Add the parameters for the stored procedure here
	@apno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	select 'Education' as Identifier, e.APNO, e.School as [Name], 
	c.OldValue as [Old Value], c.NewValue as [New Value], c.ChangeDate as [Change Date], 
	c.UserID as [User ID]
	from dbo.changelog c with(nolock)
	inner join dbo.Educat e with(nolock) on c.ID = e.EducatID
	where c.OldValue <> c.NewValue and c.TableName = 'Educat.Investigator' 
	and e.apno = @apno

	Union All

	select 'Employment' as Identifier ,e.APNO, e.Employer as [Name], 
	c.OldValue as [Old Value], c.NewValue as [New Value], c.ChangeDate as [Change Date], 
	c.UserID as [User ID]
	from dbo.changelog c with(nolock)
	inner join dbo.Empl e with(nolock) on c.ID = e.EmplID
	where c.OldValue <> c.NewValue and  c.TableName = 'Empl.Investigator' 
	and  e.apno = @apno

END







