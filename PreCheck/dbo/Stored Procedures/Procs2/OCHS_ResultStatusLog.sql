CREATE Procedure OCHS_ResultStatusLog (@CLNO Int ,@LastName varchar(100),@FirstName varchar(50),@APNO Int=0,@OrderID int=0)  
As  
BEGIN  
 SET NOCOUNT ON  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 WITH XMLNAMESPACES ('http://ns.hr-xml.org' as ns1)  
 select distinct CLNO,lastName, FirstName, OrderID,APNO,OrderIDOrApno, COC,L.ProviderID, 
 L.XMLResponse.value('(//ns1:OrderStatus)[1]','VARCHAR(100)') [Status] ,
 L.XMLResponse.value('(//ns1:Results)[1]','VARCHAR(100)') TestResult,L.LastUpdated StatusDate,L1.ProcessStatus
 From   
 (Select C.CLNO,R.LastName,R.FirstName,OrderIDOrApno,C.OCHS_CandidateInfoID OrderID,C.APNO,COC,ProviderID,TestResult  
 from OCHS_CandidateInfo C inner join OCHS_ResultDetails R  on cast(C.OCHS_CandidateInfoID as varchar) = OrderIDOrApno  
 UNION ALL  
 Select C.CLNO,R.LastName,R.FirstName,OrderIDOrApno,C.OCHS_CandidateInfoID OrderID,C.APNO,COC,ProviderID,TestResult  
 from OCHS_CandidateInfo C inner join OCHS_ResultDetails R  on cast(C.APNO as varchar) = OrderIDOrApno) Qry  
    inner join ochs_resultslog L on Qry.Providerid = L.ProviderID 
	inner join OCHS_ResultsLog L1 on COC = left(L1.ProviderID,len(COC))
 where ( (CLNO = @CLNO and LastName = @LastName and Firstname = @FirstName) or (APNO = @APNO and @APNO>0 ) or (OrderID = @OrderID and @OrderID>0)  )
 and isnull(Lastname,'')<>'' and isnull(FirstName,'')<>''
 order by L.LastUpdated 
  
  
 SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
 SET NOCOUNT OFF  
END  
  
  