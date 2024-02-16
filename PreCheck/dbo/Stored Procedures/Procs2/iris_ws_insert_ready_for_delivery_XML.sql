-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[iris_ws_insert_ready_for_delivery_XML]
	-- Add the parameters for the stored procedure here
	@data TEXT,
    @vendor int
AS

Declare 
    @hdoc int,
    @countScreeningID int,
    @screening_id int

BEGIN

    Set @countScreeningID = 0;
    
    EXEC sp_xml_preparedocument @hdoc OUTPUT, @data
    
  if (@vendor = 1)
    Begin
    Insert dbo.iris_ws_ready_for_delivery (screening_id, delivered) 
    select IdValue, 0
    from openXML(@hdoc, '/BackgroundCheck/BackgroundSearchPackage/Screenings/Screening/ReferenceId', 2) 
    with (IdValue int ) 
    where IdValue not in ( select screening_id from iris_ws_ready_for_delivery);
    End
  else if (@vendor = 2)
    Begin 
    Insert dbo.iris_ws_ready_for_delivery (screening_id, delivered) 
    select IdValue, 0
    from openXML(@hdoc, '/BackgroundSearchPackage/Screenings/Screening/ClientReferences', 2) 
    with (IdValue int ) 
    where IdValue not in ( select screening_id from iris_ws_ready_for_delivery)
    End

Exec sp_xml_removedocument @hdoc
    
END
