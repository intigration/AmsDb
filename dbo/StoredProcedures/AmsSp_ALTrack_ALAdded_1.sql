
----------------------------------------------------------------------
-- AmsSp_ALTrack_ALAdded_1
--
-- An alert has been added for a given plantServerKey.
--
-- Inputs -
--  add time.
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
CREATE PROCEDURE AmsSp_ALTrack_ALAdded_1
@dtUpdateTime datetime
AS
set nocount on
declare @nReturn int
set @nReturn = 0

update AlertList_UpdateTracking with (rowlock)
	set LastAddTime = @dtUpdateTime,
		LastUpdateTime = @dtUpdateTime

if (@@error <> 0)
begin
print 'ERROR-- updating AlertList_UpdateTracking with add'
	set @nReturn = -1
end

return @nReturn

GO

