CREATE PROCEDURE Service_FirstLastAutoWebPickup @Apno int AS


/*
     Email Final Pdf to Client 
    Check firstname and lastname first
 and Lastname,firstname against clientcontacts
*/


SELECT appl.apdate,appl.attn,appl.apstatus,Appl.APNO, client.clno,
              appl.first,appl.last,appl.middle,Client.DeliveryMethodID,
              refDeliveryMethod.DeliveryMethod, 
              ClientContacts.Email,ClientContacts.FirstName, 
              ClientContacts.MiddleName, ClientContacts.LastName,appl.attn
FROM    Appl INNER JOIN
              Client ON Appl.CLNO = Client.CLNO INNER JOIN
              refDeliveryMethod ON Client.DeliveryMethodID = refDeliveryMethod.DeliveryMethodID 
               INNER JOIN
               ClientContacts ON Client.CLNO = ClientContacts.CLNO
WHERE  (appl.apno = @apno) AND 
                ((Appl.Attn LIKE ClientContacts.firstName + '%')and(appl.attn like '%' + clientcontacts.lastname)
                    or(Appl.Attn LIKE  ClientContacts.lastname + '%' and appl.attn like '%' + clientcontacts.firstname))
                AND (refDeliveryMethod.DeliveryMethod = 'WILL PRINT FROM WEB')