-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 02/09/2022
-- Description:	This procedure breaks down order details by source
-- on the CIC platform. 1= StudentCheck; 2 =  CIC; 3 = All
-- =============================================

--CIC_Platform_BillingBreakdown_ByService 1,'01/01/2022','02/01/2022'
--CIC_Platform_BillingBreakdown_ByService 2,'07/01/2021','10/01/2021'
--CIC_Platform_BillingBreakdown_ByService 3,'01/01/2022','02/01/2022'
CREATE Procedure [dbo].[CIC_Platform_BillingBreakdown_ByService]
(@SourceSystem Int = 1 ,@StartDate Date,@EndDate Date)
AS


Select top 100 Percent OrderNumber APNO,
Enteredvia = Case DASourceID When 1 then 'Stuweb' 
								When 2 then 'CIC'
								else 'Other'
			 End,
ClientID,ClientProgramID,
InvoiceAmount,o.CreateDate OrderDate,
OS_BG.BusinessPackageID BackgroundPackageID, OS_BG.Price BackgroundPrice,
OS.OrderServiceNumber DrugTestOrderNumber,OS.BusinessPackageID DrugTestPackageID, OS.Price DrugTestPrice,CoC,
OS_IM.BusinessPackageID ImmunizationPackageID, OS_IM.Price ImmunizationPrice,PackageDesc,
Case when OrderPaymentID is null then 'No' else 'Yes' End PaymentProcessed,
case when isnull(SchoolWillPay,0) = 0 then 'No' else 'Yes' end SchoolPays,ClientType,Invoicenumber
from enterprise..[order] O 
left join enterprise..[OrderService] OS On O.OrderId=OS.OrderId and OS.businessserviceID = 2
left join enterprise..[OrderService] OS_BG On O.OrderId=OS_BG.OrderId and OS_BG.businessserviceID = 1
left join enterprise..[OrderService] OS_IM On O.OrderId=OS_IM.OrderId and OS_IM.businessserviceID = 3
left join precheck..packagemain cp on  OS.BusinessPackageId = Cp.PackageID
left join (select --MAX(orderstatus) orderstatus,max(datereceived) datereceived,max(testresult) testresult,
					 max(coc) coc,OrderIDOrAPNO--,max(clno) FacilityClientNO
					from precheck.dbo.OCHS_ResultDetails (nolock) group by OrderIDOrAPNO) co 
						on (cast(os.Orderservicenumber  as varchar)= OrderIDOrAPNO  OR cast(o.ordernumber as varchar) = OrderIDOrAPNO)
left join enterprise..OrderPayment Pay (nolock) on O.OrderID = Pay.OrderID
left join precheck..Client Cl (nolock) on o.clientID = cl.clno 
inner join precheck..refClienttype r on cl.clienttypeid = r.clienttypeid
left join (select distinct Apno,max(invoicenumber) Invoicenumber from Precheck..InvDetail 
 where createdate between dateadd(m,1,@StartDate) and dateadd(m,3,@EndDate)
 group by apno )a on o.OrderNumber = a.apno
where DASourceID = Case When @SourceSystem =3 then DASourceID else @SourceSystem end
and cast(O.CreateDate as Date) between @StartDate and @EndDate








