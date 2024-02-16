-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Investigator_AutoOrder]
	-- Add the parameters for the stored procedure here
		 @CLNO int,
		 @StartDate DateTime,
		 @EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT Count(1) as ReportCount, a.APNO as ReportNumber, a.Investigator, c.Name as ClientName, a.Apdate as ReportDate FROM Appl a WITH (NOLOCK) INNER JOIN Client c on a.CLNO = c.CLNO
		WHERE a.Investigator ='AUTO' AND a.CLNO = IIF(@CLNO=0,a.CLNO,@CLNO) AND
		a.apdate BETWEEN @StartDate AND @EndDate
		group by c.Name, a.APNO, a.Apdate, a.Investigator 


		--Commented by Radhika Dereddy on 03/21/2014
		--SELECT Count(1) as ReportCount FROM Appl a WITH (NOLOCK) INNER JOIN Client c on a.CLNO = c.CLNO
		--WHERE a.Investigator ='AUTO' AND a.CLNO = IIF(@CLNO=0,a.CLNO,@CLNO) AND
		--a.apdate BETWEEN @StartDate AND @EndDate
END
