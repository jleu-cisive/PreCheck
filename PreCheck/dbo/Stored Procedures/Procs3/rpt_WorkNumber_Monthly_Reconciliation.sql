
CREATE Procedure [dbo].[rpt_WorkNumber_Monthly_Reconciliation]  (@StartDate datetime = '01/01/2019' , @EndDate datetime = '01/01/2020' )
AS
BEGIN
/*
Purpose:Report used to Reconcile Talx/WorkNumber charges
Author: Schapyala
Created: 12/31/2018

Updated : 07/09/2019
Author : Doug Degenaro
Purpose : Added last4 ssn and transaction date

Exec [rpt_WorkNumber_Monthly_Reconciliation] '12','2018'

Updated : 06/29/2020
Author : Doug Degenaro
Purpose : Added sent to sjv column for Data HDT 74581
Exec [rpt_WorkNumber_Monthly_Reconciliation] '06/01/2020','06/30/2020'
*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DROP TABLE IF EXISTS #empssenttosjv

declare @tr table 
       (
              APNo int not null index ix1 clustered, 
              CodeStatus varchar(3) not null index ix2 nonclustered (ApNo) , 
			  Last4SSN varchar(4) null, -- added 07/09/2019
			  TransactionDate datetime, -- added 07/09/2019
              ActiveUsed bit null ,
              InActiveUsed bit null,
              ExpectedCount int null,
              UsedCount int null 
       );



With rawData as
       (
              select  
                     RIGHT(SSN,4) as Last4SSN, -- added 07/09/2019
					 APNO,
					 CreatedDate,  -- added 07/09/2019
                     codestatus, 
                     IsPresent,
                     IsFoundEmployerCode
              from 
                     [dbo].[integration_verification_Transaction] 
              where 
                     VerificationCodeIDType='Employment' 
					 --and month(VerifiedDate) = cast(@Month as Int)
					 --and Year(verifiedDate) = cast(@Year as Int)
                     --and  VerifiedDate between '11/01/2018' and '11/30/2018 23:59:59.999' 

					 AND verifiedDate >=@StartDate
					 AND verifiedDate < dateadd(d,1,@EndDate)

                     and codestatus is not null
					 and Apno is not null
              group by 
                     RIGHT(SSN,4),   -- added 07/09/2019
					 APNO,  
                     codestatus,
					 CreatedDate,   -- added 07/09/2019
                     IsPresent,
                     IsFoundEmployerCode
       )
	  insert into @tr (Last4SSN,APNo,TransactionDate, CodeStatus, ActiveUsed, InactiveUsed, ExpectedCount, UsedCount) --  07/09/2019 Added Las4SSn and TransactionDate 
       (
              Select 
                     Last4SSN,	 --  07/09/2019 	
					 ApNoList.ApNo, 
					 CreatedDate,  --  07/09/2019
                     ApNoList.CodeStatus, 
                     case when ApNoList.CodeStatus='E' then 0 else IsNull(ActiveUsed.CountActiveUsed, 0) end, 
                     case when ApNoList.CodeStatus='E' then 0 else IsNull(InactiveUsed.CountInactiveUsed, 0) end,
                     case when ApNoList.CodeStatus='AI' then 2 when ApNoList.CodeStatus='E' then 0 else 1 end ExpectedCount,
                     case when ApNoList.CodeStatus='E' then 0 else IsNull(ActiveUsed.CountActiveUsed, 0)+IsNull(InactiveUsed.CountInactiveUsed, 0) end UsedCount
              From
                     (Select distinct  Last4SSN,ApNo,CreatedDate, CodeStatus from rawData) ApNoList --  07/09/2019 Added Last4SSN and CreatedDate 
                     left outer join
                     (
                           Select ApNo, case when Count(*) > 0 then 1 else 0 end CountActiveUsed from rawData where IsFoundEmployerCode=1 and IsPresent=1 group by ApNo, CodeStatus 
                     ) ActiveUsed on ApNoList.ApNo = ActiveUsed.apno
                     left outer join 
                     (
                           Select ApNo, case when Count(*) > 0 then 1 else 0 end CountInactiveUsed from rawData where IsFoundEmployerCode=1 and IsPresent=0 group by ApNo, CodeStatus
                     ) InactiveUsed on ApNoList.ApNo = InactiveUsed.apno
       ) ;


	   


	select e.Apno
	into #empssenttosjv 
	from dbo.ChangeLog cl inner join dbo.Empl e on cl.ID = e.Emplid
	where changedate >=@StartDate and changedate < dateadd(d,1,@EndDate) 
	and (TableName='Empl.OrderId' and  userid ='sjv')
	

	
       Select 
	   Last4SSN,
	   a.APNO [Report Number],

	   TransactionDate,
	   (Case CodeStatus When 'AI' then 'Active + InActive Records'
													When 'AO' then 'Active Records Only'
													When 'IO' then 'InActive Records Only'
													When 'E' then 'Error'
													Else 'UnKnown'
													End) [Records Returned]
		,ExpectedCount [Number of Talx Lookup Charges]
		,ActiveUsed [Active Records Consumed]
		,InactiveUsed [InActive Records Consumed]
		,UsedCount [Total Valid (Consumed) Talx Charges]
		,UnusedCount [Refund Required - Number of InValid (Charged-Consumed) Talx Charges]
		,IsSenttosjv as [Any emps for APNO sent to SJV] 
       From
       (
              select Last4SSN,convert(varchar,tr.APNo) ApNo,FORMAT(TransactionDate,'MM/dd/yyyy hh:mm tt') as TransactionDate, CodeStatus, ActiveUsed, InactiveUsed, ExpectedCount, UsedCount, ExpectedCount-UsedCount UnusedCount,case when isnull(sjvtemp.Apno,0) > 0 then 'true' else 'false' end as IsSenttosjv From @tr tr
			  left join #empssenttosjv sjvtemp on tr.APNO = sjvtemp.Apno
       ) a   
       union
       (
            select 
				null as Last4SSN,	
				'Total' ApNo,
				 null as TransactionDate, 
                     (select convert(varchar,count(*)) from @tr) CodeStatus
					 , sum(cast(ExpectedCount as int)) ExpectedCount					 
					 , sum(cast(ActiveUsed as int)) ActiveUsed, sum(cast(InactiveUsed  as int)) InactiveUsed
					 , sum(cast(UsedCount as int)) UsedCount
					 , (select sum(ExpectedCount-UsedCount) from @tr) UnusedCount,
					 null as IsSenttosjv
					 From @tr
         )
       order by a.ApNo



SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

END