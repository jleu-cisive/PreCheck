
CREATE Proc [dbo].[ReportApplByHowReceived]
@StartDate DateTime, @EndDate DateTime
as

SET TRANSACTION ISOLATION LEVEL
    READ UNCOMMITTED
    
    
select distinct isnull(EnteredVia , 'DataEnty') as EnteredVia, count(apno) as Count from appl  where apdate >@StartDate and apdate < @EndDate group by Enteredvia


SET TRANSACTION ISOLATION LEVEL
    READ COMMITTED
    
    
    
    
    
    
    