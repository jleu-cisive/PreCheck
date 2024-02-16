-- =======================================================================================================
-- Created by  : Vairavan A
-- Create date : 07/03/2023
-- Ticket no   : 99523 
-- Description : Create new report for reopened BG's.(This procedure will be called when initiated by user action from Qreport application.)
/*---Testing
EXEC [dbo].[BackgroundReports_Reopened] '1629:1934';
EXEC [dbo].[BackgroundReports_Reopened] NULL;
EXEC [dbo].[BackgroundReports_Reopened1] '';
*/
-- =======================================================================================================

CREATE PROCEDURE dbo.Backgroundreports_reopened1
@Clno VARCHAR(max) = ''
AS
  BEGIN
      SET nocount ON;

      IF Object_id('tempdb..#Temp_AppInfo') IS NOT NULL
        DROP TABLE #temp_appinfo;

      IF Object_id('tempdb..#Apno_synced') IS NOT NULL
        DROP TABLE #apno_synced;

      IF( @Clno = ''
           OR Lower(@Clno) = 'null'
           OR @Clno = '0' )
        BEGIN
            SET @Clno = NULL
        END

      --Get the list of Apps which have been Reopened by Clno input by the user
      SELECT A.clno       AS 'Client ID',
             A.apno       AS 'Report Number',
             A.apstatus   AS App_Status,
             A.apdate     AS 'Date Created',
             A.reopendate AS 'Date Reopened',
             A.compdate   AS 'Date Complete',
             A.isautoprinted
      INTO   #temp_appinfo
      FROM   appl A WITH(nolock)
             INNER JOIN client Cl WITH(nolock)
                     ON A.clno = Cl.clno
      WHERE  A. reopendate IS NOT NULL
             AND ( @CLNO IS NULL
                    OR Cl.clno IN (SELECT value
                                   FROM   Fn_split(@CLNO, ':')) )
DECLARE @SQL nvarchar(max)
 

 
 if @@SERVERNAME = 'ALA-BI-01'
 begin
 

	SET @SQL = '
		  SELECT apno,
				 Cast(NULL AS DATETIME) AS [BackgroundReport Date]
		  INTO   ##apno_synced
		  FROM   [ALA-DB-01].[BackgroundReports].[dbo].[backgroundreport] WITH(nolock)--5771851
		  INTERSECT
		  SELECT [report number],
				 Cast(NULL AS DATETIME) AS [BackgroundReport Date]
		  FROM   #temp_appinfo

		  UPDATE a
		  SET    a.[backgroundreport date] = b.createdate
		  FROM   ##apno_synced a
				 INNER JOIN (SELECT apno,
									Max (createdate) AS createdate
							 FROM   [ALA-DB-01].[BackgroundReports].[dbo].[backgroundreport]
									WITH(
									nolock)
							 GROUP  BY apno) b
						 ON( a.apno = b.apno )

		  SELECT a.*,
				 b.[backgroundreport date]
		  FROM   #temp_appinfo a
				 INNER JOIN ##apno_synced b
						 ON( a.[report number] = b.apno )'

	EXEC (@SQL)

	Drop table if exists ##apno_synced 

end
else 
begin

	SET @SQL = '
		  SELECT apno,
				 Cast(NULL AS DATETIME) AS [BackgroundReport Date]
		  INTO   ##apno_synced
		  FROM   [BackgroundReports].[dbo].[backgroundreport] WITH(nolock)--5771851
		  INTERSECT
		  SELECT [report number],
				 Cast(NULL AS DATETIME) AS [BackgroundReport Date]
		  FROM   #temp_appinfo

		  UPDATE a
		  SET    a.[backgroundreport date] = b.createdate
		  FROM   ##apno_synced a
				 INNER JOIN (SELECT apno,
									Max (createdate) AS createdate
							 FROM   [BackgroundReports].[dbo].[backgroundreport]
									WITH(
									nolock)
							 GROUP  BY apno) b
						 ON( a.apno = b.apno )

		  SELECT a.*,
				 b.[backgroundreport date]
		  FROM   #temp_appinfo a
				 INNER JOIN ##apno_synced b
						 ON( a.[report number] = b.apno )'

	EXEC (@SQL)

	Drop table if exists ##apno_synced 
end

    SET nocount OFF;
  END 
