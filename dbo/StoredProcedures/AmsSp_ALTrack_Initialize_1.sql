
----------------------------------------------------------------------
-- AmsSp_ALTrack_Initialize_1
--
-- Initialize the AlertList tracking table.
--
-- Inputs -
--  none.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_ALTrack_Initialize_1
AS
set nocount on
declare @nReturn int
set @nReturn = 0

declare @dtBegin datetime
set @dtBegin = '1970/01/01 00:00:00'

-- there is only one record in this table, we won't delete it but clear the values
update AlertList_UpdateTracking set UpdateCount = 0, InitializeTime = @dtBegin, LastUpdateTime = @dtBegin, LastAddTime = @dtBegin

return @nReturn

GO

