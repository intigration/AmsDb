
CREATE PROCEDURE AmsSp_DeleteDevRevInstance_1
@nAmsDevRevId int
as
begin transaction

set nocount on

declare @nReturn int
select @nReturn = 0
declare @nSuccess int
select @nSuccess = 0
declare @sMessage nvarchar(255)

-- for each of the block instances.
declare DeviceListCursor CURSOR
STATIC FOR
SELECT  b1.DeviceKey
FROM  dbo.Devices as b1
where (b1.AmsDevRevId = @nAmsDevRevId)
order by b1.DeviceKey
--
--
--
declare @nDeviceKey int
--
open DeviceListCursor
--
Fetch Next from DeviceListCursor into @nDeviceKey
--
declare @nDeleteDeviceInstanceStatus int
select @nDeleteDeviceInstanceStatus = 0
--
if @nDeviceKey <> 0 and @nDeviceKey is not null
	begin
		while (@@fetch_status = 0)
		begin
			exec @nDeleteDeviceInstanceStatus = AmsSp_DeleteDeviceInstance_1 @nDeviceKey	
			if (@nDeleteDeviceInstanceStatus = 1)
			begin
				select @nSuccess = 1
				goto cleanup
			end
		
			-- get next duplicate in the list
			Fetch Next from DeviceListCursor into @nDeviceKey
		end
	end

	cleanup:
	-- cleanup cursor
	close DeviceListCursor
	deallocate DeviceListCursor

if (@nSuccess = 0)
	begin
		-- get the namedConfigs associated with the bad device revision.
		declare @nBadDevRevKey int
		declare @nConfigKey int
		declare @sConfigName nvarchar(50)
		declare @nLoopCt int
	
		set @nLoopCt = 0
		set @nBadDevRevKey = @nAmsDevRevId
		while (@nLoopCt < 2)
		begin
			declare NamedConfigCursor CURSOR
			STATIC FOR
			select ConfigKey, ConfigName from NamedConfigs where AmsDevRevId = @nBadDevRevKey
			open NamedConfigCursor
			
			-- we will loop until end of cursor
			Fetch Next from NamedConfigCursor into @nConfigKey, @sConfigName
			while (@@fetch_status = 0)
			begin
				-- adjust NamedConfigData
				if (@nSuccess = 0)
					begin
						delete from NamedConfigData where ConfigKey = @nConfigKey
						if @@Error <> 0
							begin
								SELECT @sMessage = N'failed to remove NamedConfigData associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
								IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
									insert into ##RepairDupDevTypeInfo values (@sMessage)
								set @nSuccess = 1
								goto NamedConfig_cleanup
							end
					end
				-- adjust NamedConfigBlocks
				
				if (@nSuccess = 0) 
					begin
						delete from NamedConfigBlocks where ConfigKey = @nConfigKey
						if @@Error <> 0
							begin
								SELECT @sMessage = N'failed to remove NamedConfigBlocks associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
								IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
									insert into ##RepairDupDevTypeInfo values (@sMessage)
								set @nSuccess = 1
								goto NamedConfig_cleanup
							end
					end
			
				Fetch Next from NamedConfigCursor into @nConfigKey, @sConfigName
			end
	
			if (@nSuccess = 0) 
				begin
					delete from NamedConfigs where AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove NamedConfigs associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
					end
	
			NamedConfig_cleanup:
				-- cleanup NamedConfig cursor
				close NamedConfigCursor
				deallocate NamedConfigCursor
	
			-- remove device revision extended properties associated with the bad device revision entry
			if (@nSuccess = 0)
				begin
	 				delete from DevRevExtProperty where AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove DeviceRevisions Extended property associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
				end
	
			-- remove device revision extended device alert description associated with the bad device revision entry
			if (@nSuccess = 0)
				begin
					DELETE FROM ExtDeviceAlertDesc
					FROM ExtDeviceAlertDesc INNER JOIN
						 DeviceAlertDesc ON ExtDeviceAlertDesc.AlertDescId = DeviceAlertDesc.AlertDescId
					WHERE DeviceAlertDesc.AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove extended device alert description associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
				end
	
			-- remove alert filter for device associated with the bad device revision entry
			if (@nSuccess = 0)
				begin
					DELETE FROM AlertFilterForDevice
					FROM AlertFilterForDevice INNER JOIN
						 DeviceAlertDesc ON AlertFilterForDevice.AlertDescId = DeviceAlertDesc.AlertDescId
					WHERE DeviceAlertDesc.AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove alert filter for device associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
				end

			-- remove device alert description associated with the bad device revision entry
			if (@nSuccess = 0)
				begin
					-- delete the 'bad' device alert description
					DELETE FROM DeviceAlertDesc WHERE AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove device alert description associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
				end
	
			-- remove the bad device revision entry
			if (@nSuccess = 0)
				begin
	 				delete from DeviceRevisions where AmsDevRevId = @nBadDevRevKey
					if @@Error <> 0
						begin
							SELECT @sMessage = N'failed to remove DeviceRevisions associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + N'.'
							IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
								insert into ##RepairDupDevTypeInfo values (@sMessage)
							set @nSuccess = 1
						end
				end
	
			set @nLoopCt = @nLoopCt + 1
		end
	end

if (@nSuccess <> 0)
	begin
		SELECT @sMessage = N'failed to remove device instance associated with duplicate device with AmsDevRevId= ' + cast(@nAmsDevRevId as nvarchar)  + ', transaction rollback occured.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		begin
			insert into ##RepairDupDevTypeInfo values (@sMessage)
			-- we need to issue the recordset before we do the rollback or else we will lose it.
			select * from ##RepairDupDevTypeInfo
		end
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

