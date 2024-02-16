CREATE FUNCTION [dbo].[Fix_Crim_Ordered_Date] (@Date varchar(14)) 
RETURNS datetime
AS 
    BEGIN 
    	
    	DECLARE @Fullyear varchar(8)
             declare @mymonth varchar(2)
             declare @myday varchar(2)
             declare @myyear varchar(4)    	
             declare @glueittogether varchar(10)
            Set @mymonth = Datepart(mm,@date)
            Set @myday = Datepart(dd,@date)
            Set @myyear = Datepart(yyyy,@date)
            Set @glueittogether = @mymonth + '/' + @myday + '/' + @myyear
   	Return(@glueittogether)
END

