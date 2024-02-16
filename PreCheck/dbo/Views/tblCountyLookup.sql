Create View dbo.tblCountyLookup
as
SELECT  ZC.[ZIP],City Place
      ,[County]
      ,[PERCENTAGE] PCT,Null RType
      ,Z.[STATE],Null USPSCode,FIPS
      ,NULL OLD, NULL EXTType, NULL [UNIQUE],NULL POP97,NULL TZONE, NULL AREACODE
  FROM [MainDB].[dbo].[ZipCode_County] ZC inner join [MainDB].[dbo].ZipCode Z ON ZC.ZIP = Z.Zip