
CREATE view [dbo].[counties]


as



SELECT [CNTY_NO]
      ,[County]
      ,[Crim_Source]
      ,[Crim_Phone]
      ,[Crim_Fax]
      ,[Crim_Addr]
      ,[Crim_Comment]
      ,[Crim_DefaultRate]
      ,[Civ_Source]
      ,[Civ_Phone]
      ,[Civ_Fax]
      ,[Civ_Addr]
      ,[Civ_Comment]
      ,[State]
      ,[A_County]
      ,[Country]
      ,[PassThroughCharge]
      ,[isStatewide]
      ,[FIPS]
      ,[refCountyTypeID]
      ,[IsActive]
      ,[CreateDate]
      ,[ModifyDate]
      ,[CreatedBy]
      ,[ModifiedBy]
  FROM [dbo].[TblCounties]
  where [IsActive] = 1

