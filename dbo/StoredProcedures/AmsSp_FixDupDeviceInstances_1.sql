
CREATE PROCEDURE AmsSp_FixDupDeviceInstances_1
@nAmsDevRevIdGood int,
@nAmsDevRevIdBad int
as
set nocount on

begin transaction 

declare @nReturn int
select @nReturn = 0
declare @nSuccess int
select @nSuccess = 0
declare @sMessage nvarchar(255)

print N'Executing AmsSp_FixDupDeviceInstances_1. ' 
print N'  Good AmsDevRevId= ' + cast(@nAmsDevRevIdGood as nvarchar(10)) + N', Bad AmsDevRevId= ' + cast(@nAmsDevRevIdBad as nvarchar(10))

-- get list of devices that have instances on both the good deviceRevision and the bad.
declare DupDeviceInstancesListCursor CURSOR
STATIC FOR
SELECT  distinct d1.Identifier as Identifier,
	(select count(*) from devices as d2
		where (d2.Identifier = d1.Identifier)
			and ((d2.AmsDevRevId = @nAmsDevRevIdGood)
			or  (d2.AmsDevRevId = @nAmsDevRevIdBad))) as DupCt
FROM  dbo.Devices as d1
where ((d1.AmsDevRevId = @nAmsDevRevIdGood) or (d1.AmsDevRevId = @nAmsDevRevIdBad))
	and (1 < (select count(*) from devices as d3
		where (d3.Identifier = d1.Identifier)
			and ((d3.AmsDevRevId = @nAmsDevRevIdGood)
			or  (d3.AmsDevRevId = @nAmsDevRevIdBad))))
order by d1.identifier
--
--
--
declare @sIdentifier nvarchar(255)
declare @nDupCt int
--
open DupDeviceInstancesListCursor
--
Fetch Next from DupDeviceInstancesListCursor into @sIdentifier, @nDupCt
--
declare @nDupDeviceInstanceFixStatus int
--
while (@@fetch_status = 0)
	begin
		-- process this duplicated device instance.
		print N'Duplicate device identifier= ' + @sIdentifier + N' DupCt=' + cast(@nDupCt as nvarchar(10))
	
		exec @nDupDeviceInstanceFixStatus = AmsSp_FixDupDeviceInstance_1 @sIdentifier,
						@nAmsDevRevIdGood,
						@nAmsDevRevIdBad
		if (@nDupDeviceInstanceFixStatus <> 0)
		begin
			select @nSuccess = 1
			goto cleanup
		end
	
		-- get next duplicate in the list
		Fetch Next from DupDeviceInstancesListCursor into @sIdentifier,
							@nDupCt
	end

cleanup:
-- cleanup
close DupDeviceInstancesListCursor
deallocate DupDeviceInstancesListCursor

if @nSuccess <> 0
	begin
		SELECT @sMessage = N'failed to fix duplicate device instances associated with AmsDevRevIdBad ' + cast(@nAmsDevRevIdBad as nvarchar(10))  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = 1
		goto ErrExit
	end
else
	begin
		if @@TRANCOUNT > 0 commit transaction 
		return 0
	end

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

