

CREATE PROCEDURE AmsSp_FixDupDeviceInstance_1
@sIdentifier nvarchar(255),
@nAmsDevRevIdGood int,
@nAmsDevRevIdBad int
as
set nocount on

declare @nReturn int
select @nReturn = 0
declare @sMessage nvarchar(255)
--DECLARE @Trans bit
--DECLARE @SavePoint uniqueidentifier 

begin transaction 

--SET @Savepoint = newid() 
--SAVE TRAN @Savepoint -- Save point for local overall rollback 

print N'Executing AmsSp_FixDupDeviceInstance_1.'
print N' Device identifier= ' + @sIdentifier + N', Good AmsDevRevId= ' + cast(@nAmsDevRevIdGood as nvarchar(10)) + N', Bad AmsDevRevId= ' + cast(@nAmsDevRevIdBad as nvarchar(10))

-- Rule 1. We only work with certain duplicate count.
declare @nDupCt int
select @nDupCt = count(*)
from devices as d1
where (d1.Identifier = @sIdentifier)
	and ((d1.AmsDevRevId = @nAmsDevRevIdGood)
	or  (d1.AmsDevRevId = @nAmsDevRevIdBad))
print N'Duplicate count for identifier ' + @sIdentifier + N' = ' + cast(@nDupCt as nvarchar(10))
if (@nDupCt <> 2)
	begin
		SELECT @sMessage = N'cannot process this duplicate count, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		--print 'Error- cannot process this duplicate count.'
		set @nReturn = -1
		GOTO ErrExit
	end

-- get the device data needed to determine which instance to delete.
declare DupDeviceInstanceCursor CURSOR
STATIC FOR
SELECT  distinct m1.Name as Manufacturer,
	mp1.MfrId as MfrId, 
	dt1.DeviceType AS DevTypeCode,
	dt1.Name as DevTypeName,
	dt1.AmsDevTypeId,
	dr1.DeviceRevision AS DevRevCode,
	dr1.Name as DevRevName,
	dr1.AmsDevRevId,
	d1.Identifier,
	d1.DeviceKey,
	b1.BlockKey,
	(select count(*) from Blocks as b2 where b2.DeviceKey = d1.DeviceKey) as BlockCt,
	(select count(*) from BlockData as bd2 where b1.BlockKey = bd2.BlockKey) as BlockDataCt,
	(select count(*) from BlockAsgms as ba2 where b1.BlockKey = ba2.BlockKey) as BlockAsgmCt,
	(select count(*) from DeviceMonitorList as ml2 where b1.BlockKey = ml2.BlockKey) as ScanListCt,
	(select count(*) from Components as hier2 where b1.BlockKey = hier2.TableKey) as HierarchyCt,
	(select count(*) from EventLog as el2 where b1.BlockKey = el2.BlockKey) as EventLogCt,
	(select count(*) from SnapOnData as sod2 where b1.BlockKey = sod2.BlockKey) as SnapOnDataCt,
	(select count(*) from TestResults as tr2 where b1.BlockKey = tr2.BlockKey) as TestResultsCt
FROM  dbo.Manufacturers as m1 INNER JOIN
      dbo.MfrProtocols as mp1 ON m1.AmsMfrNameId = mp1.AmsMfrNameId INNER JOIN
      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId INNER JOIN
      dbo.Devices as d1 ON dr1.AmsDevRevId = d1.AmsDevRevId INNER JOIN
      dbo.Blocks as b1 ON d1.DeviceKey = b1.DeviceKey
WHERE (d1.Identifier = @sIdentifier)
	and ((d1.AmsDevRevId = @nAmsDevRevIdGood)
	or  (d1.AmsDevRevId = @nAmsDevRevIdBad))
--
--
--
declare @sManufacturer1 nvarchar(255)
declare @sMfrId1 nvarchar(255)
declare @sDevTypeCode1 nvarchar(255)
declare @sDevTypeName1 nvarchar(255)
declare @sDevRevCode1 nvarchar(255)
declare @sDevRevName1 nvarchar(255)
declare @nAmsDevTypeId1 int
declare @nAmsDevRevId1 int
declare @sIdentifier1 nvarchar(255)
declare @nDeviceKey1 int
declare @nBlockKey1 int
declare @nBlockCt1 int
declare @nBlockDataCt1 int
declare @nBlockAsgmCt1 int
declare @nScanListCt1 int
declare @nHierarchyCt1 int
declare @nEventLogCt1 int
declare @nSnapOnDataCt1 int
declare @nTestResultsCt1 int
declare @sAmsTag1 nvarchar(255)
--
declare @sManufacturer2 nvarchar(255)
declare @sMfrId2 nvarchar(255)
declare @sDevTypeCode2 nvarchar(255)
declare @sDevTypeName2 nvarchar(255)
declare @sDevRevCode2 nvarchar(255)
declare @sDevRevName2 nvarchar(255)
declare @nAmsDevTypeId2 int
declare @nAmsDevRevId2 int
declare @sIdentifier2 nvarchar(255)
declare @nDeviceKey2 int
declare @nBlockKey2 int
declare @nBlockCt2 int
declare @nBlockDataCt2 int
declare @nBlockAsgmCt2 int
declare @nScanListCt2 int
declare @nHierarchyCt2 int
declare @nEventLogCt2 int
declare @nSnapOnDataCt2 int
declare @nTestResultsCt2 int
declare @sAmsTag2 nvarchar(255)
--
open DupDeviceInstanceCursor
--
Fetch Next from DupDeviceInstanceCursor into @sManufacturer1,
					@sMfrId1,
					@sDevTypeCode1,
					@sDevTypeName1,
					@nAmsDevTypeId1,
					@sDevRevCode1,
					@sDevRevName1,
					@nAmsDevRevId1,
					@sIdentifier1,
					@nDeviceKey1,
					@nBlockKey1,
					@nBlockCt1,
					@nBlockDataCt1,
					@nBlockAsgmCt1,
					@nScanListCt1,
					@nHierarchyCt1,
					@nEventLogCt1,
					@nSnapOnDataCt1,
					@nTestResultsCt1
if (@@fetch_status <> 0)
	begin
		-- we should have got the first one here!
		print N'Error- did not retrieve the 1st device type!'
		SELECT @sMessage = N'did not retrieve the 1st device type, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')				
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		-- cleanup
		close DupDeviceInstanceCursor
		deallocate DupDeviceInstanceCursor
		set @nReturn = -99
		GOTO ErrExit
	end

Fetch Next from DupDeviceInstanceCursor into @sManufacturer2,
					@sMfrId2,
					@sDevTypeCode2,
					@sDevTypeName2,
					@nAmsDevTypeId2,
					@sDevRevCode2,
					@sDevRevName2,
					@nAmsDevRevId2,
					@sIdentifier1,
					@nDeviceKey2,
					@nBlockKey2,
					@nBlockCt2,
					@nBlockDataCt2,
					@nBlockAsgmCt2,
					@nScanListCt2,
					@nHierarchyCt2,
					@nEventLogCt2,
					@nSnapOnDataCt2,
					@nTestResultsCt2
if (@@fetch_status <> 0)
begin
	-- we should have got the second one here!
	print N'Error- did not retrieve the 2nd device type!'
	SELECT @sMessage = N'did not retrieve the 2nd device type, Identifier = ' + @sIdentifier  + N'.'
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	-- cleanup
	close DupDeviceInstanceCursor
	deallocate DupDeviceInstanceCursor
	set @nReturn = -99
	GOTO ErrExit
end

-- cleanup
close DupDeviceInstanceCursor
deallocate DupDeviceInstanceCursor

-- get the current AmsTag assignments
select @sAmsTag1 = et1.ExtBlockTag
from ExtBlockTags as et1 INNER JOIN
	BlockAsgms as ba1 on et1.ExtBlockTagKey = ba1.ExtBlockTagKey
where (ba1.BlockKey = @nBlockKey1) and (EventIdDayOut = 49710)

select @sAmsTag2 = et1.ExtBlockTag
from ExtBlockTags as et1 INNER JOIN
	BlockAsgms as ba1 on et1.ExtBlockTagKey = ba1.ExtBlockTagKey
where (ba1.BlockKey = @nBlockKey2) and (EventIdDayOut = 49710)

/*print 'Duplicate device summary--'
print @sManufacturer1 + ', ' + @sDevTypeName1 + ', ' + @sDevRevName1 + ', '
	+ cast(@nAmsDevTypeId1 as nvarchar(10)) + ', ' + cast(@nAmsDevRevId1 as nvarchar(10))
print @sManufacturer2 + ', ' + @sDevTypeName2 + ', ' + @sDevRevName2 + ', '
	+ cast(@nAmsDevTypeId2 as nvarchar(10)) + ', ' + cast(@nAmsDevRevId2 as nvarchar(10))*/

-- there just are certain cases that we will handle; the rest are deemed to complex at this time.
if (@nBlockCt2 <> 1) or (@nBlockCt1 <> 1)
	begin
		-- either device has multiple blocks.
		-- not sure what to do here.
		SELECT @sMessage = N'either device has multiple blocks, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit
	end
if (@nBlockDataCt2 <> 0) and (@nBlockDataCt1 <> 0)
	begin
		-- both devices have blockData.
		-- not sure what to do here.
		SELECT @sMessage = N'both devices have blockData, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit
	end
if (@nHierarchyCt2 <> 0) and (@nHierarchyCt1 <> 0)
	begin
		-- both devices are assigned.
		SELECT @sMessage = N'both devices are assigned, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit 
	end
if (@nScanListCt1 <> 0) and (@nScanListCt2 <> 0)
	begin
		-- both devices are in the DeviceMonitorList
		SELECT @sMessage = N'both devices are in the DeviceMonitorList, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit 
	end
if (@nBlockAsgmCt1 > 1) and (@nBlockAsgmCt2 > 1)
	begin
		-- both devices are in the BlockAsgms
		SELECT @sMessage = N'both devices are in the BlockAsgms, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit
	end

-- we determine which is the good versus the bad device by the following --
declare @nGoodOne int
declare @nBadOne int
select @nGoodOne = -99
select @nBadOne = -99
-- if a device has no blockData then it is the bad one.
if (@nGoodOne = -99)
	begin
		if (@nBlockDataCt1 = 0) and (@nBlockDataCt2 <> 0)
			begin
				select @nGoodOne = 2
				select @nBadOne = 1
			end
		else if (@nBlockDataCt2 = 0) and (@nBlockDataCt1 <> 0)
			begin
				select @nGoodOne = 1
				select @nBadOne = 2
			end
		else if (@nBlockDataCt2 = 0) and (@nBlockDataCt1 = 0)
			begin
				select @nGoodOne = 1
				select @nBadOne = 2
			end
		else if (@nBlockDataCt2 <> 0) and (@nBlockDataCt1 <> 0)
			begin
				-- both devices have blockData.
				-- not sure what to do here.
				SELECT @sMessage = N'both devices have blockData, Identifier = ' + @sIdentifier  + N'.'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
				set @nReturn = -2
				GOTO ErrExit
			end
	end
-- if the device assigned then it is the good one.
if (@nGoodOne = -99)
	begin
		if (@nHierarchyCt1 = 0) and (@nHierarchyCt2 <> 0)
			begin
				select @nGoodOne = 2
				select @nBadOne = 1
			end
		else if (@nHierarchyCt2 = 0) and (@nHierarchyCt1 <> 0)
			begin
				select @nGoodOne = 1
				select @nBadOne = 2
			end
		else if (@nHierarchyCt2 <> 0) and (@nHierarchyCt1 <> 0)
			begin
				-- both devices are assigned.
				SELECT @sMessage = N'both devices are assigned, Identifier = ' + @sIdentifier  + N'.'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
				set @nReturn = -2
				GOTO ErrExit
			end
	end
-- if the device is in the DeviceMonitorList then select that one.
if (@nGoodOne = -99)
	begin
		if (@nScanListCt1 = 0) and (@nScanListCt2 <> 0)
			begin
				select @nGoodOne = 2
				select @nBadOne = 1
			end
		else if (@nScanListCt1 <> 0) and (@nScanListCt2 = 0)
			begin
				select @nGoodOne = 1
				select @nBadOne = 2
			end
		else if (@nScanListCt1 <> 0) and (@nScanListCt2 <> 0)
			begin
				-- both devices are in the DeviceMonitorList
				SELECT @sMessage = N'both devices are in the DeviceMonitorList, Identifier = ' + @sIdentifier  + N'.'
				IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
					insert into ##RepairDupDevTypeInfo values (@sMessage)
				set @nReturn = -2
				GOTO ErrExit 
			end
	end
-- we should have determined by now or else error.
if (@nGoodOne = -99)
	begin
		-- failed to make determination !!
		print N'Error-- failed to make determination.'
		SELECT @sMessage = N'failed to make determination, Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -2
		GOTO ErrExit
	end
print N'GoodOne= ' + cast(@nGoodOne as nvarchar(10)) + N', BadOne= ' + cast(@nBadOne as nvarchar(10))

-- FUTURE- we may need to merge data.

-- Now we are safe to assume that the 'bad' device and all its associated data may be deleted.
declare @nDeleteDupDeviceInstanceStatus int
if (@nGoodOne = 1)
	exec @nDeleteDupDeviceInstanceStatus = AmsSp_DeleteDeviceInstance_1 @nDeviceKey2 -- bad one								
else
	exec @nDeleteDupDeviceInstanceStatus = AmsSp_DeleteDeviceInstance_1 @nDeviceKey1 -- bad one
									
if (@nDeleteDupDeviceInstanceStatus <> 0)
	begin
		SELECT @sMessage = N'unable to fix duplicate device Iinstance with Identifier = ' + @sIdentifier  + N'.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -3 -- unable to resolve duplicate device instances associated with this deviceType
		GOTO ErrExit 
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

