-- ===================================================
-- Author:		Dongmei He
-- Create date: 02/16/2023
-- Description:	To identify affiliate ids for ZipCrim
-- ===================================================
CREATE PROCEDURE [dbo].[GetAffiliateIDs] AS

select distinct AffiliateID from client where [Accounting System Grouping] = 'ZIP Crim'