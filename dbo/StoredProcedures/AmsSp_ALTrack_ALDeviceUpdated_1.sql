
----------------------------------------------------------------------
-- AmsSp_ALTrack_ALDeviceUpdated_1
--
-- AL has been updated for a given device.
--
-- Inputs -
--  nBlockKey - the database key for this device-block level.
--  UpdateTime - the time the AL was updated.
--	nALUpdateType - the type of AL update- 1=added, 2=changed, 3=cleared
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
CREATE PROCEDURE AmsSp_ALTrack_ALDeviceUpdated_1
@nBlockKey int,
@dtUpdateTime datetime,
@nALUpdateType int
AS
set nocount on
declare @nReturn int
set @nReturn = 0

begin
	-- go ahead and update the tracking info.
	if (@nALUpdateType = 1)	-- alert added
	begin
		exec @nReturn = AmsSp_ALTrack_ALAdded_1 @dtUpdateTime
	end
	else if (@nALUpdateType = 2) -- alert updated
	begin
		exec @nReturn = AmsSp_ALTrack_ALUpdated_1 @dtUpdateTime
	end
	else if (@nALUpdateType = 3) -- alert cleared
	begin
		exec @nReturn = AmsSp_ALTrack_ALUpdated_1 @dtUpdateTime
	end
	else -- invalid update type !!!
	begin
		print 'ERROR-- invalid update type...'
		set @nReturn = -1
	end
	-- no matter what kind of update (add, update, cleared) we will always increment the updateCount
	declare @nUpdateCount int
	select @nUpdateCount = UpdateCount from AlertList_UpdateTracking with (nolock)
	set @nUpdateCount = @nUpdateCount + 1
	update AlertList_UpdateTracking with (rowlock) set UpdateCount = @nUpdateCount
end

return @nReturn

GO

