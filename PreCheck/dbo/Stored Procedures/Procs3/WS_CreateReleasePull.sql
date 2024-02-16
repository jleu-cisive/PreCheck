-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.WS_CreateReleasePull
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select ai.applimagesid,ai.apno,ai.imagefilename,ai.clientfilename,ai.description
 from applimages ai inner join appl a on ai.apno = a.apno
where ai.clientfilename ='signature.jpg' and ai.status is null
and isnull(a.ssn,'') <> ''

   
END
