-----------------------------------------------------------------------
-- AmsSp_InstantiableConfigBlocks_GetAddId_1
--
-- Get or add InstantiableBlockKey (if not exists) from InstantiableConfigBlocks table
--
-- Inputs -
--	@nDeviceKey int
--		Device Key
--	@nBlockIndex int
--		Block Index
--	@sBlockType	nvarchar(1)
--		Block Type
--  @sConfigType nvarchar(1) 'C' for chararteristic, 'T' for Template
--
-- Outputs -
--	@nInstantiableBlockKey
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get BlockKey.
--
-- Nghy Hong (8/4/2011)
--

CREATE PROCEDURE AmsSp_InstantiableConfigBlocks_GetAddId_1
@nDeviceKey int,
@nBlockIndex int,
@sBlockType nvarchar(1),
@sConfigType nvarchar(1),
@nInstantiableBlockKey int OUTPUT
AS

declare @iReturnVal int;
set @iReturnVal = -1; --initialize as unsuccessful

BEGIN TRY
	--Validate Devicekey
	if exists (select DeviceKey from Devices where DeviceKey = @nDeviceKey)
	begin
		set @nInstantiableBlockKey = -1;
		
		--Get the InstantiableBlockKey if exists
		select @nInstantiableBlockKey = InstantiableBlockKey
		from InstantiableConfigBlocks with (nolock)
		where DeviceKey = @nDeviceKey and BlockIndex = @nBlockIndex;
		
		--Add new InstantiableBlockKey if InstantiableBlockKey not exists
		if (@nInstantiableBlockKey = -1)
		begin
			if exists (select InstantiableBlockKey from InstantiableConfigBlocks)
				select @nInstantiableBlockKey = max(InstantiableBlockKey) + 1 from InstantiableConfigBlocks
			else
				set @nInstantiableBlockKey = 0; --begin the InstantiableBlockKey with 0
						
			insert InstantiableConfigBlocks with (rowlock) (InstantiableBlockKey, DeviceKey, BlockIndex, BlockType, ConfigType)
			values (@nInstantiableBlockKey, @nDeviceKey, @nBlockIndex, @sBlockType, @sConfigType);
		end 
		
		--Successful operation
		set @iReturnVal = 0;
	end
END TRY
BEGIN CATCH
	set @nInstantiableBlockKey = -1;
END CATCH

return @iReturnVal

GO

