CREATE PROCEDURE dbo.TestReportBilling900ChargesHEVNclients 
@FirstOfMonth datetime=null
AS

Declare @StartDate datetime
Declare @EndDate datetime

Set @StartDate =  DATEADD(day, 15, @FirstOfMonth)
Set @EndDate =  DATEADD(day, 45, @FirstOfMonth)

if(@FirstOfMonth is not null)
 BEGIN --Based on Invoice Date
      SELECT distinct c.Name,c.clno, i.Apno, a.First,a.Last,a.SSN, Description  FROM InvDetail i
      --  join InvMaster m on m.InvoiceNumber = i.InvoiceNumber
          join Appl a on i.apno=a.apno
          join Client c on c.clno=a.clno
          join Empl e on e.apno=i.apno
         WHERE (CreateDate > = @StartDate and CreateDate < @EndDate) 
         
--	and type=1 --manual entry
         and Description like '%900%'  -- Employment 900 call , Precheck paid to get employment info
         and c.HEVNEmployer=1 -- HEVN client, we pay their 900 charges
--C.HevnEmployerStatusID <> 1
         ORDER BY c.name
 END
ELSE
BEGIN --For items not yet invoiced
      SELECT distinct c.Name,c.clno, i.Apno, a.First,a.Last,a.SSN, Description  FROM InvDetail i
--  join InvMaster m on m.InvoiceNumber = i.InvoiceNumber
      join Appl a on i.apno=a.apno
      join Client c on c.clno=a.clno
      join Empl e on e.apno=i.apno
      WHERE --InvDate > = @StartDate and InvDate < @EndDate 
       InvoiceNumber is null
      and type=1 --manual entry
      and Description like '%900%'  -- Employment 900 call , Precheck paid to get employment info
      and c.HEVNEmployer=1 -- HEVN client, we pay their 900 charges
--C.HevnEmployerStatusID <> 1 
ORDER BY c.name


END