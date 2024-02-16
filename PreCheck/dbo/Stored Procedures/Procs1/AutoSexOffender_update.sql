-- Create Procedure AutoSexOffender_update

Create PROCEDURE [dbo].[AutoSexOffender_update] AS
BEGIN
	declare @id int
	declare @apno int
	declare @state varchar(2)
	declare @crimid int
	create table #a (apno int, [state] varchar(2),CLNO int,AutoOrderClient varchar(6),SkipSexOffender varchar(6), id int identity)
	create table #c (CNTY_NO int,  id int identity)
	
	 insert	#a (apno, [state],CLNO,AutoOrderClient,SkipSexOffender) 
	select a.apno, a.state
	,a.CLNO ,IsNull(AutoOrderConfig.[value], 'False'),IsNull(SexOffenderConfig.[value], 'False') --added by Schapyala on 07/02/14
	from dbo.appl a left join dbo.clientconfiguration SexOffenderConfig on a.clno = SexOffenderConfig.clno and SexOffenderConfig.configurationkey = 'SkipSexOffender' 
					left join dbo.clientconfiguration AutoOrderConfig on a.clno = AutoOrderConfig.clno and AutoOrderConfig.configurationkey = 'AutoOrder' --added by Schapyala on 07/02/14
	where -- a.InUse = 'SexOff_S' 
	 (ApDate > '2014-07-10 08:00:47.000') 
	AND 
	APNO NOT IN 
		--(SELECT APNO FROM  Crim WHERE CNTY_NO=2480 AND APNO IN (SELECT APNO FROM Appl WHERE InUse = 'SexOff_S' ))
		(
Select APNO from Crim Where APNO in(
SELECT         APNO
FROM            dbo.Appl
WHERE        (ApDate > '2014-07-10 08:00:47.000') --and Investigator = 'AUTO'
)
and CNTY_NO = 2480
)

			declare @CLNO int
			declare @AutoOrderClient varchar(6)
			declare @SkipSexOffender varchar(6)

			select @id = 0

			WHILE @id < (select max(id) from #a)
				BEGIN
					select @id = @id + 1

					select 	@apno = apno,
						--  @state = state -- commented the state to be a null value for Auto ordering Sex offender searches using AMIS Agents
							@state = NULL,
							@CLNO = clno,  --added by Schapyala on 07/02/14
							@AutoOrderClient = AutoOrderClient,
							@SkipSexOffender = SkipSexOffender  --end added by Schapyala on 07/02/14
					from	#a
					where	#a.id = @id

					if @SkipSexOffender = 'False'
						exec  dbo.createcrimsexoffender @state, @apno, 2480, @crimid
							 
					--if @AutoOrderClient = 'True'
					--Begin
						--Create crim records based on client rules configuration
						insert	#c (CNTY_NO) 
						select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.CivilID  where r.clno = @clno 
						union
						select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.FederalID  where r.clno = @clno 

						insert into dbo.Crim (Apno, CNTY_NO, County,CreatedDate,[Clear],vendorid,deliverymethod,b_rule,iris_rec,readytosend )
						Select @apno, c.CNTY_NO, County,getdate(),
						case when @AutoOrderClient = 'True' then 'R' else null end, --IF Autoorder client, then set it to pending 
						R_id,R_Delivery,'Yes','Yes','0'
						From #C c inner join dbo.TblCounties cnty on c.cnty_no = cnty.cnty_no
						inner join dbo.Iris_Researcher_Charges IRC on c.cnty_no = IRC.cnty_no AND (Researcher_Default = 'Yes')
						inner join  dbo.Iris_Researchers IR on Researcher_id = R_id
						
						-- below was commented by kiran on 7/10/2014, to get active vendor and delivery method for each county.

						----Select @apno, c.CNTY_NO, County,getdate(),
						----case when @AutoOrderClient = 'True' then 'R' else null end, --IF Autoorder client, then set it to pending 
						----86419,'Call_In','Yes','Yes','0'
						----From #C c inner join dbo.counties cnty on c.cnty_no = cnty.cnty_no
						--Where c.CNTY_NO not in (Select CNTY_NO	From dbo.crim where APNO = @apno)  -- uncomment if they complain about duplicate orders -- added by schapyala on 07/2/14 to prevent duplicates	

						Truncate table #c
					--End
               
					END
		
	drop table #a 
	drop table #c


	Update Appl
	set inuse = 'SexOff_E'
	where inuse = 'SexOff_S'
END
