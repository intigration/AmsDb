
----------------------------------------------------------------------
-- AmsSp_ALTrack_ALUpdated_1
--
-- AL has been updated.
--
-- Inputs -
--  UpdateTime - the time the AL was updated.
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
CREATE PROCEDURE AmsSp_ALTrack_ALUpdated_1
@dtUpdateTime datetime
AS
set nocount on
declare @nReturn int
set @nReturn = 0

update AlertList_UpdateTracking with (rowlock) set LastUpdateTime = @dtUpdateTime

if (@@error <> 0)
begin
print 'ERROR-- updating AlertList_UpdateTracking with update'
	set @nReturn = -1
end

return @nReturn

GO

