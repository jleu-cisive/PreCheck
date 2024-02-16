-- =============================================
-- Author:		kiran miryala
-- Create date: 10/28/2013
-- Description:	Billing- to remove pass thru charges, actually to add negitive amount to invdetail table.
-- modified by Lalit on 30 jan 2023 to add monthly service fee for #71323
-- =============================================
CREATE PROCEDURE [dbo].[Billing_RemovePassThruCharges]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Add Data Entry fee $3.25 by Client by Package (imported the spresheet that Dana provided into a table)
	-- for all APNO entered by Precheck Staff EnteredVia = 'DEMI' from 11/01/2021
	-- Modified by Radhika Dereddy on 12/01/2021
	EXEC dbo.[Billing_AddDataEntryPassThruFeeByClientByPackage]


	DELETE FROM INVDETAIL WHERE Billed = 0 and Type = 2 and Amount < 0 and Description not  like 'Criminal%' -- Radhika on 01/31/2017


   CREATE TABLE #PassThru (clno Int NOT NULL,Apno Int , Type Int ,Billed bit,CreateDate datetime, Description  varchar(100), Amount  smallmoney)
   INSERT INTO #PassThru 
   SELECT   a.clno
      ,i.[APNO]
      ,[Type]     
      ,i.[Billed]		
      ,getdate()
      ,[Description],Amount
      --,Convert(smallmoney,('-' + cast(Amount as varchar))) as Amount   

FROM            dbo.InvDetail i inner join Appl a on i.Apno= a.apno
inner join precheck.[dbo].[ClientConfiguration] cc on a.CLNO = cc.CLNO and ConfigurationKey = 'RemovePassThruCharges'
where i.Billed = 0 and Type = 2  and Amount > 0 and Description not  like 'Criminal%'
order by i.apno 

update #PassThru 
set Amount = Convert(smallmoney,('-' + cast(Amount as varchar)))


 --INSERT INTO #PassThru 
 --  SELECT   clno
 --     ,[APNO]
 --     ,[Type]     
 --     ,[Billed]		
 --     ,getdate()
 --     ,[Description],Convert(smallmoney,('-' + cast(Amount as varchar)))
	--  from #PassThru

INSERT INTO dbo.InvDetail
           ([APNO]
           ,[Type]
           ,[Billed]
           ,[CreateDate]
           ,[Description]
           ,[Amount])
     SELECT[APNO]
      ,[Type]     
      ,[Billed]		
      ,[CreateDate]
      ,[Description],
	  Amount
from #PassThru

-- SELECT  a.clno
--      ,i.[APNO]
--      ,[Type]     
--      ,i.[Billed]		
--      ,getdate()
--      ,[Description],Amount
--      --,Convert(smallmoney,('-' + cast(Amount as varchar))) as Amount   

--FROM            dbo.InvDetail i inner join Appl a on i.Apno= a.apno
--inner join precheck.[dbo].[ClientConfiguration] cc on a.CLNO = cc.CLNO and ConfigurationKey = 'RemovePassThruCharges'
--where i.Billed = 0 and Type = 2  and Amount <> 0 and Description not  like 'Criminal%' 
--order by i.APno


--select * from #PassThru order by APNO

drop table #PassThru
-- Added by Kiran 05/02/2022 to remove Duplictae pass thru charges for Worknumber

--Exec [dbo].[Billing_RemoveDuplicateWNCharges]
Exec [dbo].[Billing_MonthlyServiceFee]

END
