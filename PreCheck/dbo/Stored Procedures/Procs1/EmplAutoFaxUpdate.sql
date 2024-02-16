









-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[EmplAutoFaxUpdate]

	(@textinput text,@empid int,@status int,@inv varchar(8))





AS

BEGIN



--DECLARE @ptr binary(16)



	

SET NOCOUNT ON;



--SELECT @ptr = TEXTPTR(Priv_Notes) FROM Empl WHERE EmplID = @empid

--IF @ptr is not null

--UPDATETEXT Empl.Priv_Notes @ptr 0 0 @textinput

--ELSE

--Update Empl set Priv_Notes = @textinput WHERE EmplID = @empid

Update dbo.Empl set Priv_Notes = Priv_Notes + CHAR(13)+CHAR(10) + cast(@textinput as varchar(max)) WHERE EmplID = @empid



IF @inv = 'null'

UPDATE Empl SET AutoFaxStatus = @status,Investigator = null WHERE EmplID = @empid 

ELSE

BEGIN

--if (@empid & 1) = 1

--UPDATE Empl SET AutoFaxStatus = @status,Investigator = 'JLOPEZ' WHERE EmplID = @empid 

----UPDATE Empl SET AutoFaxStatus = @status,Investigator = @inv WHERE EmplID = @empid 

--else

UPDATE Empl SET AutoFaxStatus = @status,Investigator = 'DAllen' WHERE EmplID = @empid 

END

SET NOCOUNT OFF;

END
















