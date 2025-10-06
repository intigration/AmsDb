
-- return code = -1 default
-- return code = 1 failed to delete block instance assosiated with dup dev. Transaction is rollback
-- return code = 0 all block instances assosiated with dup dev are sucessfully removed

-- return code = -99 no BlockKey found

CREATE PROCEDURE AmsSp_DeleteBlockInstance_1
@nDeviceKey int,
@nBlockIndex int
as

set nocount on

declare @nReturn int
declare @nDupBlockKeyBad int
declare @nSuccess int
declare @sMessage nvarchar(255)

set @nReturn = 0
set @nSuccess = 0

begin transaction 

select @nDupBlockKeyBad = BlockKey from Blocks where DeviceKey = @nDeviceKey and BlockIndex = @nBlockIndex

if @nDupBlockKeyBad = -1 or @nDupBlockKeyBad Is Null
	begin
		set @nReturn = -99
		goto ErrExit
	end

-- delete blockData
if @nSuccess <> 1 
	begin
		delete from BlockData where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove BlockData associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust hierarchy
if @nSuccess <> 1
	begin 
		delete from Components where TableKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove Components associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust TestResults
if @nSuccess <> 1 
	begin
		delete from TestResults where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove TestResults associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust AlertFilterForDevice
if @nSuccess <> 1 
	begin
		delete from AlertFilterForDevice where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove AlertFilterForDevice associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust DeviceMonitorList
if @nSuccess <> 1 
	begin
		delete from DeviceMonitorList where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove DeviceMonitorList associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust AlertList
if @nSuccess <> 1 
	begin
		delete from AlertList where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove AlertList associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust DeviceLocation
if @nSuccess <> 1 
	begin
		delete from DeviceLocation where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove DeviceLocation associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust SnapOnData
if @nSuccess <> 1 
	begin
		delete from SnapOnData where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove SnapOnData associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
-- adjust BlockAsgms
if @nSuccess <> 1 
	begin
		delete from BlockAsgms where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove BlockAsgms associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end

-- adjust AlertLog before doing EventLog
if @nSuccess <> 1 
	begin
		delete AlertLog from AlertLog INNER JOIN EventLog 
								ON AlertLog.EventIdDay = EventLog.EventIdDay AND AlertLog.EventIdFraction = EventLog.EventIdFraction
				  where Eventlog.blockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove AlertLog associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end
	end 

-- adjust EventLog
if @nSuccess <> 1 
	begin
		delete from EventLog where BlockKey = @nDupBlockKeyBad
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove EventLog associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
		
-- remove block
if @nSuccess <> 1 
	begin
		delete from Blocks where BlockKey = @nDupBlockKeyBad 
		if @@Error <> 0
			begin
				set @nSuccess = 1
				SELECT @sMessage = N'failed to remove Blocks associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N' .'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
					insert into ##RepairDupDevTypeInfo values (@sMessage)
			end 
	end
		
-- service the transaction
if (@nSuccess <> 0)
	begin
		SELECT @sMessage = N'failed to remove block instance associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar) + N' and BlockIndex= ' + cast(@nBlockIndex as nvarchar) + N', transaction rollback occured.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = 1	
		goto ErrExit
	end

-- Normal exit
if @@TRANCOUNT > 0 commit transaction 
return @nReturn

-- Error Exit
ErrExit:
if @@TRANCOUNT > 1
  commit transaction
else
  if @@TRANCOUNT = 1
  begin
    -- need issue what's in temp table before we rollback.
    IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
	select * from ##RepairDupDevTypeInfo
    rollback transaction
  end

return @nReturn

GO

