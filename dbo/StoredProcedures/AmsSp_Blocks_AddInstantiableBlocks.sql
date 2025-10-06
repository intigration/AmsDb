----------------------------------------------------------------------------
-- AmsSp_Blocks_AddInstantiableBlocks
--
--	Add current assigned instantiable Function blocks to Blocks table.
-- 
--	
-- Input:
--  @DeviceId nvarchar(255)	- device identifier
--
-- Output: -
--	@Error - Error message to be sent up the chain
--
-- Returns -
--	0 - successful.
--	-1 - General error.
--
-- Nghy Hong - 02/08/2012
CREATE PROCEDURE AmsSp_Blocks_AddInstantiableBlocks
@DeviceId nvarchar(255),
@Error nvarchar(max) output
AS
declare @nReturn int;
set @nReturn = 0;

Begin Try
	declare aCursor cursor for
		select Devices.DeviceKey, InstantiableConfigBlocks.BlockIndex, InstantiableConfigBlocks.BlockType
		from InstantiableBlockAsgms INNER JOIN
		InstantiableConfigBlocks ON InstantiableBlockAsgms.InstantiableBlockKey = InstantiableConfigBlocks.InstantiableBlockKey INNER JOIN
		Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey
		where (InstantiableBlockAsgms.UtcDateTimeOut = N'9999-12-31 00:00:00') AND (InstantiableConfigBlocks.ConfigType = N'C') AND 
		(InstantiableConfigBlocks.BlockType = N'F') AND (Devices.Identifier = @DeviceId)

	declare @nDevKey int;
	declare @nBlkIdx int;
	declare @sBlkType nvarchar(1);
	declare @nBlkKey int;

	open aCursor
	fetch next from aCursor into @nDevKey, @nBlkIdx, @sBlkType
	while (@@fetch_status = 0)
	begin
		if not exists (
			select DeviceKey, BlockIndex, BlockType
			from Blocks WHERE DeviceKey = @nDevKey AND BlockIndex = @nBlkIdx AND BlockType = @sBlkType)
		begin
			select @nBlkKey = max(BlockKey) + 1 from Blocks;
			insert Blocks with (rowlock) 
				(BlockKey, DeviceKey, BlockIndex, DispositionId, BlockType)
				values (@nBlkKey, @nDevKey, @nBlkIdx, 0, @sBlkType)
		end
		
		fetch next from aCursor into @nDevKey, @nBlkIdx, @sBlkType
	end
	close aCursor
	deallocate aCursor

END TRY
BEGIN CATCH
	set @nReturn = -1;
	set @Error = ERROR_MESSAGE();
END CATCH

return @nReturn;

GO

