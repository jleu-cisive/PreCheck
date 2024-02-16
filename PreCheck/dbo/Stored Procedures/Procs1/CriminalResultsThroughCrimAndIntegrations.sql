-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.CriminalResultsThroughCrimAndIntegrations
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate  datetime
AS
BEGIN
	DECLARE 
@varspace varchar(10),
@var1c int,
@var1cni int,
@var1r int,
@var1riu int,
@var1u int,
@var2c int,
@var2r int,
@var2u int

Declare @countTable table
(
 Type varchar(50),
 Integration_Results varchar(50),
 Criminal_Website_Results varchar(50)
)




SET @varspace = ' ';




-- INTEGRATION
-- record cleared by investigator
SELECT  @var1c =      count(  distinct c.CrimID) 
FROM            crim c
inner join IRIS_ResultLog t on t.crimid = c.CrimID
WHERE        ((Convert(date, c.CreatedDate) >= CONVERT(date, @StartDate)) AND
                         (Convert(date, c.CreatedDate) <= CONVERT(date, @EndDate))) and 
             c.Clear = 'T' 
			 and t.clear = 'V' 
			 and t.ResultLogCategoryID = 7
			 
-- record cleared total
SELECT  @var1cni =      count(  distinct crim_id) 
FROM            iris_ws_screening 
WHERE        ((Convert(date, created_on) >= CONVERT(date, @StartDate)) AND
                         (Convert(date, created_on) <= CONVERT(date, @EndDate))) and 
             result_status = 'clear'
SELECT  @var1cni = @var1cni - @var1c -- record cleared no investigator



-- record found active
SELECT  @var1r =   count(  distinct crim_id) 
FROM            iris_ws_screening i
inner join crim c on c.crimid = i.crim_id
WHERE        ((Convert(date, i.created_on) >= CONVERT(date, @StartDate)) AND
                         (Convert(date, i.created_on) <= CONVERT(date, @EndDate)))
             and 
             i.result_status = 'hit' and c.IsHidden = 1 -- true

-- record found in unused
SELECT  @var1riu =      count(  distinct crim_id) 
FROM            iris_ws_screening i
inner join crim c on c.crimid = i.crim_id
WHERE        ((Convert(date, i.created_on) >= CONVERT(date, @StartDate)) AND
                         (Convert(date, i.created_on) <= CONVERT(date, @EndDate)))
             and 
             i.result_status = 'hit' and c.IsHidden = 0 -- false


--unspecified/other records
SELECT  @var1u =      count( distinct crim_id) 
FROM            iris_ws_screening
WHERE        ((Convert(date, created_on) >= CONVERT(DATETIME, @StartDate)) AND
                         (Convert(date, created_on) <= CONVERT(date, @EndDate)))
             and 
             result_status = 'unspecified'



--CRIM WEBSITE
-- records cleared
SELECT @var2c = COUNT(*) 
FROM (
    SELECT NULL AS [EMPTY]
    FROM [CriminalVendor_Log] AS [t0]
    WHERE ((Convert(date, [t0].[Last_Updated])>= CONVERT(date, @StartDate)) 
  AND (Convert(date, [t0].[Last_Updated]) <= CONVERT(date, @EndDate))) and 
  clear = 'T'
    GROUP BY [t0].[APNO], [t0].[CNTY_NO]
    ) AS [t1]

--records found
SELECT @var2r = COUNT(*) 
FROM (
    SELECT NULL AS [EMPTY]
    FROM [CriminalVendor_Log] AS [t0]
    WHERE ((Convert(date, [t0].[Last_Updated]) >= CONVERT(date, @StartDate)) 
  AND (Convert(date, [t0].[Last_Updated]) <= CONVERT(date, @EndDate))) and 
  clear = 'V'
    GROUP BY [t0].[APNO], [t0].[CNTY_NO]
    ) AS [t1]

-- records unspecified
SELECT @var2u = COUNT(*) 
FROM (
    SELECT NULL AS [EMPTY]
    FROM [CriminalVendor_Log] AS [t0]
    WHERE ((Convert(date, [t0].[Last_Updated])>= CONVERT(date, @StartDate)) 
  AND (Convert(date, [t0].[Last_Updated]) <= CONVERT(date, @EndDate))) and 
  (clear != 'T' and clear != 'V')
    GROUP BY [t0].[APNO], [t0].[CNTY_NO]
    ) AS [t1]

 
 
 insert into @countTable values ('Record Found(Actively in Report)', @var1r, @var2r);
 insert into @countTable values ('Record Found(Moved to Unused)', @var1riu, null);
 insert into @countTable values ('Clear (by investigator)', @var1c, null);
  insert into @countTable values ('Remaining Clear (All other clears)', @var1cni, @var2c);
 insert into @countTable values ('Other', @var1u, @var2u);
 insert into @countTable values ('Total', @var1c + @var1cni +  @var1r + @var1riu + @var1u,  @var2c + @var2r + @var2u);
 select * from @countTable;
END
