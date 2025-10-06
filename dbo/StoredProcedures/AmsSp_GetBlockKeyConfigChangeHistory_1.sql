
-----------------------------------------------------------------------
-- AmsSp_GetBlockKeyConfigChangeHistory_1
--
-- Get block key configuration change history.
--
-- Inputs -
--	BlockKey
--
-- Outputs -
--	Recordset containing list of configuration change dates (in GMT).
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/30/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetBlockKeyConfigChangeHistory_1
@nBlockKey as integer
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

SELECT DISTINCT dbo.EventLog.EventTime as EventTime, dbo.EventLog.EventIdDay, dbo.EventLog.EventIdFraction
FROM dbo.BlockData INNER JOIN
    dbo.EventLog ON 
    dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND 
    dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
WHERE (dbo.BlockData.BlockKey = @nBlockKey) AND (BlockData.ValueMode = 'h') 
ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

