
CREATE PROCEDURE AmsSp_DeleteDeviceType_1
@nAmsDevTypeId int
as

set nocount on

declare @nReturn int
select @nReturn = 0
declare @nSuccess int
select @nSuccess = 0
declare @sMessage nvarchar(255)

begin transaction

-- for each of the block instances.
declare DevRevListCursor CURSOR
STATIC FOR
SELECT  b1.AmsDevRevId
FROM  dbo.DeviceRevisions as b1
where (b1.AmsDevTypeId = @nAmsDevTypeId)
order by b1.AmsDevRevId
--
--
--
declare @nAmsDevRevId int
--
open DevRevListCursor
--
Fetch Next from DevRevListCursor into @nAmsDevRevId
--
declare @nDeleteDevRevInstanceStatus int
select @nDeleteDevRevInstanceStatus = 0
--
while (@@fetch_status = 0)
	begin
		if @nAmsDevRevId <> 0 and @nAmsDevRevId is not null
			begin
				exec @nDeleteDevRevInstanceStatus = AmsSp_DeleteDevRevInstance_1 @nAmsDevRevId	
				if (@nDeleteDevRevInstanceStatus = 1)
				begin
					select @nSuccess = 1
					goto cleanup
				end
			end
		
		-- get next duplicate in the list
		Fetch Next from DevRevListCursor into @nAmsDevRevId
	end
		
	cleanup:
	-- cleanup cursor
	close DevRevListCursor
	deallocate DevRevListCursor

-- delete the deviceTypes
if (@nSuccess = 0)
begin
	delete from DeviceTypes where AmsDevTypeId = @nAmsDevTypeId
	if (@@error <> 0)
	begin
		set @nSuccess = 1
	end
end

if (@nSuccess <> 0)
	begin
		SELECT @sMessage = N'failed to remove device instance associated with duplicate device with AmsDevTypeId= ' + cast(@nAmsDevTypeId as nvarchar)  + N'.'
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

