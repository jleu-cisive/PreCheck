
-- =============================================
-- Author:		/*Yves Fernandes*/
-- Create date: /*10/29/19*/
-- Description:	/*merges names for different sources with names in the applalias*/
-- Execution: /*Description*/
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AddAliasesFromOtherSources]
	@apno int
AS
BEGIN
    declare @currentdate datetime = getdate();
    drop table if EXISTS #names
	;WITH cte AS
	(
		SELECT e.apno, Ltrim(rtrim(e.[Name])) AS FullName, 'EDUCATION' [Source]
		FROM educat e
		where e.apno = @apno and len(Ltrim(rtrim(e.[Name]))) > 0
		UNION ALL
		SELECT @apno, Ltrim(rtrim(a.NameOnDriverLicense)) AS FullName, 'DL' [Source] FROM Enterprise.dbo.Applicant a
		where ApplicantNumber = @apno and len (Ltrim(rtrim(a.NameOnDriverLicense))) > 0
		UNION ALL
		SELECT @apno, Ltrim(rtrim(al.NameOnLicense)) AS FullName, 'LICENSE' [Source] FROM Enterprise.dbo.ApplicantLicense al
		INNER JOIN Enterprise.dbo.Applicant a2 ON al.ApplicantId = a2.ApplicantId
		where a2.ApplicantNumber = @apno and len(Ltrim(rtrim(al.NameOnLicense))) > 0
	),
	cte2 as
    (
        SELECT c.apno,
        LTRIM(RTRIM(c.[FullName])) [FullName],
        CASE WHEN CHARINDEX (' ', c.FullName)=0 THEN c.FullName ELSE LEFT(c.[FullName], CHARINDEX (' ', c.[FullName])) END [First],
        CASE 
                WHEN CharIndex(' ', c.[FullName], CHARINDEX (' ', c.[FullName])+1) /*SecondSpace*/ = 0 THEN ''
                ELSE SubString(c.[FullName], CharIndex(' ', c.[FullName]) /*FirstSpace*/ +1, 
                                    Len(c.[FullName])-CharIndex(' ', c.[FullName]) /*FirstSpace*/-CharIndex(' ', Reverse(SubString(c.[FullName], CharIndex(' ', c.[FullName])+1, Len(c.[FullName])))) /*LastSpace*/)
                END [Middle],
        CASE 
                WHEN CharIndex(' ', c.[FullName]) /*FirstSpace*/ = 0 then '' 
                ELSE CASE 
                            WHEN CharIndex(' ', c.[FullName], CHARINDEX (' ', c.[FullName])+1) /*SecondSpace*/ = 0 THEN
                                    SubString(c.[FullName], CharIndex(' ', c.[FullName]) /*FirstSpace*/ +1 , len(c.[FullName]))
                            ELSE 
                                    SubString(c.[FullName], Len(c.[FullName]) - CharIndex(' ', Reverse(SubString(c.[FullName], CharIndex(' ', c.[FullName])+1, Len(c.[FullName])))) /*LastSpace*/ +2, len(c.[FullName]))
                            END
        END [Last],
		c.Source
        FROM cte c
        WHERE C.FullName IS NOT NULL
    )
    select distinct APNO, [First], middle,[Last] into #names from cte2
	WHERE len(isnull([first], '')) <= 50 AND len(isnull([middle], '')) <= 50 AND len(isnull([last], '')) <= 50
    ;with cte as
    (
        select * from ApplAlias aa
        where aa.APNO = @apno
    )
    MERGE cte as target
    using #names as source
    on(target.apno = source.apno
        and isnull(target.First,'') = isnull(source.First, '') 
        and isnull(target.Middle, '') = isnull(source.Middle, '') 
        and isnull(target.Last, '') = isnull(source.Last,'')
    )
    when matched then
        UPDATE set target.ispublicrecordqualified = 1
    when not matched then 
        insert (apno, first,middle,last,ismaiden,generation, addedby,clno,ssn, ispublicrecordqualified, isprimaryname, isactive,
                createddate,createdby, lastupdatedate, lastupdatedby) 
        values(@apno, source.first, source.middle,source.last,0,'','AliasAutomation',null,null,1,0,1,@currentdate,'AliasAutomation',
                @currentdate, 'AliasAutomation');  
END
