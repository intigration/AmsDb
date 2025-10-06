-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetLastSyncTime_1
--
-- Get the last sync time for the blockKey.
-- Returns dateTime in ODBC canonical (with milliseconds) format
--	(ie. yyyy-mm-dd hh:mi:ss.mmm) if found else blank if not found.
--
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--	@nBlockIndex		int		optional blockIndex.  If 0 then the
--								nDevLevelBlockKey is used.
--
-- Outputs -
--	@sSyncTime		nvarchar(255)
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to obtain information.
--	-2 - Error, blockIndex not found for this deviceLevelBlockKey
--
-- Joe Fisher - 8/25/2003
--

CREATE PROCEDURE AmsSp_DevBlk_GetLastSyncTime_1
@nDevLevelBlockKey int,
@nBlockIndex	int,
@sSyncTime	nvarchar(255) output
AS
declare @iReturnVal int
declare @dt datetime
declare @nBlockKey int

set @iReturnVal = 0
set @sSyncTime = ''

set nocount on

if (@nBlockIndex = 0)
	set @nBlockKey = @nDevLevelBlockKey
else
begin
	exec AmsSp_GetBlockKey_ByDeviceLevelBlockKey_1 @nDevLevelBlockKey, @nBlockIndex, @nBlockKey OUTPUT
	if (@nBlockKey = -999)
	begin
		return -2 --Error, blockIndex not found for this deviceLevelBlockKey
	end
end

-- search for event type of DBW_ET_DEVICE_SCAN (8).
select @dt = max(EventTime) from EventLog with (nolock)
	where BlockKey = @nBlockKey and
		  Type = 8

if (@dt is not null)
begin
	-- put in 'mm/dd/yyyy hh:mm:ss' format
	set @sSyncTime = convert(nvarchar(255), @dt, 101) + ' ' + convert(nvarchar(255), @dt, 108)
end
else
begin
	set @sSyncTime = ''	-- this is our indication that we do not have a entry.
end

return @iReturnVal

GO

