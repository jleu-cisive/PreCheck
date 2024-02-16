
CREATE PROCEDURE [dbo].[M_Client_Members] AS

--Intranet Report Members(clients)
select clno,name,addr1,city,state,zip from client with (nolock) where billingstatusid = 1
and nonclient <> 1
