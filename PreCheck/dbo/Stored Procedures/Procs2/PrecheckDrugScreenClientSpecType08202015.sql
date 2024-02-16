



--Created on 01-06-2006 get new report 

--[PrecheckDrugScreenClientSpecType] 11340

Create Proc [dbo].[PrecheckDrugScreenClientSpecType08202015]

@client int

As

Declare @ErrorCode int



  SELECT  cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType],c.Name -- Isnull(F.FacilityName, c.Name) Name

  FROM [PreCheck].[dbo].[ClientConfiguration_DrugScreening] cc

  INNER JOIN [PreCheck].[dbo].[Client] c  ON cc.clno=c.clno

 -- Left JOIN HEVN.DBO.Facility F On cc.clno = F.FacilityCLNO

  WHERE cc.CLNO = @client



  




