CREATE PROCEDURE Iris_CrimsReadytoOrder AS

SELECT     Crim.Clear, Appl.ApStatus, Crim.Ordered, Crim.CrimID, Crim.readytosend, Appl.APNO, irisordered,
                   Crim.Crimenteredtime, Crim.CNTY_NO, Crim.IRIS_REC, Crim.batchnumber, Crim.deliverymethod
FROM         Crim INNER JOIN
                      Appl ON Crim.APNO = Appl.APNO
WHERE     (Appl.ApStatus = 'p' OR
                      Appl.ApStatus = 'w') AND (Crim.Clear = 'R')
ORDER BY Appl.APNO