
CREATE PROCEDURE AmsSp_DeleteDeviceInstance_1
@nDeviceKey int
as

set nocount on

declare @nReturn int
select @nReturn = 0
declare @nSuccess int
select @nSuccess = 0
declare @sMessage nvarchar(255)

begin transaction

-- for each of the block instances.
declare DeviceBlocksListCursor CURSOR
STATIC FOR
SELECT  b1.BlockIndex
FROM  dbo.Blocks as b1
where (b1.DeviceKey = @nDeviceKey)
order by b1.BlockIndex
--
--
--
declare @nBlockIndex int
--
open DeviceBlocksListCursor
--
Fetch Next from DeviceBlocksListCursor into @nBlockIndex
--
declare @nDeleteBlockInstanceStatus int
select @nDeleteBlockInstanceStatus = 0
--

while (@@fetch_status = 0)
	begin
		if @nBlockIndex is not null
			begin
				exec @nDeleteBlockInstanceStatus = AmsSp_DeleteBlockInstance_1 @nDeviceKey, @nBlockIndex	
				if (@nDeleteBlockInstanceStatus = 1)
				begin
					select @nSuccess = 1
					goto cleanup
				end
			end
			-- get next duplicate in the list
			Fetch Next from DeviceBlocksListCursor into @nBlockIndex
	end
		
	cleanup:
	-- cleanup cursor
	close DeviceBlocksListCursor
	deallocate DeviceBlocksListCursor

-- delete device level information.
-- get rid of the CalStatus stuff.
if (@nSuccess = 0)
begin
	delete from calstatus where devicekey = @nDeviceKey
	if (@@error <> 0)
	begin
		SELECT @sMessage = N'failed to remove calstatus associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar)  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nSuccess = 1
	end
end

-- delete device instantiation blocks
if (@nSuccess = 0)
begin
	begin try
		declare @sDevId nvarchar(255);
		select @sDevId = DeviceKey From Devices where DeviceKey = @nDeviceKey;
		exec AmsSp_DeleteInstantiationBlocks_1 @sDevId;
	end try
	begin catch
		SELECT @sMessage = N'failed to remove Devices associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar)  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb..sysobjects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nSuccess = 1
	end catch
end

-- delete the device
if (@nSuccess = 0)
begin
	delete from Devices where devicekey = @nDeviceKey
	if (@@error <> 0)
	begin
		SELECT @sMessage = N'failed to remove Devices associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar)  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nSuccess = 1
	end
end

if (@nSuccess <> 0)
	begin
		SELECT @sMessage = N'failed to remove device instance associated with duplicate device with DeviceKey= ' + cast(@nDeviceKey as nvarchar)  + ', transaction rollback occured.'
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

