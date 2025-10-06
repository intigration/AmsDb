---------------------------------------------------------------------------
--AmsSp_SyncInstantiableFuncBlockAsgm_1
--
--Update the current(UtcDateTimeOut = 9999-12-31) instantiable function block 
--assignments to the current UTC date time stamp to mark the assignment to be 
--not current or invalid for the block index not listed in the input xml.
--
-- Input:
--  @FunctionBlockList	- data in xml supporting single device, one or more Blocks.
--				<Root>
--					<Device DevId="00031020000008122009001010131293">
--						<Blocks>
--							<Block BlockIndex="1100" BlockType="F" ItemId="xxxx"/>
--							<Block BlockIndex="1200" BlockType="F" ItemId="xxxx"/>
--							<Block BlockIndex="1300" BlockType="F" ItemId="xxxx"/>
--							<Block BlockIndex="1400" BlockType="F" ItemId="xxxx"/>
--						</Blocks>
--					</Device>
--				</Root>'
--
---- Output: -
--	@Error - Error message to be sent up the chain
--
-- Returns -
--	0 - successful.
--	-1 - general error.
--	-2 - No device found in the input xml.
--
-- Nghy Hong - 06/01/2011
--
CREATE PROCEDURE AmsSp_SyncInstantiableFuncBlockAsgm_1
@DevBlockParams xml,
@Error nvarchar(max) output
AS
declare @nReturn int, @ErrorCode int;
set @nReturn = 0;
set @ErrorCode = -1; -- general error
declare @ErrMsg nvarchar(255);
declare @hDoc int;

BEGIN TRY
	declare @BlockTable table(
	DevId nvarchar(255),
	BlockIndex int,
	BlockType nvarchar(1),
	DDItemId nvarchar(255));
	
	--Fill @BlockTable with all blocks (include the ones with no parameter data)
	-- Transfer data from xml to the temporary table
	exec sp_xml_preparedocument @hDoc OUTPUT, @DevBlockParams
	insert into @BlockTable
	select * from openxml(@hDoc, 'Root/Device/Blocks/Block', 1) 
	with( 
	DevId nvarchar(255) '../../@DevId',
	BlockIndex int '@BlockIndex',
	BlockType nvarchar(1) '@BlockType',
	DDItemId nvarchar(255) '@ItemId'
	);
	-- release xml doc handle
	exec sp_xml_removedocument @hDoc
	
	-- Get device id (Support only one device instance at a time)
	declare @DevId nvarchar(255);
	set @DevId = N'';
	select top 1 @DevId = DevId from @BlockTable;

	if (len(@DevId) = 0)
	begin
		set @ErrorCode = -2; 
		RAISERROR(N'No device found in the input xml.', 11,/*Severity*/ 1/*State*/);
	end
	
	declare @DbFuncBlockAsms table(
	DevId nvarchar(255),
	BlockIndex int,
	BlockType nvarchar(1),
	DDItemId nvarchar(255),
	BlockKey int);

	--Fetch instantiable function blocks from database
	--Get all the current(UtcDateTimeOut = 9999-12-31) instantiable function blocks
	insert into @DbFuncBlockAsms
	select Devices.Identifier, InstantiableConfigBlocks.BlockIndex, InstantiableConfigBlocks.BlockType, 
			InstantiableBlockAsgms.DDItemId, InstantiableBlockAsgms.InstantiableBlockKey
	from  InstantiableBlockAsgms inner join
		   InstantiableConfigBlocks ON InstantiableBlockAsgms.InstantiableBlockKey = InstantiableConfigBlocks.InstantiableBlockKey 
		   inner join Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey
	WHERE (Devices.Identifier = @DevId)
	AND (InstantiableBlockAsgms.UtcDateTimeOut = N'9999-12-31')	

	declare @DbDevId nvarchar(255);
	declare @DbBlockIndex int;
	declare @DbBlockType nvarchar(1);
	declare @DbDDItemId nvarchar(255);
	declare @DbBlockKey int;
	--Cycle thru the resultset and set the UtcDateTimeOut to the current Utc 
	--for those instantiable blocks not in the xml
	declare blockCursor cursor for select * from @DbFuncBlockAsms;
	open blockCursor;
	fetch next from blockCursor into @DbDevId, @DbBlockIndex, @DbBlockType, @DbDDItemId, @DbBlockKey
	while (@@fetch_status = 0)
	begin
		if not exists (
		select * from @BlockTable where 
		DevId = @DbDevId and BlockIndex = @DbBlockIndex and BlockType = @DbBlockType and DDItemId = @DbDDItemId
		)
		begin
			Update InstantiableBlockAsgms set UtcDateTimeOut = SYSUTCDATETIME()
			where InstantiableBlockKey = @DbBlockKey and DDItemId = @DbDDItemId and UtcDateTimeOut = N'9999-12-31';
		end

		fetch next from blockCursor into @DbDevId, @DbBlockIndex, @DbBlockType, @DbDDItemId, @DbBlockKey;
	end

	close blockCursor;
	deallocate blockCursor;

END TRY
BEGIN CATCH
	set @nReturn = @ErrorCode;
	set @Error = 'Error code:  ' + cast(@ErrorCode as nchar(3))
						+ ';  Error Message:  ' + ERROR_MESSAGE()
						+ ';  Stored Procedure:  ' + ERROR_PROCEDURE();

END CATCH

return @nReturn;

GO

