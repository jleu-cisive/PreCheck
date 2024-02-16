
-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 2/10/2015
-- Description:	get all the compact state licenses with MUltistate and single state , where license issuing state do not match there facility state/ employer state
-- =============================================

CREATE PROCEDURE  [dbo].[Usp_Daily_CompactSateReport]
@CLNO int,@SPMODE int,@DATEREF datetime
As
SET NOCOUNT ON

Exec HEVN.[dbo].Usp_Daily_CompactSateReport @Clno