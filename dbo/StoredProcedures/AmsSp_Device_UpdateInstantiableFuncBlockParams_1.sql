-------------------------------------------------------------------------------------------------------------------------------
-- AmsSp_Device_UpdateInstantiableFuncBlockParams_1
--
--  Add device's instantiable function block parameters, and add/update instantiable function block assignment base on the input xml.
-- 
-- Note:
--  1.  Ther standard function blocks could be in the supplied xml, but will be excluded from the operation, only the instantiable 
--		function blocks will be affected.
--	2.	Device's current instantiable function blocks not supplied in the input xml will be marked  
--		as past instantiable funtion block assignment/invalid. 
--		
--
-- Input:
--  @DevParams	- data in xml supporting single device, one or more Blocks and one or more Block parameters
--				<Root>
--					<Device DevId="00031020000008122009001010131293">
--						<Blocks>
--							<Block BlockIndex="1100" BlockType="F" ItemId="xxxx">
--								<Parameter ParamName="00000000:01" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:02" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:03" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:04" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:05" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:06" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:07" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:08" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:09" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:0A" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:0B" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:0C" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--								<Parameter ParamName="00000000:0D" ParamType="3" ParamSize="12" ParamData="0144FFFEFF00"/>
--							</Block>
--							<Block BlockIndex="1200" BlockType="F" ItemId="xxxx"/>
--								.
--								.
--								.
--							<Block BlockIndex="xxxx" BlockType="F" ItemId="xxxx"/>
--						</Blocks>
--					</Device>
--				</Root>'
--
--
---- Output: -
--	@Error - Error message to be sent up the chain
--
-- Returns -
--	0 - successful.
--	-1 - General error.
--	-2 - No device found in the input xml.
--	-3 - Device not found in the database.
--	-4 - Device has no standard blocks.
--  -5 - Error on adding new function blocks.
--  -6 - Error on updating instantiable function block assignments.
--  -7 - Error on generating event.
--  -8 - Error on synchronizing instantiable function block assignments.
--  -9 - Error on Adding current assigned instantiable Function blocks to Blocks table.
--
-- Nghy Hong - 06/01/2011
-- Nghy Hong - 02/08/2012 Updated process to also adding instantiable Function blocks to Blocks table.
CREATE PROCEDURE AmsSp_Device_UpdateInstantiableFuncBlockParams_1
@DevParams xml,
@Error nvarchar(max) output
AS
declare @nReturn int, @ErrorCode int;
set @nReturn = 0;
set @ErrorCode = -1; -- general error
declare @ErrMsg nvarchar(255);
declare @hDoc int;
declare @DataTable Table(
	DevId nvarchar(255),
	BlockIndex int,
	BlockType nvarchar(1),
	DDItemId nvarchar(255),
	ParamName nvarchar(255),
	ParamType int,
	ParamSize int,
	ParamData varchar(max)
);

declare @DevIdTable Table(DevId nvarchar(255));

BEGIN TRY
	BEGIN TRAN;

	-- Get xml doc handle
	exec sp_xml_preparedocument @hDoc OUTPUT, @DevParams
	-- Transfer blocks having parameter data from xml to the temporary table
	insert into @DataTable
	select * from openxml(@hDoc, 'Root/Device/Blocks/Block/Parameter', 1) 
	with( 
	DevId nvarchar(255) '../../../@DevId',
	BlockIndex int '../@BlockIndex',
	BlockType nvarchar(1) '../@BlockType',
	DDItemId nvarchar(255) '../@ItemId',
	ParamName nvarchar(255),
	ParamType int,
	ParamSize int,
	ParamData varchar(max)
	);
	
	insert into @DevIdTable
	select DevId from openxml(@hDoc, 'Root/Device', 1) 
	with(DevId nvarchar(225) '@DevId')
		
	-- release xml doc handle
	exec sp_xml_removedocument @hDoc

	-- Get device id (Support only one device instance at a time)
	declare @DevId nvarchar(255);
	set @DevId = N'';
	select top 1 @DevId = DevId from @DevIdTable;

	if (len(@DevId) = 0)
	begin
		set @ErrorCode = -2; 
		RAISERROR(N'No device found in the input xml.', 11,/*Severity*/ 1/*State*/);
	end

	-- make sure the device is in the database
	if not exists (select Identifier from Devices where Identifier = @DevId)
	begin
		set @ErrorCode = -3; 
		set @ErrMsg = N'Device ' + @DevId + N' not found in the database.'
		RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
	end

	----------------------------------------------
	--Support only one device instance at a time--
	----------------------------------------------
	delete from @DataTable where DevId <> @DevId

	-----------------------------------------------------------------
	-- Filter out the standard function block that are in the list --
	-----------------------------------------------------------------
	delete @DataTable
	from @DataTable T1 inner join 
	Devices on T1.DevId = Devices.Identifier inner join
	DeviceRevisions on Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId inner join
	NamedConfigs on DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId inner join
	NamedConfigBlocks on NamedConfigs.ConfigKey = NamedConfigBlocks.ConfigKey
	where T1.BlockIndex = NamedConfigBlocks.BlockIndex and T1.BlockType = NamedConfigBlocks.BlockType;	
	
	------------------
	-- Do the works --
	------------------
	declare @BlockIndex int;
	declare @BlockType nvarchar(1);
	declare @DDItemId nvarchar(255);
	declare @nEventIdDay int;
	declare @nEventIdFraction int;
	
	declare blockCursor cursor for select distinct DevId, BlockIndex, BlockType, DDItemId from @DataTable;
	open blockCursor;
	fetch next from blockCursor into @DevId, @BlockIndex, @BlockType, @DDItemId
	while (@@fetch_status = 0)
	begin
		---------------------------
		-- Servicing InstantiableConfigBlocks table--
		---------------------------
		declare @iDeviceKey int;
		declare @iBlockKey int

		-- Get device key
		select @iDeviceKey = DeviceKey from Devices
		where (Devices.Identifier = @DevId)

		if ( @@rowcount = 0 )
		begin
			set @ErrorCode = -4; 
			set @ErrMsg = N'Device id(' + @DevId + N') has no block data.'
			RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
		end

		-- Get/add InstantiableBlockKey from InstantiableConfigBlocks
		exec @nReturn = AmsSp_InstantiableConfigBlocks_GetAddId_1 @iDeviceKey, @BlockIndex, @BlockType, N'C', @iBlockKey output

		if (@nReturn <> 0) 
		begin
			set @ErrorCode = -5; 
			set @ErrMsg = N'AmsSp_InstantiableConfigBlocks_GetAddId_1 execution failed, its return code = ' + cast(@nReturn as nvarchar(10))
			RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
		end

		-----------------------------------------------------
		--  Servicing InstantiableFunctionBlockAsgms table --
		-----------------------------------------------------
		--Add/update instantiable function Blocks		
		exec @nReturn = AmsSp_UpdateInstantiableBlockAsgms_1 @iBlockKey, @DDItemId, @ErrMsg output
		
		if (@nReturn <> 0)
		begin
			set @ErrorCode = -6;
			RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
		end
		
		------------------------------
		-- Servicing InstantiableConfigData table--
		------------------------------
		-- Insert new BlockData --
		-- Generate new event
		exec @nReturn = AmsSp_LogEventSummary_1	N'NO_EVENTTIME',
												N'admin',
												-1,				--ComputerId
												-1,				--Device level BlockKey
												0,				--EventCode (always 0)
												N'Block instantiation',		--Source application
												1,				--Event type = CHANGE 
												28,				--Event category = Change performed by foreign host
												N'Field Change', --reason
												0,				--OtherBufLen
												NULL,			--Other
												0,				--Archived
												N'admin',
												@nEventIdDay output,
												@nEventIdFraction output,
												N'',				-- AlertId,
												N'',				-- AlertTypeUid,
												NULL,			-- MoreDetail,
												N''				-- OperationType

		if (@nReturn <> 0) 
		begin
			set @ErrorCode = -7; 
			set @ErrMsg = N'BlockData event generation failed.  ' + N'AmsSp_LogEventSummary_1 sp return code = ' + cast(@nReturn as nvarchar(10))
			RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
		end

		insert into InstantiableConfigData
		select @iBlockKey, @nEventIdDay, @nEventIdFraction, N'P', T1.ParamName, T1.ParamType, T1.ParamSize, T1.ParamData
		from @DataTable T1
		where T1.BlockIndex = @BlockIndex and T1.BlockType = @BlockType;
		
		fetch next from blockCursor into @DevId, @BlockIndex, @BlockType, @DDItemId;
	end

	close blockCursor;
	deallocate blockCursor;

	-----------------------------------------------------
	--  Servicing InstantiableBlockAsgms table --
	-----------------------------------------------------	
	--Set device's current instantiable function blocks to be invalid for those blocks not provided in the xml. 	
	exec @nReturn = AmsSp_SyncInstantiableFuncBlockAsgm_1 @DevParams, @ErrMsg output
	
	if (@nReturn <> 0)
	begin
		set @ErrorCode = -8;
		RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
	end
	
	---------------------------------
	--  Servicing Blocks table --
	---------------------------------
	--Add current assigned instantiable Function blocks to Blocks table 		
	exec @nReturn = AmsSp_Blocks_AddInstantiableBlocks @DevId, @ErrMsg output
	
	if (@nReturn <> 0)
	begin
		set @ErrorCode = -9;
		RAISERROR(@ErrMsg, 11,/*Severity*/ 1/*State*/);
	end

	--Commit the successful process
	if @@TRANCOUNT > 0 COMMIT TRAN;
END TRY
BEGIN CATCH
	set @nReturn = @ErrorCode;
	set @Error = 'Error code:  ' + cast(@ErrorCode as nchar(3))
						+ ';  Error Message:  ' + ERROR_MESSAGE()
						+ ';  Stored Procedure:  ' + ERROR_PROCEDURE();

	if @@TRANCOUNT > 1 COMMIT TRAN;
	else if @@TRANCOUNT = 1 ROLLBACK TRAN;
END CATCH


return @nReturn;

GO

