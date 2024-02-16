



CREATE VIEW [dbo].[vwClient]
AS
SELECT TOP (100) PERCENT
       CASE
           WHEN C.AffiliateID = 30 THEN
               NULL
           ELSE
               C.AffiliateID
       END AS AffiliateId,
       CASE
           WHEN (ISNULL(C.AffiliateID, 30) = 30) THEN
               NULL
           ELSE
               RA.Affiliate
       END AS AffiliateName,
       C.CLNO AS ClientId,
       C.Name AS ClientName,
       ISNULL(C.ClientTypeID, 0) AS ClientTypeId,
       ISNULL(T.ClientType, '') AS ClientTypeName,
       C.TaxRate,
       C.GetsEmpl_StudentCheck AS IncludeEmployment,
       C.GetsProfLic_StudentCheck AS IncludeLicense,
       CASE
           WHEN C.ClientTypeID IN ( 6, 7, 8, 11, 13 ) THEN
               ISNULL(C.SchoolWillPay, 1)
           ELSE
               CONVERT(BIT, 1)
       END AS InvoiceSchool,
       C.GetsEdu_StudentCheck AS IncludeEducation,
       CASE
           WHEN (C.WebOrderParentCLNO = C.CLNO OR c.WebOrderParentCLNO=0) THEN
               NULL
           ELSE
               C.WebOrderParentCLNO
       END AS ParentId,
       CASE
           WHEN (C.WebOrderParentCLNO = C.CLNO OR c.WebOrderParentCLNO=0) THEN
               NULL
           ELSE
               PC.[Name]
       END AS Parent,
       IsActiveWebOrderClient = CONVERT(   BIT,
                                           CASE
                                               WHEN ISNULL(C.DescriptiveName, '') = '' THEN
                                                   CONVERT(BIT, 0)
                                               ELSE
                                                   CONVERT(BIT, 1)
                                           END
                                       ),
       CAMName = ISNULL(cam.Name, 'N/A'),
       CAMEmail = ISNULL(cam.EmailAddress, 'N/A'),
       CAMPhone = ISNULL(cam.Phone, '(800) 999-9861'),
	   AccountGroupName=C.[Accounting System Grouping],
	   IsActive=CASE WHEN C.IsInactive=0 THEN 1 ELSE 0 END
FROM dbo.Client AS C
    LEFT OUTER JOIN dbo.refClientType AS T
        ON C.ClientTypeID = T.ClientTypeID
    LEFT OUTER JOIN dbo.Client AS PC
        ON C.WebOrderParentCLNO = PC.CLNO
    LEFT OUTER JOIN dbo.refAffiliate AS RA
        ON C.AffiliateID = RA.AffiliateID
    LEFT OUTER JOIN Users cam
        ON C.CAM = cam.UserID


