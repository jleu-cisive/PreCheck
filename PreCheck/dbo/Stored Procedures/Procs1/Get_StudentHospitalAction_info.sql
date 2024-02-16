-- =============================================
-- Author:		<Radhika Dereddy >
-- Description: <For StudentCheck - Check Status page>
-- 	Create date: <11/13/2015>
-- =============================================

--EXEC Get_StudentHospitalAction_info '497-08-8775', '02/11/1994'
CREATE PROCEDURE Get_StudentHospitalAction_info
	-- Add the parameters for the stored procedure here
	@SSN varchar(11),
	@i94 varchar(50) = null,
	@DOB varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		 SELECT top 1 APNO, First, Last FROM dbo.Appl 
		 INNER JOIN client cl on  Appl.clno = cl.clno
		 WHERE ((REPLACE('SSN','-','') = REPLACE(@SSN,'-','')) 
		 OR REPLACE(i94,'-','') = REPLACE(@i94,'-','')) 
		AND DOB = @DOB AND 
		(Enteredvia = 'StuWeb' OR  cl.clienttypeid in (6,8,9,11,12,13) )
		order by appl.createddate desc
END
