	CREATE view [Enterprise].[vwCountryStateCity] AS
		SELECT 'USA' AS Name,'Country' As [Type], NULL AS ParentName
		UNION ALL
		SELECT STATE AS Name,'State' AS [Type], 'USA' AS ParentName FROM [MainDB].[dbo].ZipCode WHERE TimeZone IS NOT NULL GROUP BY STATE
		UNION ALL
		SELECT CITY AS Name,'City' AS [Type], STATE AS ParentName FROM [MainDB].[dbo].ZipCode WHERE TimeZone IS NOT NULL
