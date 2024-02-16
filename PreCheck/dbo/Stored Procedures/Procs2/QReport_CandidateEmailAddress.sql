/***************************************************************************************************
Procedure:          dbo.QReport_CandidateEmailAddress
Create Date:        2023-12-18  
Author:             Cameron DeCook
Description:        Provides Candidate Email address for Pending Cases
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2023-12-18          Cameron DeCook      Initial Creation
***************************************************************************************************/
CREATE PROC dbo.QReport_CandidateEmailAddress
    @CLNO VARCHAR(MAX) = '0',
    @AffiliateID VARCHAR(MAX) = '0'
AS
BEGIN

    SET NOCOUNT ON;


    IF (@CLNO = '0' OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO = '')
    BEGIN
        SET @CLNO = '0';
    END;
    IF (
           @AffiliateID = ''
           OR LOWER(@AffiliateID) = 'null'
           OR @AffiliateID = '0'
       )
    BEGIN
        SET @AffiliateID = NULL;
    END;

    SELECT a.APNO,
           a.Email AS [Applicant Email]
    FROM dbo.Appl a WITH (NOLOCK)
        INNER JOIN dbo.Client c WITH (NOLOCK)
            ON a.CLNO = c.CLNO
        INNER JOIN dbo.refAffiliate ra WITH (NOLOCK)
            ON c.AffiliateID = ra.AffiliateID
    WHERE a.ApStatus = 'P'
          AND
          (
              @CLNO = '0'
              OR c.CLNO IN
                 (
                     SELECT value FROM fn_Split(@CLNO, ':')
                 )
          )
          AND
          (
              @AffiliateID IS NULL
              OR ra.AffiliateID IN
                 (
                     SELECT value FROM fn_Split(@AffiliateID, ':')
                 )
          )
          --AND c.CLNO = IIF(@CLNO = '0', c.CLNO, @CLNO);


END;
