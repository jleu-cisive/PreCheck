-- =============================================
-- Author:		Najma Begum	
-- Create date: 06/09/2012
-- Description:	insert new crim record
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AddSanctionCheck]
	@Apno int, @SectStat char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @getclientno char;
Select @getclientno = (select dbo.client.[Medicaid/Medicare] from dbo.client
inner join appl on dbo.client.clno = dbo.appl.clno where dbo.appl.apno = @Apno);
if (@getclientno = '1')
  Begin
   if ((select count(*) from dbo.medinteg where apno = @apno) = 0)
     INSERT INTO dbo.Medinteg (apno,sectstat,CreatedDate) VALUES (@Apno,@SectStat,getdate());
     else
     Update dbo.MedInteg set sectstat = @SectStat where apno = @Apno;
   end
END
