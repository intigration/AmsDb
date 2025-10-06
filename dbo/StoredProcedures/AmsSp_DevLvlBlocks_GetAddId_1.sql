----------------------------------------------------------------------
-- AmsSp_DevLvlBlocks_GetAddId_1
--
-- Get Device Level BlockKey. if not found, then add it.
--
-- Inputs -
--	@nDeviceKey int
--		Device Key
--	@nDispositionId smallint
--		Disposition Id
--
-- Outputs -
--	nBlockKey
--
-- Returns -
--	0 - successful, block existed
--  1 - successful, block was added
--	-1 - Error, unable to get BlockKey.
--
-- Jane Xiao (7/7/2003)
--

CREATE PROCEDURE AmsSp_DevLvlBlocks_GetAddId_1
@nDeviceKey int,
@nDispositionId smallint,
@nBlockKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get DeviceRevId if present.
-- for the device level block, the BlockIndex = 0 and BlockType = ''
select @nBlockKey = BlockKey
from Blocks with (nolock)
where DeviceKey = @nDeviceKey
and BlockIndex = 0
and BlockType = ''

if @@rowcount = 0 
--Block not found, add it
begin
	-- get the next BlockKey
	declare @NextBlockKey int
	select @NextBlockKey = max(BlockKey) + 1 from Blocks
	-- add block to db
	insert Blocks with (rowlock) (BlockKey, DeviceKey,BlockIndex,DispositionId, BlockType)
	values (@NextBlockKey, @nDeviceKey, 0,@nDispositionId, '')
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nBlockKey = @NextBlockKey
		set @iReturnVal = 1
	end
end

return @iReturnVal

GO

