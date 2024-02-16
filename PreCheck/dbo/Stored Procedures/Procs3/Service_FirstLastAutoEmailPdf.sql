

CREATE PROCEDURE [dbo].[Service_FirstLastAutoEmailPdf] @Apno int AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*
     Jeremiah Soto -updated 6/20/2005
     Email Final Pdf to Client 
     Check firstname and lastname first
     and Lastname,firstname against clientcontacts

     DHE added top 1 to the subquery to avoid more than one returns.
*/

SELECT      distinct dbo.Appl.ApDate, dbo.Appl.Attn, dbo.Appl.ApStatus, dbo.Appl.APNO, dbo.Client.CLNO, dbo.Appl.UserID,(Case when charindex('@',Appl.Attn)>0 then Appl.Attn else contact.email end) Email,
dbo.Appl.[First], dbo.Appl.[Last], dbo.Appl.Middle, dbo.Client.DeliveryMethodID, dbo.refDeliveryMethod.DeliveryMethod, (case when cc.value = 'True' THEN 'support@MyStudentCheck.Net' ELSE ISNULL(dbo.Users.EmailAddress, 
                      'ClientServiceReports@precheck.com') END) AS EmailAddress,dbo.Appl.Attn AS Expr1
FROM         dbo.Appl INNER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO LEFT JOIN
					  dbo.ClientContacts contact on (dbo.Appl.CLNO = contact.CLNO   and len(isnull(contact.email,'')) > 0 
													and   (( charindex('@',Appl.Attn)>0 OR rtrim(ltrim(Appl.Attn)) LIKE rtrim(ltrim(contact.firstName)) + '%' AND  rtrim(ltrim(appl.attn)) LIKE '%' + rtrim(ltrim(contact.lastname)) ) 
															OR ( rtrim(ltrim(Appl.Attn))  LIKE rtrim(ltrim(contact.lastname)) + '%' AND rtrim(ltrim(appl.attn)) LIKE '%' + rtrim(ltrim(contact.firstname))))  )
				INNER JOIN
                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID LEFT OUTER JOIN
                      dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
left join clientconfiguration cc on appl.clno = cc.clno and cc.configurationkey = 'Redirect_Nevada'
WHERE  (dbo.Appl.apno = @apno) 


--Delete below when confirmed that the fix above is working fine - schapyala - 05/13/2015

--SELECT     dbo.Appl.ApDate, dbo.Appl.Attn, dbo.Appl.ApStatus, dbo.Appl.APNO, dbo.Client.CLNO, dbo.Appl.UserID,
--                          isnull((SELECT Top 1 email
--                              FROM         clientcontacts
--                              WHERE    
--                          (clientcontacts.clno = appl.clno) AND (( rtrim(ltrim(Appl.Attn)) LIKE rtrim(ltrim(ClientContacts.firstName)) + '%' AND  rtrim(ltrim(appl.attn)) LIKE '%' + rtrim(ltrim(clientcontacts.lastname)) ) 
--                             OR
--                          ( rtrim(ltrim(Appl.Attn))  LIKE rtrim(ltrim(ClientContacts.lastname)) + '%' AND rtrim(ltrim(appl.attn)) LIKE '%' + rtrim(ltrim(clientcontacts.firstname))))  
--and len(email) > 0),'') AS email, dbo.Appl.[First], 
--                      dbo.Appl.[Last], dbo.Appl.Middle, dbo.Client.DeliveryMethodID, dbo.refDeliveryMethod.DeliveryMethod, (case when cc.value = 'True' THEN 'support@MyStudentCheck.Net' ELSE ISNULL(dbo.Users.EmailAddress, 
--                      'ClientServiceReports@precheck.com') END) AS EmailAddress, dbo.Appl.Attn AS Expr1
--FROM         dbo.Appl INNER JOIN
--                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
--                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID LEFT OUTER JOIN
--                      dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
--left join clientconfiguration cc on appl.clno = cc.clno and cc.configurationkey = 'Redirect_Nevada'
--WHERE    (appl.apno = @apno)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
