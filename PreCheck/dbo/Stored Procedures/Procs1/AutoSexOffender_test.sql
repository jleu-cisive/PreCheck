-- Alter Procedure AutoSexOffender_test

CREATE  PROCEDURE [dbo].[AutoSexOffender_test] AS

declare @id int
declare @apno int
declare @state varchar(2)
declare @crimid int
create table #a (apno int, state varchar(2),  id int identity)
create table #c (CNTY_NO int,  id int identity)
	
 insert	#a (apno, state) 
    --select apno, state from appl where inuse = 'SexOff_S'AND APNO NOT IN 
    --(SELECT APNO FROM  Crim WHERE CNTY_NO=2480 AND APNO IN (SELECT APNO FROM Appl WHERE InUse = 'SexOff_S' ))
	--NB:05/02/2013- uncommented above to get apno's by client config for some clno to skip autosexoffender process.

	select a.apno, a.state from appl a left join clientconfiguration c on a.clno = c.clno and c.configurationkey = 'SkipSexOffender' where IsNull(c.[value], 'False') = 'False'
and a.InUse = 'SexOff_S' 
--AND APNO NOT IN 
--    (SELECT APNO FROM  Crim WHERE CNTY_NO=2480 AND APNO IN (SELECT APNO FROM Appl WHERE InUse = 'SexOff_S' ))


         select @id = 0
		while @id < (select max(id) from #a)
                begin
			select @id = @id + 1
                        select 	@apno = apno,
                                     --  @state = state -- commented the state to be a null value for Auto ordering Sex offender searches using AMIS Agents
								 @state = NULL
				from	#a
			where	#a.id = @id

                     --  exec  createcrimsexoffender @state, @apno, 2480, @crimid
               
			   
							declare @CLNO int
							select @CLNO = clno  from appl where Apno = @Apno

							declare @config varchar(10)
							select @config = value from clientconfiguration where configurationkey = 'AutoOrder' and value = 'True' and clno = @clno


							if (Select isnull(@config,'False')) = 'True'
							Begin

							 insert	#c (CNTY_NO) 
							select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.CivilID  where r.clno = @clno 
							 union
							 select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.FederalID  where r.clno = @clno 

							insert into Crim (Apno, CNTY_NO, County,CreatedDate,Clear)
							Select @apno, c.cnty_no, County,getdate(),'R'
							From #C c inner join dbo.TblCounties cnty on c.cnty_no = cnty.cnty_no


							Select * from #c

							 Truncate table #c
							End
                 end
				Select * from #a
drop table #a 

 drop table #c



Update Appl
set inuse = 'SexOff_E'
where inuse = 'SexOff_S'
