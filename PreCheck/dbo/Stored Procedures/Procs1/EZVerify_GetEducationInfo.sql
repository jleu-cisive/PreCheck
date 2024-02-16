

-- =============================================
-- Author:		Najma Begum
-- Create date: 11/28/2011
-- Description:	To get education verification info for EZVerify App
-- =============================================
CREATE PROCEDURE [dbo].[EZVerify_GetEducationInfo]
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
declare @EduID int
declare @TempSSN int
declare @ASSN varchar(14)
declare @TempVar varchar(20)

SET @TempVar = LEFT(@VID,4) 
if(isNumeric(@TempVar)<>0)
begin
--SET @SSN = LEFT(@VID,4)
SET @SSN = @TempVar
end

SET @TempVar = RIGHT(@VID, Len(@VID)-4)
if(isNumeric(@TempVar)<> 0)
Begin
--SET @EduID = RIGHT(@VID, Len(@VID)-4)
SET @EduID = @TempVar
End
if(@EduID is not NULL AND @SSN is not NULL)
begin
SET @ASSN = (SELECT  dbo.Appl.SSN
FROM         dbo.Appl INNER JOIN
                      dbo.Educat ON dbo.Appl.APNO = dbo.Educat.Apno where dbo.Educat.EducatID = @EduID)
if(@ASSN is not null OR @ASSN <> '')
BEGIN
SET @TempSSN = Right(@ASSN,4)
if(@TempSSN = @SSN)
BEGIN
declare @IsInvalidated int
SET @IsInvalidated = (select count(*) from dbo.EZVerifyLog where VIDInvalidated = 1 and VerificationID = 'S' + @VID)
if(@IsInvalidated = 0)
begin

SELECT     dbo.Educat.EducatID, dbo.Educat.Apno, dbo.Educat.SectStat, dbo.Educat.From_A, dbo.Educat.To_A, 
                      dbo.Educat.Degree_A,dbo.Educat.Studies_A,dbo.Educat.Pub_Notes, dbo.Educat.Priv_Notes, dbo.Educat.web_status,dbo.Educat.hasgraduated, dbo.Educat.School, dbo.Appl.ApDate, dbo.Appl.Last, 
                      dbo.Appl.First, dbo.Appl.Middle, (ISNULL(dbo.Appl.Alias1_First,'')+' ' +ISNULL(dbo.Appl.Alias1_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias1_Last,'')) as Alias,
(ISNULL(dbo.Appl.Alias2_First,'')+' ' +ISNULL(dbo.Appl.Alias2_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias2_Last,'')) as Alias2, 
(ISNULL(dbo.Appl.Alias3_First,'')+' ' +ISNULL(dbo.Appl.Alias3_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias3_Last,'')) as Alias3, 
(ISNULL(dbo.Appl.Alias4_First,'')+' ' +ISNULL(dbo.Appl.Alias4_Middle,'')+ ' '+ISNULL(dbo.Appl.Alias4_Last,'')) as Alias4, dbo.Appl.SSN, dbo.Appl.DOB, dbo.Client.Name, dbo.SectStat.[Description] as SectStatDesp
FROM         dbo.Appl INNER JOIN
dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
                      dbo.Educat ON dbo.Appl.APNO = dbo.Educat.Apno INNER JOIN
                      dbo.SectStat ON dbo.Educat.SectStat = dbo.SectStat.Code where dbo.Educat.EducatID = @EduID
END
END


end
END                    
END
END

