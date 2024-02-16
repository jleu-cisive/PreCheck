-- =============================================
-- Author:		kiran miryala
-- Create date: 10/28/2013
-- Description:	Billing- to remove pass thru charges, actually to add negitive amount to invdetail table.
-- =============================================
CREATE PROCEDURE [dbo].[Billing_Get_RemovePassThruCharges]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  

 SELECT  a.clno
      ,i.[APNO]
      ,[Type]     
      ,i.[Billed]		
      ,CreateDate--,getdate()
      ,[Description],Amount
      --,Convert(smallmoney,('-' + cast(Amount as varchar))) as Amount   

FROM            dbo.InvDetail i inner join Appl a on i.Apno= a.apno
inner join precheck.[dbo].[ClientConfiguration] cc on a.CLNO = cc.CLNO and ConfigurationKey = 'RemovePassThruCharges'
where i.Billed = 0 and Type = 2  and Amount <> 0 and Description not  like 'Criminal%' 
order by i.APno


--select * from #PassThru order by APNO


END
