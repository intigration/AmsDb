-----------------------------------------------------------------------
-- AmsSp_Blocks_GetAddId_1
--
-- Get BlockKey. if not found, then add it.
--
-- Inputs -
--	@nDeviceKey int
--		Device Key
--	@nBlockIndex int
--		Device Revision code
--	@nDispositionId smallint
--		Disposition Id
--	@sBlockType	char(1)
--		Block Type
--
-- Outputs -
--	nBlockKey
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get BlockKey.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_Blocks_GetAddId_1
@nDeviceKey int,
@nBlockIndex int,
@nDispositionId smallint,
@sBlockType char(1),
@nBlockKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- check that the device key is valid
select DeviceKey from Devices where DeviceKey = @nDeviceKey
if (@@rowcount = 0)
begin
	return -1
end

-- get DeviceRevId if present.
select @nBlockKey = BlockKey
from Blocks with (nolock)
where DeviceKey = @nDeviceKey
and BlockIndex = @nBlockIndex

if @@rowcount = 0 
--Block not found, add it
begin
	-- get the next BlockKey
	declare @NextBlockKey int
	select @NextBlockKey = max(BlockKey) + 1 from Blocks
	-- add block to db
	insert Blocks with (rowlock) (BlockKey, DeviceKey,BlockIndex,DispositionId, BlockType)
	values (@NextBlockKey, @nDeviceKey, @nBlockIndex,@nDispositionId, @sBlockType)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nBlockKey = @NextBlockKey
	end
end

return @iReturnVal

GO

