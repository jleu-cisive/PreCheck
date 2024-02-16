-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/30/2017
-- Description:	TMH TAT Report for Robert Perez
-- Modified By : Radhika Dereddy on 12/4/2017 to include Attended Dates From and To
-- EXEC [TMH_TAT_Report] '10/01/2017','12/01/2017',''
-- =============================================
CREATE PROCEDURE [dbo].[TMH_TAT_Report]
	-- Add the parameters for the stored procedure here
		@StartDate datetime,
		@EndDate datetime,
		@CLNO varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

if(@CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END



select a.apno,c.clno,c.name as Client,a.apdate as 'received date',
a.apstatus as Status,
a.last,a.first,a.middle,
 a.compdate as 'Completed Date',
a.origcompdate as 'Original Completed Date',
a.reopendate as 'Reopen Date',
dbo.elapsedbusinessdays_2(a.apdate,a.origcompdate) as elapsedBizDays, replace(description,'Package: ' ,'') Package
 from appl a with (nolock)
inner join client c with (nolock) on a.clno = c.clno
inner join (Select description,CLNO,Apno  from invmaster m WITH (NOLOCK) inner join invdetail d WITH (NOLOCK) on  m.InvoiceNumber = d.InvoiceNumber where billed =1 and CLNO in 
(SELECT * from [dbo].[Split](':',@clno)) and description like 'package%') Inv on a.Apno = Inv.Apno and a.CLNO = Inv.CLNO
where (a.clno in 
(SELECT * from [dbo].[Split](':',@clno)) OR @clno IS NULL )
and a.apdate between @StartDate and DateAdd(d,1,@EndDate)
END
