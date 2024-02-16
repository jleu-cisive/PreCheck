-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 06/03/2014
-- Description:	Gets the client list
-- =============================================
CREATE PROCEDURE [dbo].[PrecheckFramework_GetClientList] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

      select 
		   clno,
		   name,		  
		   case when IsOnCreditHold = 1 then cast(1 as bit)
			   WHEN c.BillingStatusID<>1 THEN cast(1 as bit)
				else IsInActive end as IsInActive,
		   case when IsInActive = 1 then 'InActive'
				when (BillingStatusID = 3 or IsOnCreditHold=1) then 'Credit Hold'
				when IsInActive = 0 and BillingStatusID = 1 then 'Active' 
				WHEN c.BillingStatusID=2 THEN 'InActive'
				end as Status		   						
	from dbo.Client c		
		
END





