-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/11/2020
-- Description:	Get all the USERID's for a given data range for 
-- Employment department
-- =============================================
CREATE PROCEDURE [dbo].[Employment_Investigators]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SET @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate))

	
	DROP TABLE IF EXISTS #temp1
	DROP TABLE IF EXISTS #temp2
	DROP TABLE IF EXISTS #temp3
	DROP TABLE IF EXISTS #tempUsersList

    -- Insert statements for procedure here
SELECT *, 't1' src INTO #temp1
  FROM ( 
		SELECT ROW_NUMBER() OVER (PARTITION BY c.[ID], CONVERT(DATE, c.[ChangeDate]) order by c.[ChangeDate] desc) rn, c.[ID],
			 CASE WHEN wkids.[sectionkeyid] is null then 
			 CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) END    -- no work number ..
				  ELSE (CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'      -- work number from Integration_Verification_SourceCode
			 END [UserID],
			 c.[ChangeDate],
			 c.[NewValue] [Value]
       FROM dbo.ChangeLog c 
	   LEFT OUTER JOIN ( SELECT sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock) 
							WHERE refVerificationSource = 'WorkNumber' 
						  and DateTimStamp between @StartDate and @EndDate
                       ) wkids ON c.[ID] = wkids.[sectionkeyid]
		WHERE c.[TableName] = 'Empl.sectstat' and c.ChangeDate between @StartDate and @EndDate
     ) a
WHERE a.[rn] = 1

SELECT  * , 't2' src into #temp2
	FROM ( SELECT ROW_NUMBER() over (partition by c.[ID], Convert(date, c.[ChangeDate]) order by c.[ChangeDate] desc) rn,c.[ID],
				CASE WHEN wkids.[sectionkeyid] is null then                            
				CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end -- no work number ..
					 ELSE (case when len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'      -- work number from Integration_Verification_SourceCode
					  END [UserID],
				c.[ChangeDate],c.[NewValue] [Value]
		  FROM dbo.ChangeLog c 
		  LEFT OUTER JOIN (SELECT  sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock)
							WHERE refVerificationSource = 'WorkNumber' 
								and DateTimStamp between @StartDate and @EndDate
						  ) wkids ON c.[ID] = wkids.[sectionkeyid]
		  WHERE c.[TableName] = 'Empl.web_status' and c.ChangeDate between @StartDate and @EndDate
     ) a
WHERE a.[rn] = 1

SELECT * , 't3' src into #temp3
  FROM (SELECT ROW_NUMBER() over (partition by c.[ID], Convert(date, c.[ChangeDate]) order by c.[ChangeDate] desc) rn,c.[ID],
                     CASE WHEN wkids.[sectionkeyid] is null then
					 CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end     -- no work number ..
                          ELSE (case when len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'   -- work number from Integration_Verification_SourceCode
                     END [UserID],
                      c.[ChangeDate], c.[NewValue] [Value]
         FROM dbo.ChangeLog c 
         LEFT OUTER JOIN ( SELECT sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock)
							WHERE  refVerificationSource = 'WorkNumber' 
							and DateTimStamp between @StartDate and @EndDate							 
						  ) wkids ON c.[ID] = wkids.[sectionkeyid]
         WHERE ( c.[TableName] = 'Empl.priv_notes' or c.TableName = 'Empl.pub_notes') and c.ChangeDate between @StartDate and @EndDate
       ) a
WHERE a.[rn] = 1


SELECT DISTINCT USERID INTO #tempUsersList
FROM 
(
	SELECT DISTINCT USERID FROM #temp1
		UNION ALL
	SELECT DISTINCT USERID FROM #temp2
		UNION ALL
	SELECT DISTINCT USERID FROM #temp3
) a

SELECT * FROM #tempUsersList WHERE USERID NOT IN (SELECT USERID FROM #tempUsersList WHERE UserID like '%(WKN)%')


END
