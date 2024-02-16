
CREATE procedure [dbo].[GetContactsByClient](@clientid int)
as
select clno,contacttype,firstname,middlename,lastname,phone,email,username from ClientContacts where clno = @clientid

