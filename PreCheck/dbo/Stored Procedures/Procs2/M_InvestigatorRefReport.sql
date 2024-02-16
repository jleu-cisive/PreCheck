CREATE PROCEDURE M_InvestigatorRefReport   as 

---------- PERSONAL REFERENCE REPORT

SELECT DISTINCT e.Investigator,e.persrefid, A.APNO,
                          (SELECT     COUNT(*)
                            FROM          persref
                            WHERE    (persref.persrefid = e.persrefid) AND (persref.SectStat = '5') AND (persref.investigator = e.Investigator)) AS Verified,
                          (SELECT     COUNT(*)
                            FROM          persref
                            WHERE      (persref.persrefid = e.persrefid) AND (persref.SectStat = '6') AND (persref.investigator = e.Investigator)) AS Unverified_Attached,
                          (SELECT     COUNT(*)
                            FROM          persref
                            WHERE    (persref.persrefid = e.persrefid) AND (persref.SectStat = '7') AND (persref.investigator = e.Investigator)) AS Alert_attached,
                          (SELECT     COUNT(*)
                            FROM          persref
                            WHERE     (persref.persrefid = e.persrefid) AND (persref.SectStat ='8') AND (persref.investigator = e.Investigator)) AS See_attached
                         
FROM         dbo.Appl A INNER JOIN
                      dbo.persref e ON A.APNO = e.Apno
where  (A.ApStatus IN ('P','W')) and (e.investigator is not null) and (e.sectstat <> '9')