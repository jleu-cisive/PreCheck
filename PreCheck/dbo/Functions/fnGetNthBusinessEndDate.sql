CREATE function [dbo].[fnGetNthBusinessEndDate]
(
     @StartDate datetime = null,
     @NthDay int
) 
returns datetime
 as
BEGIN
   declare @NthBusinessDate  DATETIME

   
   
   SELECT  @NthBusinessDate = MainDB.dbo.[fnGetNthBusinessEndDate]( @StartDate,@NthDay)

   RETURN @NthBusinessDate
End