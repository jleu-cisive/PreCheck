
-- =============================================
-- Author:		Vairavan  A
-- Create date: 11/17/2022
--Ticket No : 62753
--Ticket Description : New QReport to be called CLNO Change
--Purpose : To display the CLNO changed for all report in the Audit Reports, using date range & @AffiliateID as parameters.
--Unittesting
--EXEC [dbo].[Qreport_ClnoChange] '11/01/2022','11/18/2022','0'
--EXEC [dbo].[Qreport_ClnoChange] '08/01/2022','11/18/2022','30:198'
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_clnochange] 
@StartDate    DATETIME  NULL,
@EndDate      DATETIME  NULL,
@AffiliateIDs VARCHAR(max) = '0'
AS
  BEGIN
      SET nocount ON;
	  
	  
	  If cast(@EndDate as float) - cast(@StartDate as float) <= 92
	  Begin

      IF @AffiliateIDs = '0'
        BEGIN
            SET @AffiliateIDs = NULL
        END

      SELECT b.[clno]        AS [CLNO],
             a.[id]          AS [ReportNo],
             c.[name]        AS [ClientName],
             c.[affiliateid] AS [Affiliateid],
             [oldvalue],
             [newvalue],
             [changedate],
             b.[apdate]      AS [Appdate],
             a.[userid],
             b.[enteredvia]  AS [EnteredVia],
             b.[priv_notes]  AS [Priv_Notes]
      FROM   [dbo].[changelog] a WITH(nolock)
             INNER JOIN [dbo].[appl] b WITH(nolock)
                     ON ( 
						  a.[ChangeDate] >= @StartDate
						  AND a.[id] = b.[apno]
                          AND a.[tablename] = 'Appl.CLNO'
                          AND ( @StartDate IS NULL
                                 OR b.[apdate] >= @StartDate
                                    AND b.[apdate] < Dateadd(day, 1, @EndDate) )
                        )
             INNER JOIN [dbo].[client] c WITH(nolock)
                     ON( b.[clno] = c.[clno]
                         AND (( @AffiliateIDs IS NULL
                                 OR affiliateid IN (SELECT value
                                                    FROM   Fn_split(
                                                   @AffiliateIDs,
                                                           ':'
                                                           )) )) )

      end
	  else  if cast(@EndDate as float) - cast(@StartDate as float) > 92
	  begin
		Select 'This report can not be executed for a period longer than 92 days' As Errordescription
		      --'This report can not be executed for a period longer than 92 days'     AS [CLNO],
        --   NULL       AS [ReportNo],
        --  NULL     AS [ClientName],
        --    NULL  AS [Affiliateid],
        --    NULL As  [oldvalue],
        --  NULL As    [newvalue],
        -- NULL As     [changedate],
        --  NULL     AS [Appdate],
        --    NULL  as     [userid],
        --      NULL  AS [EnteredVia],
        --      NULL   AS [Priv_Notes]
		--raisError (15600, -1, -1, 'This report can not be executed for a period longer than 92 days')
		-- You'll still need this next line (return), otherwise it will continue to run, please make sure you test everything both in SSMS and in the app before posting for review, thanks!
		--return 
	 End
	 

  END 