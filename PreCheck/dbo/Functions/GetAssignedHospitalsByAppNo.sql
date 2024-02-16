CREATE FUNCTION dbo.GetAssignedHospitalsByAppNo (@AppNo int) 
RETURNS varchar(8000) AS  
BEGIN 
DECLARE @ASSIGNEDHOSPITALS Varchar(8000)
DECLARE @STATUS Varchar(8000)


Select @ASSIGNEDHOSPITALS =    Coalesce( @ASSIGNEDHOSPITALS + '<tr><td><font class="tinytable"> ','') + DescriptiveName +' </font></td> <td width=100><font class="tinytable">'+ ref.StudentAction + ' </font></td> </tr>'
--Select @ASSIGNEDHOSPITALS =   Coalesce( @ASSIGNEDHOSPITALS + '</td><td> <font class="tinytable">' + ref.StudentAction + '</font></td></tr>','') + '<tr><td> <font class="tinytable">' +  Name + '&nbsp;</font>' ,  @STATUS = (ref.StudentAction )
--  +
From   ApplStudentAction A Inner Join Client B
On     A.CLNO_Hospital = B.CLNO
Inner Join refStudentAction ref 
On    A.StudentActionID = ref.StudentActionID
Where A.ApNo = @AppNo


return('<TABLE cellspacing=0 cellpadding=0 border=1 bordercolor=EEEEEE width=100%> <tr><td><font class="tinytable"> ' + @ASSIGNEDHOSPITALS + ' </TABLE>')
--return('<table width=300 border=1 bordercolor=CCCCCC cellspacing=0 cellpadding=0' + @ASSIGNEDHOSPITALS + ' </td><td><font class="tinytable">'+@STATUS+'</font></td></table>')
END





--CREATE FUNCTION dbo.GetAssignedHospitalsByAppNo (@AppNo int) 
--RETURNS varchar(8000) AS  
--BEGIN 
--DECLARE @ASSIGNEDHOSPITALS Varchar(8000)
--Select @ASSIGNEDHOSPITALS = Coalesce(@ASSIGNEDHOSPITALS,'') +(ref.StudentAction + ' - ' ) +  Name + '<BR>' 
--From   ApplStudentAction A Inner Join Client B
--On     A.CLNO_Hospital = B.CLNO
--Inner Join refStudentAction ref 
--On    A.StudentActionID = ref.StudentActionID
--Where A.ApNo = @AppNo
--return(@ASSIGNEDHOSPITALS)
--END




