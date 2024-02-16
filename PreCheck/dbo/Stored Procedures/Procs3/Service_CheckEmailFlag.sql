CREATE PROCEDURE [dbo].[Service_CheckEmailFlag] @clno int, @AttnEmail varchar(50) 
AS


-- In addition to sending the attn contact's email 
-- this will also check if there are additional contacts that
-- need to receive report 

     select email from clientcontacts WITH (NOLOCK) where 
     (clno = @clno) and (GetsReport = '1') 
      and (email <> @AttnEmail) 
     and (Email is not null)