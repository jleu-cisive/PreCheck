CREATE PROCEDURE Win_ServiceInUseTransition @StartStatus varchar(8),@EndStatus varchar(8)  AS




--Start------------------------------- When Merlin is down uncomment below
---------------------------------- Reset Inuse = null, set R1 to R2,W1 to W2, X1 to X2, S1 to S2 where inuse = Merlin_S
/*
If @EndStatus = 'Social_E'
 Begin
  Update Appl
  set InUse = 'Merlin_E'
  where InUse = 'Social_E'
end
else
Begin
 Update Appl
 SET inUse= @StartStatus
 where inUse = @EndStatus
End
*/
--End-----------------------------------------------------------------------------


-------Start----------- When Merlin is Running

  Update Appl
 SET inUse= @StartStatus
 where inUse = @EndStatus

------End -----------