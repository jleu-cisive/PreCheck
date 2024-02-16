
CREATE PROCEDURE [dbo].[SelectAppl] 
@Apno int,
@SSN Varchar(20)
AS

/*SELECT APNO, ApStatus, UserID,ApDate, CLNO, Attn ,Last ,First ,Middle, SSN ,DOB ,Sex ,Addr_Num ,Addr_Dir 
	,Addr_Street ,Addr_StType ,Addr_Apt ,City ,State ,Zip ,RecruiterID  
FROM Appl WHERE apno =  @Apno and ssn = @SSN


SELECT a.APNO, a.ApStatus, a.UserID, a.CLNO, a.Last ,a.First ,a.Middle, a.SSN ,a.DOB ,a.Sex 
	,a.Addr_Street ,a.Addr_StType ,a.Addr_Apt ,a.City ,a.State ,a.Zip
	,aa.StatusID, aa.ClientEmail 
FROM Appl a left join AdverseAction aa ON a.APNO = aa.APNO
WHERE a.apno =  @Apno and substring(a.ssn,len(rtrim(a.ssn))-3,4) = @SSN*/

SELECT a.APNO, a.ApStatus, a.UserID, a.CLNO
	, c.adverse    --hz added on 7/6/06
	, a.SSN ,a.DOB ,a.Sex 
	,case when len(aa.StatusID) > 0 then aa.Name else a.[First] + ' ' + isnull(a.Middle,'')+ ' ' + isnull(a.[Last],'') end as [name]
	,case when len(aa.StatusID) > 0 then aa.Address1 else isnull(a.Addr_Num,'') + ' ' + isnull(a.Addr_Apt,'') + ' ' + isnull(a.Addr_Dir,'') + ' ' + a.Addr_Street  + ' ' +  isnull(Addr_StType,'') end as Addr_Street
	,aa.Address2
	,case when len(aa.StatusID) > 0 then aa.City else a.City end as City
	,case when len(aa.StatusID) > 0 then aa.State else a.State end as State
	,case when len(aa.StatusID) > 0 then aa.Zip else a.Zip end as Zip
	,aa.StatusID, aa.ClientEmail 
	,u.[name] as cam	--hz added on 7/7/06
FROM Appl a left join AdverseAction aa ON a.APNO = aa.APNO,  client c, users u 
WHERE a.apno =  @Apno and substring(a.ssn,len(rtrim(a.ssn))-3,4) = @SSN
	and  c.clno = a.clno and c.cam = u.userid   --hz added on 7/7/06
