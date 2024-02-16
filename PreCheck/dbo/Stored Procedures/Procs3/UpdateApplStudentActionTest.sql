

--Modified by JC on 12-01-05: to add Hospital_CLNO when insert AdverseAction
--Modified By SC on 03-03-07 to avoid duplicate updates to the AdverseActionHistory table


CREATE PROCEDURE [dbo].[UpdateApplStudentActionTest]
  @Apno Text,
  @StudentActionID Text,
  @CLNO_Hospital varchar(10)
	
as
--------------- added on 120105 -------------------- 
declare @Email varchar(100) 
--set @Email=(select Email from ClientContacts where clno=@CLNO_Hospital and PrimaryContact=1)
set @Email=( select Email from ClientContacts where clno=@CLNO_Hospital and contactid in (select min(contactid) from clientcontacts where clno=@CLNO_Hospital group by clno) )  

----------------------------------------------------


BEGIN TRANSACTION

--------------- added on 031307 -------------------- 
Select * into [#AppList] from dbo.fn_Split(@Apno,',')

Select * into [#StudentActionList] from dbo.fn_Split(@StudentActionID,',')
----------------------------------------------------

-- parameter string query
UPDATE ApplStudentAction SET StudentActionID =  QRY.StudentActionID
FROM     ApplStudentAction Apl 
INNER JOIN 
	( SELECT A.Value StudentActionID, B.Value APNO FROM [#StudentActionList] A inner join [#AppList] B ON A.IDX = B.IDX )  QRY
ON         Apl.APNO = QRY.APNO 
and CLNO_Hospital=@CLNO_Hospital

--Insert into Adverse table if a PreAdverse/Adverse has not been requested earlier per app (on the specific app) 
insert into AdverseAction (APNO,StatusID,Hospital_CLNO,ClientEmail,Name,Address1,City,State,Zip)
SELECT APNO
	,1 --for PreAdverse request
	,@CLNO_Hospital
	,@Email 
	,a.[First] + ' ' + isnull(a.Middle,'')+ ' ' + isnull(a.[Last],'') Name
	,isnull(a.Addr_Num,'') + ' ' + isnull(a.Addr_Apt,'') + ' ' + isnull(a.Addr_Dir,'') + ' ' + a.Addr_Street  + ' ' +  isnull(Addr_StType,'') Address1
	,a.City
	,a.State
	,a.Zip
FROM Appl a 
where  a.apno in (Select Value from [#AppList]  A Inner Join ApplStudentAction Apl On A.Value=Apl.APNO Where StudentActionID in (2,3) and Apl.CLNO_Hospital=@CLNO_Hospital
and Value not in (select distinct APNO from AdverseAction A Inner Join [#AppList] Apl On A.APNO=Apl.Value where Hospital_CLNO = @CLNO_Hospital) )

--Update the status to PREADVERSE if the StudentAction =  2 ( Possible Reject (PreAdverse) )
--***************************************StudentAction =  2 ( Possible Reject (PreAdverse) )

--insert into AdverseActionHistory table - Insert PreAdverse only when the Preadverse is not requested by the Client earlier
insert into AdverseActionHistory(AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
Select AdverseActionID,1,1,'Client',getdate() From AdverseAction Where Hospital_CLNO=@CLNO_Hospital  
and apno in (Select Value from [#AppList]  A Inner Join ApplStudentAction Apl On A.Value=Apl.APNO Where StudentActionID=2 and Apl.CLNO_Hospital=@CLNO_Hospital )
and AdverseActionID Not in (Select   distinct AAH.AdverseActionID 
							From  AdverseActionHistory AAH inner join AdverseAction AA
							on    AA.AdverseActionID = AAH.AdverseActionID
							where AAH.StatusID = 1 and UserID = 'Client' 
							and Hospital_CLNO=@CLNO_Hospital
							and apno in (Select Value from [#AppList]))

--***************************************StudentAction =  2 ( Possible Reject (PreAdverse) )

--Update the status to ADVERSE if the StudentAction =  3 ( Reject (Adverse) ) 
--************************************StudentAction =  3 ( Reject (Adverse) )
Update AdverseAction 
SET StatusID = 16  -- Adverse Request
where apno in (Select Value from [#AppList]  A Inner Join ApplStudentAction Apl On A.Value=Apl.APNO Where StudentActionID=3 and Apl.CLNO_Hospital=@CLNO_Hospital )
and   StatusID not in (17,18,23) -- Do not Reset to Adverse Requested if the Adverse action is in process or Completed.
and Hospital_CLNO=@CLNO_Hospital

--insert into AdverseActionHistory table - Insert Adverse only when the Adverse is not requested by the Client earlier
insert into AdverseActionHistory(AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
Select AdverseActionID,1,16,'Client',getdate() From AdverseAction Where Hospital_CLNO=@CLNO_Hospital  
and apno in (Select Value from [#AppList]  A Inner Join ApplStudentAction Apl On A.Value=Apl.APNO Where StudentActionID=3 and Apl.CLNO_Hospital=@CLNO_Hospital )
and AdverseActionID Not in (Select   distinct AAH.AdverseActionID 
							From  AdverseActionHistory AAH inner join AdverseAction AA
							on    AA.AdverseActionID = AAH.AdverseActionID
							where AAH.StatusID = 16 and UserID = 'Client' 
							and Hospital_CLNO=@CLNO_Hospital
							and apno in (Select Value from [#AppList]))

--************************************StudentAction =  3 ( Reject (Adverse) )

--------------- added on 031307 -------------------- 
Drop Table [#AppList] 

Drop Table [#StudentActionList] 
----------------------------------------------------

COMMIT TRANSACTION



