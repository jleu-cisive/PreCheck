CREATE PROCEDURE [dbo].[Service_CheckAttnMatch] @apno int  AS

SELECT count(distinct clientcontacts.firstname + '' + clientcontacts.lastname)
FROM  dbo.Appl  WITH (NOLOCK)
INNER JOIN dbo.ClientContacts WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.ClientContacts.CLNO
WHERE
(dbo.Appl.APNO = @apno) AND 
((rtrim(ltrim(dbo.Appl.Attn)) LIKE rtrim(ltrim(dbo.ClientContacts.FirstName)) + '%' 
AND rtrim(ltrim(dbo.Appl.Attn)) LIKE '%' + rtrim(ltrim(dbo.ClientContacts.LastName))) 
OR
(rtrim(ltrim(dbo.Appl.Attn)) LIKE rtrim(ltrim(dbo.ClientContacts.LastName)) + '%' 
AND rtrim(ltrim(dbo.Appl.Attn)) LIKE '%' + ltrim(rtrim(dbo.ClientContacts.FirstName))
))
--and len(email)>0