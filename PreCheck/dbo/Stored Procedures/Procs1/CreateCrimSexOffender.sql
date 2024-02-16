-- Create Procedure CreateCrimSexOffender
--commented down line 41 to 49 by Reshma for Jira CXHE-43 [ME 67847 - Crims already processed/pending prior to AI Review]


/********************************************************************************************************/


CREATE PROCEDURE [dbo].[CreateCrimSexOffender]
  @state varchar(2),
  @Apno int,
  @CNTY_NO int,
   @CrimID int OUTPUT
as
  set nocount on

DECLARE @BigCounty varchar(75)

SELECT @BigCounty=county FROM dbo.TblCounties WHERE CNTY_NO=@CNTY_NO


  insert into Crim (Apno, CNTY_NO, County) values (@Apno, @CNTY_NO, @BigCounty)
  select @CrimID = @@Identity


  exec testfaxingsexoffender @apno,@Bigcounty,@cnty_no, @CrimID, @state



--update Crim
--set Clear = 'R'
--where Apno in (Select Apno from Appl where Apno = @Apno and EnteredVia = 'StuWeb' and  (CNTY_NO = 2480) )
--and Clear is null

--if((select [Value] from clientconfiguration c inner join appl a on a.clno = c.clno where apno = @apno

-- and configurationkey = 'autoorder') = 'True')
-- BEGIN
-- update Crim
--set Clear = 'R'
--where Apno = @Apno and CNTY_NO = 2480
--and Clear is null
-- END

 /********************************************************************************************************/

 /****** Object:  StoredProcedure [dbo].[GetCountyNumState]    Script Date: 3/14/2013 4:16:52 PM ******/
SET ANSI_NULLS ON
