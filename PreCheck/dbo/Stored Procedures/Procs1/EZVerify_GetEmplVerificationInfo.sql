

/****** Object:  StoredProcedure [dbo].[EZVerify_GetEmplVerificationInfo]    Script Date: 06/22/2011 11:03:41 ******/

-- =============================================
-- Author:		Najma Begum
-- Create date: 06/15/2011
-- Description:	To get employment verification info for EZVerify App
-- =============================================
CREATE PROCEDURE [dbo].[EZVerify_GetEmplVerificationInfo]
	-- Add the parameters for the stored procedure here
	@VID nvarchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if(@VID is not null AND LEN(@VID) > 4)
BEGIN
declare @SSN int
declare @EmplID int
declare @TempSSN int
declare @ASSN varchar(14)
declare @TempVar varchar(20)

SET @TempVar = Right(@VID,4)
if(isNumeric(@TempVar)<>0)
begin
--SET @SSN = Right(@VID,4)
SET @SSN = @TempVar
End

SET @TempVar = Left(@VID, Len(@VID)-4)
if(isNumeric(@TempVar)<>0)
begin
--SET @EmplID = Left(@VID, Len(@VID)-4)
SET @EmplID = @TempVar
End

if(@EmplID is not NULL AND @SSN is not NULL)
begin
SET @ASSN = (SELECT  dbo.Appl.SSN
FROM         dbo.Appl INNER JOIN
                      dbo.Empl ON dbo.Appl.APNO = dbo.Empl.Apno where dbo.Empl.EmplID = @EmplID)
if(@ASSN is not null OR @ASSN <> '')
BEGIN
SET @TempSSN = Right(@ASSN,4)
if(@TempSSN = @SSN)
BEGIN
declare @IsInvalidated int
SET @IsInvalidated = (select count(*) from dbo.EZVerifyLog where VIDInvalidated = 1 and VerificationID = @VID)
if(@IsInvalidated = 0)
begin

SELECT     dbo.Empl.EmplID, dbo.Empl.Apno, dbo.Empl.SectStat, dbo.Empl.From_A, dbo.Empl.To_A, dbo.Empl.Position_A, dbo.Empl.From_V, dbo.Empl.To_V, 
                      dbo.Empl.Position_V, dbo.Empl.Ver_By, dbo.Empl.Title, dbo.Empl.Pub_Notes, dbo.Empl.Priv_Notes, dbo.Empl.web_status, dbo.Empl.Emp_Type, dbo.Empl.Rel_Cond, dbo.Empl.Rehire, dbo.Appl.ApDate, dbo.Appl.Last, 
                      dbo.Appl.First, dbo.Appl.Middle, (ISNULL(dbo.Appl.Alias1_First,'')+' ' +ISNULL(dbo.Appl.Alias1_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias1_Last,'')) as Alias,
(ISNULL(dbo.Appl.Alias2_First,'')+' ' +ISNULL(dbo.Appl.Alias2_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias2_Last,'')) as Alias2, 
(ISNULL(dbo.Appl.Alias3_First,'')+' ' +ISNULL(dbo.Appl.Alias3_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias3_Last,'')) as Alias3, 
(ISNULL(dbo.Appl.Alias4_First,'')+' ' +ISNULL(dbo.Appl.Alias4_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias4_Last,'')) as Alias4, dbo.Appl.SSN, dbo.Appl.DOB, dbo.Client.Name, dbo.SectStat.[Description] as SectStatDesp
                      
                      FROM         dbo.Appl INNER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
                      dbo.Empl ON dbo.Appl.APNO = dbo.Empl.Apno INNER JOIN
                      dbo.SectStat ON dbo.Empl.SectStat = dbo.SectStat.Code
 where dbo.Empl.EmplID = @EmplID                      

END
END
end                    
END
END
END

