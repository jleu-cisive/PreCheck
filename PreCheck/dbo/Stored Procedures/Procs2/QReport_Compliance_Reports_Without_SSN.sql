-- =============================================  
-- Author:  <YSharma>  
-- Create date: <2/1/2023>  
-- Description: <As Per #HDT : 78958  new Q-Report for Compliance to gather all submitted reports that didn't include an SSN or I9 number>   
-- exec [dbo].[QReport_Compliance_Reports_Without_SSN] @Date1='04/23/2020',@Date2= '05/02/2022'  
 
-- =============================================
CREATE PROCEDURE dbo.QReport_Compliance_Reports_Without_SSN
(
@Date1 DateTime='',
@Date2 DateTime ='',
@CLNO INTEGER =0
)
AS
BEGIN
	--Declare @Date1 DateTime='01/17/2002',
	--@Date2 DateTime ='01/17/2012',
	--@CLNO INTEGER =1095
	IF @CLNO=''  OR @CLNO=0
	BEGIN
		SET @CLNO=NULL
	END

	IF @Date2 <> NULL OR @Date2 <>''
		BEGIN
			SELECT A.APNO,(ISNULL(A.Last,'') +' '+ISNULL(A.Middle,'')+' '+ISNULL(A.First,'')) AS CandidateName , A.CLNO,C.Name As ClientName,C.CAM AS ClientCAM,A.SSN
			FROM dbo.Appl A
			INNER JOIN dbo.Client C ON A.CLNO=C.CLNO
			WHERE 
			A.ApDate>=@Date1 AND A.ApDate <=@Date2
			AND A.CLNO = ISNULL(@CLNO,A.CLNO)
			AND SSN IS NULL
			ORDER BY A.APNO
		END 
	ELSE 
		BEGIN
			SELECT A.APNO,(ISNULL(A.Last,'') +' '+ISNULL(A.Middle,'')+' '+ISNULL(A.First,'')) AS CandidateName , A.CLNO,C.Name As ClientName,C.CAM AS ClientCAM,A.SSN
			FROM dbo.Appl A
			INNER JOIN dbo.Client C ON A.CLNO=C.CLNO
			WHERE 
			A.ApDate=@Date1
			AND A.CLNO = ISNULL(@CLNO,A.CLNO)
			AND SSN IS NULL
			ORDER BY A.APNO
		END
END 

