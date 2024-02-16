/*
New Qreport titled "ZipCrim Credentialing Monitoring And Lookup"
Ticket - #60367 ZipCrim Credentialing Monitoring And Lookup

Exec [dbo].[ZipCrim_Credentialing_Monitoring_And_Lookup]
*/

CREATE PROCEDURE [dbo].[ZipCrim_Credentialing_Monitoring_And_Lookup]  AS
SET NOCOUNT ON
Select C.ZipCrimClientID,C.CLNO,(zcwos.PartnerReference + '-' + map.ExternalId) as LeadNum,A.Last, A.First,A.Apno AS PreCheck_APNO,A.Startdate,-- Lic.ProfLicId,Lic.Lic_Type,
(SELECT COUNT(1) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')) AS ProfLic_Count,
(SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')) AS Medinteg_Count 
FROM Appl A with (nolock)
JOIN Client C  with (nolock) ON A.Clno = C.Clno
inner join  [dbo].[ZipCrimWorkOrders] zcwo on zcwo.apno = A.apno
inner join [dbo].[ZipCrimWorkOrdersStaging] zcwos on zcwos.workorderid = zcwo.workorderid
inner join [dbo].[PreCheckZipCrimComponentMap] map on map.apno = zcwo.apno
--inner join [dbo].[ProfLic] lic on lic.apno = a.apno
WHERE (A.ApStatus IN ('P','W')) and 
a.CLNO in (17480) Order By Medinteg_Count,ProfLic_Count Desc