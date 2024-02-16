	CREATE view [Enterprise].[vwZip] AS
		SELECT Z.ZIP AS Zip, Z.STATE AS State, Z.CITY AS City
		FROM [MainDB].[dbo].ZipCode AS Z(NOLOCK) 
		INNER JOIN [MainDB].[dbo].[ZipCode_County] AS ZC ON ZC.ZIP = Z.ZIP
