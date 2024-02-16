-- =============================================
-- Author:		Liel Alimole
-- Create date: 03/27/2013
-- Description:	This procedure calculates the revenue for all clients in the given application (@year) date to the present year
-- =============================================
CREATE PROCEDURE [dbo].[GetRevenueByYear]
	@Year varchar(4)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
 --Get list of clients whose first app date is in the given year
DECLARE @clientList1 TABLE (a INT, b datetime, c varchar(1000), d int)
INSERT into @clientList1
	select Clno, fistappdate, name, ClientTypeID from
		(select C.Clno,C.name, min(A.ApDate) as fistappdate, C.ClientTypeID
		from Client C inner join Appl A on C.CLNO = A.CLNO
		
		group by C.CLNO,C.name, C.Clienttypeid) l 
		where year(l.fistappdate) = @Year
		order by l.CLNO

DECLARE @clientList TABLE (a INT, b datetime, c varchar(1000), d varchar(1000))
insert into @clientList 
	select c1.a, c1.b, c1.c, ct.ClientType
	from @clientList1 c1 inner join refClientType ct on c1.d = ct.ClientTypeID

--Get the tax and sales sums for each month by client
DECLARE @monthlist TABLE (clno INT, month nvarchar(1000), sum smallmoney, taxsum smallmoney)
		INSERT into @monthlist
		SELECT  CLNO, DateName( month , DateAdd( month , Month(InvDate) , 0 ) - 1 ) as 'month', sum(Sale) as SaleSum, sum(Tax) as TaxSum
		FROM         dbo.InvMaster
		WHERE     CLNO in (SELECT a AS val FROM @clientList)
		and year(InvDate) = @Year
		group by CLNO, Month(InvDate)
		order by CLNO

--Get the month sales for each client spread over 12 months
DECLARE @monthlist2 TABLE (clno INT, [January] smallmoney ,[February] smallmoney ,[March] smallmoney ,[April] smallmoney ,[May] smallmoney ,[June] smallmoney ,[July] smallmoney ,[August] smallmoney ,[September] smallmoney ,[October] smallmoney ,[November] smallmoney ,[December] smallmoney) -- months
INSERT into @monthlist2
select *
  from
    (
    select clno, m.month as Month_, sum
    from @monthlist m
    ) p
 pivot (sum(sum) for Month_ in ([January],[February],[March],[April],[May],[June],[July],[August],[September],[October],[November],[December])) v

--Get the sale and tax sum (revenue) of above clients for all invoices from the given year to the current year
	DECLARE @sumList TABLE (a INT, b smallmoney, c smallmoney)
	INSERT into @sumList
		SELECT  CLNO, sum(Sale) as SaleSum, sum(Tax) as TaxSum
		FROM         dbo.InvMaster
		WHERE     CLNO in (SELECT a AS val FROM @clientList)
		and year(InvDate) = @Year
		group by CLNO
		order by CLNO

	-- output the CLNO, ClientName, firstAppdate, sales for all months, total sales and total tax sum
	SELECT c.a as CLNO,c.c as ClientName, c.b as FirstAppDate, c.d as ClientType,
	m.[January],m.[February],m.[March],m.[April],m.[May],m.[June],m.[July],m.[August],m.[September],m.[October],m.[November],m.[December],
	s.b as 'Total Sales Sum', s.c as 'Total Tax Sum'
	from @clientList c inner join @sumList s on c.a = s.a
	inner join @monthlist2 m on s.a = m.clno
	order by c.a



END
