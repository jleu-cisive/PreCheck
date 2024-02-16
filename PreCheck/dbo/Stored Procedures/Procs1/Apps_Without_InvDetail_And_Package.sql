-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/19/2017
-- Description:	Apps without Invoice detail and without package
-- =============================================
CREATE PROCEDURE Apps_Without_InvDetail_And_Package
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--#temp1

select Distinct Apno  Into #Temp1 from InvDetail where Apno in 
(

select Apno from Appl where Billed = 1 and Compdate >= @StartDate and Compdate <= @EndDate  ----177672
)

and Type=0 


--#temp2

select Apno into #temp2 from Appl where Billed = 1 and Compdate >= @StartDate and Compdate <= @EndDate


--#temp3

select * into #temp3  from InvDetail where Apno in 
(

select Apno from  #temp2 
)

and Apno not in (Select Apno from #temp1)


select * from #temp2 where  Apno not in (Select Apno from #temp3) and  Apno not in (Select Apno from #temp1) /* this is Apno’s which do not have an entry in the InvoiceDetail at all */


/* temp 3 is billed at line item level and no package price*/


Drop table #temp1
Drop table #temp2
Drop table #temp3

END
