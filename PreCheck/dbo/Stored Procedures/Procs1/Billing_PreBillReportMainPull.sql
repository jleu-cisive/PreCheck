


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PreBillReportMainPull]
	-- Add the parameters for the stored procedure here
	@CutOffDate datetime,@BillingCycle varchar(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--    SELECT D.APNO , D.AMOUNT ,  D.DESCRIPTION , D.Type, D.InvDetID
--      ,   APPL.APSTATUS ,  APPL.LAST , APPL.FIRST , APPL.MIDDLE
--      , APPL.COMPDATE ,  APPL.CLNO, appl.update_billing, APPL.DeptCode
--      , CLIENT.NAME ,  CLIENT.ADDR1 , CLIENT.ADDR2 ,
--       CLIENT.CITY, CLIENT.STATE, CLIENT.ZIP , CLIENT.TAXRATE ,  CLIENT.IsTaxExempt  ,
-- refBC.BillingCycle as BillingCycle FROM InvDetail D WITH (NOLOCK), APPL APPL WITH (NOLOCK),  CLIENT CLIENT WITH (NOLOCK),
--  refBillingCycle refBC WITH (NOLOCK) WHERE ( D.APNO = APPL.APNO )   AND  ( APPL.CLNO = CLIENT.CLNO ) 
--        AND  ( ( ( D.Billed = 0 ) AND   ( ( ( APPL.APSTATUS = 'F' ) 
--        AND ( APPL.COMPDATE < @CutOffDate ) )  OR ( APPL.APSTATUS =  'W'
--       ) ) AND   ( refBC.BillingCycleID = client.BillingCycleID) AND 
--        (refBC.BILLingCYCLE = @BillingCycle) )  ) ORDER BY APPL.CLNO ,
-- appl.last, appl.first, appl.middle, appl.apno , D.TYPE


    SELECT D.APNO , D.AMOUNT ,  D.DESCRIPTION , D.Type, D.InvDetID
      ,   APPL.APSTATUS ,  APPL.LAST , APPL.FIRST , APPL.MIDDLE
      , APPL.COMPDATE ,  APPL.CLNO, appl.update_billing, APPL.DeptCode
      , CLIENT.NAME ,  CLIENT.ADDR1 , CLIENT.ADDR2 ,
       CLIENT.CITY, CLIENT.STATE, CLIENT.ZIP , CLIENT.TAXRATE ,  CLIENT.IsTaxExempt  , refBC.BillingCycle as 'BillingCycle'
 FROM InvDetail D WITH (NOLOCK)
inner join  APPL APPL WITH (NOLOCK) on  D.APNO = APPL.APNO  
inner join  CLIENT CLIENT WITH (NOLOCK) on APPL.CLNO = CLIENT.CLNO 
  inner join refBillingCycle refBC WITH (NOLOCK) on refBC.BillingCycleID = client.BillingCycleID
WHERE 
        ( D.Billed = 0 ) AND  
 ( (  APPL.APSTATUS = 'F' AND  APPL.COMPDATE < @CutOffDate  )  OR ( APPL.APSTATUS =  'W') ) 
AND   (refBC.BILLingCYCLE = @BillingCycle) 

ORDER BY APPL.CLNO ,appl.last, appl.first, appl.middle, appl.apno , D.TYPE




SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END






