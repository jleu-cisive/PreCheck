--select * from  [Compliance].[GetDNRApplicantCrim]('333-33-3333', null)
create FUNCTION [Compliance].[GetDNRApplicantCrim](@SSN varchar(11), @CNTY_NO int = null)
RETURNS @DNRApplicantCrim TABLE (SSN varchar(11), 
                                 CaseNo varchar(50),
                                 CNTY_NO int,
								 County varchar(40),
								 NameOnRecord varchar(100),
                                 CreateBy varchar(50),
                                 CreateDate DateTime,
                                 DispositionDate DateTime,
                                 DNRApplicantCrimId int,
                                 ModifyBy varchar(50),
                                 ModifyDate DateTime,
                                 Offence varchar(1000),
                                 CrimId int,
                                 DetailCreateDate DateTime,
                                 DetailCreateBy varchar(50),
                                 DNRApplicantCrimDetailId int,
                                 DNRAppSource varchar(50),
                                 DetailModifyBy varchar(50),
                                 DetailModifyDate DateTime,
                                 PublicNotes varchar(max),
                                 Apno int)



AS
BEGIN

INSERT INTO @DNRApplicantCrim
	(
	    SSN, 
        CaseNo,
        CNTY_NO,
		County,
	    NameOnRecord,
        CreateBy,
        CreateDate,
        DispositionDate,
        DNRApplicantCrimId,
        ModifyBy,
        ModifyDate,
        Offence,
        CrimId,
        DetailCreateDate,
        DetailCreateBy,
        DNRApplicantCrimDetailId,
        DNRAppSource,
        DetailModifyBy,
        DetailModifyDate,
        PublicNotes,
        Apno
	)
    select 
	    d.SSN, 
        d.CaseNo,
        d.CNTY_NO,
		c.County,
		c.Name,
        d.CreateBy,
        d.CreateDate,
        d.DispositionDate,
        d.DNRApplicantCrimId,
        d.ModifyBy,
        d.ModifyDate,
        d.Offence,
        c.CrimId,
        dd.CreateDate,
        dd.CreateBy,
        dd.DNRApplicantCrimDetailId,
        dd.DNRAppSource,
        dd.ModifyBy,
        dd.ModifyDate,
        c.Pub_Notes,
        c.Apno
	  from [Compliance].DNRApplicantCrim d
      join [Compliance].DNRApplicantCrimDetail dd
        on d.DNRApplicantCrimId = dd.DNRApplicantCrimId
      join Crim c
        on dd.CrimId = c.CrimID
     where d.SSN = @SSN 
	   and d.CNTY_NO = ISNULL(@CNTY_NO, d.CNTY_NO)
	   and d.IsActive = 1 and dd.IsActive = 1
                             
RETURN
END

