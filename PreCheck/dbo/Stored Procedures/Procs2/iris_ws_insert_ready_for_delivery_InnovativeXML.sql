-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[iris_ws_insert_ready_for_delivery_InnovativeXML]
	-- Add the parameters for the stored procedure here
	@data TEXT
AS

Declare 
    @hdoc int,
    @countScreeningID int,
    @screening_id int

BEGIN

    Set @countScreeningID = 0;
    
    EXEC sp_xml_preparedocument @hdoc OUTPUT, @data

    Insert dbo.iris_ws_ready_for_delivery (screening_id, delivered) 
    select IdValue, 0
    from openXML(@hdoc, '/BackgroundCheck/BackgroundSearchPackage/Screenings/Screening/ReferenceId', 2) 
    with (IdValue int ) 
    where IdValue not in ( select screening_id from iris_ws_ready_for_delivery)

Exec sp_xml_removedocument @hdoc
    
END