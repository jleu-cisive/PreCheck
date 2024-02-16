

--EXEC Precheck.[dbo].[Applications_With_No_DeptCode] '08/10/2011','09/15/2014',10760

-- =============================================
-- Author:		<Prasanna>
-- Create date: <09/15/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Applications_With_No_DeptCode]
	-- Add the parameters for the stored procedure here
	
	@StartDate DateTime,
	@EndDate DateTime,
	@CLNO int

AS
BEGIN
   if (@CLNO <> null OR @CLNO <> 0)
	  Begin
		select a.CLNO, a.APNO, a.apdate, a.DeptCode, 
		cd.XMLD.value('(/CustomClientData/ClientData1)[1]', 'nvarchar(max)') as Datapoint1,
		cd.XMLD.value('(/CustomClientData/ClientData2)[1]', 'nvarchar(max)') as Datapoint2,
		cd.XMLD.value('(/CustomClientData/ClientData3)[1]', 'nvarchar(max)') as Datapoint3,
		cd.XMLD.value('(/CustomClientData/ClientData4)[1]', 'nvarchar(max)') as Datapoint4,
		a.Investigator, a.Enteredby from Appl a with(nolock)  inner join ApplClientData cd with(nolock)
		on a.apno = cd.apno and a.clno = cd.clno
		where (@CLNO IS NULL OR a.CLNO = @CLNO) and (apdate >= @StartDate and apdate <= @Enddate) and (DeptCode is NULL OR DeptCode = '')
		order by CLNO,apdate
	  End
   else 
	  Begin
		select a.CLNO, a.APNO, a.apdate, a.DeptCode, 
		cd.XMLD.value('(/CustomClientData/ClientData1)[1]', 'nvarchar(max)') as Datapoint1,
		cd.XMLD.value('(/CustomClientData/ClientData2)[1]', 'nvarchar(max)') as Datapoint2,
		cd.XMLD.value('(/CustomClientData/ClientData3)[1]', 'nvarchar(max)') as Datapoint3,
		cd.XMLD.value('(/CustomClientData/ClientData4)[1]', 'nvarchar(max)') as Datapoint4,
		a.Investigator, a.Enteredby from Appl a with(nolock) inner join ApplClientData cd with(nolock)
	    on a.apno = cd.apno and a.clno = cd.clno
	    where (apdate >= @StartDate and apdate <= @Enddate) and (DeptCode is NULL OR DeptCode = '')
	    order by CLNO,apdate
	  End

END
