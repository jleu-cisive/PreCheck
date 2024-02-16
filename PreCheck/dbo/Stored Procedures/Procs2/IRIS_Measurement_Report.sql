

-- =============================================
-- Modified By:		DEEPAK VODETHELA
-- Create date: 11/30/2020
-- DescriptiON:	Iris Measurement Report
-- EXEC IRIS_Measurement_Report '11/30/2020','11/30/2020'
-- EXEC IRIS_Measurement_Report NULL,NULL,NULL,NULL,0,0,NULL,NULL
-- =============================================
CREATE PROCEDURE [dbo].[IRIS_Measurement_Report]
    -- Add the parameters for the stored procedure here
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @Investigator VARCHAR(8) = NULL,
    @Category VARCHAR(20) = NULL,
    @CategoryID INT = 0,
    @CLNO INT = 0,
    @State VARCHAR(20) = NULL,
    @County VARCHAR(50) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering WITH SELECT statements.
    SET NOCOUNT ON;
    IF (@StartDate IS NULL AND @EndDate IS NULL)
    BEGIN
        SET @StartDate = CAST(GETDATE() AS DATE);
        SET @EndDate = @StartDate;
    END;

    -- Insert statements for procedure here
    SELECT @CategoryID = ResultLogCategoryID
    FROM dbo.IRIS_ResultLogCategory
    WHERE ResultLogCategory = @Category;
    SET @CategoryID = ISNULL(@CategoryID, 0);

    IF (@Investigator IS NULL)
    BEGIN
        SELECT DISTINCT
               Investigator,
               Category,
               Status,
               RecordCount
        FROM
        (
            SELECT DISTINCT
                   i.Investigator,
                   (
                       SELECT ResultLogCategory
                       FROM dbo.IRIS_ResultLogCategory WITH (NOLOCK)
                       WHERE ResultLogCategoryID = i.ResultLogCategoryID
                   ) AS Category,
                   CASE
                       WHEN i.Clear = 'T' THEN
                           'Clear'
                       WHEN i.Clear = 'F' THEN
                           'Record Found'
                       WHEN i.Clear = 'P' THEN
                           'Possible Record'
                       WHEN i.Clear = 'Q' THEN
                           'Needs QA'
                       WHEN i.Clear = 'I' THEN
                           'Needs Research'
                       ELSE
                           'Ordered'
                   END AS Status,
                   COUNT(ResultLogID) AS RecordCount
            FROM dbo.IRIS_ResultLog i WITH (NOLOCK)
                INNER JOIN Crim c WITH (NOLOCK)
                    ON i.CrimID = c.CrimID
                INNER JOIN counties cc WITH (NOLOCK)
                    ON cc.CNTY_NO = c.CNTY_NO
                LEFT OUTER JOIN Appl a WITH (NOLOCK)
                    ON i.APNO = a.APNO
            WHERE i.Clear IN ( 'T', 'F', 'Q', 'I', 'P' )
                  AND i.LogDate >= @StartDate
                  AND i.LogDate < DATEADD(DAY, 1, @EndDate)
                  AND i.ResultLogCategoryID = IIF(@CategoryID = 0, i.ResultLogCategoryID, @CategoryID)
                  AND a.CLNO = IIF(@CLNO = 0, a.CLNO, @CLNO)
                  AND cc.State = ISNULL(@State, cc.State)
                  AND c.County = ISNULL(@County, c.County)
            GROUP BY i.Investigator,
                     i.ResultLogCategoryID,
                     i.Clear
            UNION ALL
            SELECT DISTINCT
                   cl.UserID AS Investigator,
                   'OASIS' AS Category,
                   CASE
                       WHEN cl.NewValue = 'B' THEN
                           'Clear Internal'
                   END AS Status,
                   COUNT(cl.UserID) AS RecordCount
            FROM dbo.ChangeLog AS cl (NOLOCK)
                INNER JOIN Crim c WITH (NOLOCK)
                    ON cl.ID = c.CrimID
                INNER JOIN counties cc WITH (NOLOCK)
                    ON c.CNTY_NO = cc.CNTY_NO
                LEFT OUTER JOIN Appl a WITH (NOLOCK)
                    ON a.APNO = c.APNO
            WHERE TableName = 'Crim.Clear'
                  AND
                  (
                      cl.ChangeDate >= @StartDate
                      AND cl.ChangeDate <= DATEADD(s, -1, DATEADD(d, 1, @EndDate))
                  )
                  AND cl.NewValue = 'B'
                  AND a.CLNO = IIF(@CLNO = 0, a.CLNO, @CLNO)
                  AND cc.State = ISNULL(@State, cc.State)
                  AND c.County = ISNULL(@County, c.County)
            GROUP BY cl.UserID,
                     cl.NewValue
        ) AS Result
        ORDER BY Investigator;
    END;

    ELSE
    BEGIN

        SELECT DISTINCT
               Investigator,
               Category,
               Status,
               RecordCount
        FROM
        (
            SELECT DISTINCT
                   i.Investigator,
                   (
                       SELECT ResultLogCategory
                       FROM dbo.IRIS_ResultLogCategory WITH (NOLOCK)
                       WHERE ResultLogCategoryID = i.ResultLogCategoryID
                   ) AS Category,
                   CASE
                       WHEN i.Clear = 'T' THEN
                           'Clear'
                       WHEN i.Clear = 'F' THEN
                           'Record Found'
                       WHEN i.Clear = 'P' THEN
                           'Possible Record'
                       WHEN i.Clear = 'Q' THEN
                           'Needs QA'
                       WHEN i.Clear = 'I' THEN
                           'Needs Research'
                       ELSE
                           'Ordered'
                   END AS Status,
                   COUNT(ResultLogID) AS RecordCount
            FROM dbo.IRIS_ResultLog i WITH (NOLOCK)
                INNER JOIN Crim c WITH (NOLOCK)
                    ON i.CrimID = c.CrimID
                INNER JOIN counties cc WITH (NOLOCK)
                    ON cc.CNTY_NO = c.CNTY_NO
                LEFT OUTER JOIN Appl a WITH (NOLOCK)
                    ON i.APNO = a.APNO
            WHERE i.Clear IN ( 'T', 'F', 'Q', 'I', 'P' )
                  AND i.LogDate >= @StartDate
                  AND i.LogDate < DATEADD(DAY, 1, @EndDate)
                  AND i.Investigator = @Investigator
                  AND i.ResultLogCategoryID = IIF(@CategoryID = 0, i.ResultLogCategoryID, @CategoryID)
                  AND a.CLNO = IIF(@CLNO = 0, a.CLNO, @CLNO)
                  AND cc.State = ISNULL(@State, cc.State)
                  AND c.County = ISNULL(@County, c.County)
            GROUP BY i.Investigator,
                     i.ResultLogCategoryID,
                     i.Clear
            UNION ALL
            SELECT DISTINCT
                   cl.UserID AS Investigator,
                   'OASIS' AS Category,
                   CASE
                       WHEN cl.NewValue = 'B' THEN
                           'Clear Internal'
                   END AS Status,
                   COUNT(cl.UserID) AS RecordCount
            FROM dbo.ChangeLog AS cl (NOLOCK)
                INNER JOIN Crim c WITH (NOLOCK)
                    ON cl.ID = c.CrimID
                INNER JOIN counties cc WITH (NOLOCK)
                    ON c.CNTY_NO = cc.CNTY_NO
                LEFT OUTER JOIN Appl a WITH (NOLOCK)
                    ON a.APNO = c.APNO
            WHERE TableName = 'Crim.Clear'
                  AND
                  (
                      cl.ChangeDate >= @StartDate
                      AND cl.ChangeDate <= DATEADD(s, -1, DATEADD(d, 1, @EndDate))
                  )
                  AND cl.NewValue = 'B'
                  AND cl.UserID = @Investigator
                  AND a.CLNO = IIF(@CLNO = 0, a.CLNO, @CLNO)
                  AND cc.State = ISNULL(@State, cc.State)
                  AND c.County = ISNULL(@County, c.County)
            GROUP BY cl.UserID,
                     cl.NewValue
        ) AS Result
        ORDER BY Investigator;
    END;

END;
