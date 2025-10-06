
CREATE PROCEDURE AmsSp_FixDupDevType_1
@sMfrId nvarchar(255),
@sProtocol nvarchar(255),
@sDeviceTypeCode nvarchar(255),
@sDeviceRevisionCode nvarchar(255)
as
set nocount on

begin transaction 

declare @nReturn int
select @nReturn = 0
declare @nSuccess int
select @nSuccess = 0
declare @sMessage nvarchar(255)

select @sMessage = N'Executing AmsSp_FixDupDevType_1. '+ N'Protocol=' + @sProtocol + N', MfrId=' + @sMfrId + N', DevTypeCode=' + @sDeviceTypeCode + N', DevRevCode=' + @sDeviceRevisionCode
IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
	insert into ##RepairDupDevTypeInfo values (@sMessage)

-- Rule 1.  We only work with HART or FF or PROFIBUS-DP or PROFIBUS-PA.
if (@sProtocol <> N'HART') and (@sProtocol <> N'FF') and (@sProtocol <> N'PROFIBUS-DP') and (@sProtocol <> N'PROFIBUS-PA')
begin
	select @sMessage = N' this process does not support this protocol- ' + @sProtocol
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	set @nReturn = -1
	goto ErrExit
end

-- Rule 2. We only work with certain duplicate count.
declare @nDupCt int
select @nDupCt = count(*)
FROM         dbo.Manufacturers as m1 INNER JOIN
                      dbo.MfrProtocols as mp1 ON m1.AmsMfrNameId = mp1.AmsMfrNameId INNER JOIN
                      dbo.DeviceProtocols as dp1 ON mp1.ProtocolId = dp1.ProtocolId INNER JOIN
                      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId
where (mp1.mfrid = @sMfrId) and (dt1.DeviceType = @sDeviceTypeCode) and (dr1.DeviceRevision = @sDeviceRevisionCode)
print N'Duplicate count for ' + @sMfrId + N'.' + @sDeviceTypeCode + N'.' + @sDeviceRevisionCode + N' = ' + cast(@nDupCt as nvarchar(10))
if (@nDupCt <> 2)
begin
	--print 'Error- cannot process this duplicate count.'
	select @sMessage = N'cannot process this duplicate count. '
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	set @nReturn = -2
	goto ErrExit 
end

-- get the duplicate device type data.
declare DupDevTypeListCursor CURSOR
STATIC FOR
SELECT  distinct m1.Name as Manufacturer,
	mp1.MfrId as MfrId, 
	dt1.DeviceType AS DevTypeCode,
	dt1.Name as DevTypeName,
	dt1.AmsDevTypeId,
	dr1.DeviceRevision AS DevRevCode,
	dr1.Name as DevRevName,
	dr1.AmsDevRevId,
	(select count(*) from devices where devices.AmsDevRevId = dr1.AmsDevRevId) as DeviceCt,
	(select count(*) from NamedConfigs where NamedConfigs.AmsDevRevId = dr1.AmsDevRevId) as TemplateCt
FROM  dbo.Manufacturers as m1 INNER JOIN
      dbo.MfrProtocols as mp1 ON m1.AmsMfrNameId = mp1.AmsMfrNameId INNER JOIN
      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId
WHERE (mp1.MfrId = @sMfrId)
	and (dt1.DeviceType = @sDeviceTypeCode)
	and (dr1.DeviceRevision = @sDeviceRevisionCode)
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
declare @nDeviceCt1 int
declare @nTemplateCt1 int
--
declare @sManufacturer2 nvarchar(255)
declare @sMfrId2 nvarchar(255)
declare @sDevTypeCode2 nvarchar(255)
declare @sDevTypeName2 nvarchar(255)
declare @sDevRevCode2 nvarchar(255)
declare @sDevRevName2 nvarchar(255)
declare @nAmsDevTypeId2 int
declare @nAmsDevRevId2 int
declare @nDeviceCt2 int
declare @nTemplateCt2 int
--
open DupDevTypeListCursor
--
Fetch Next from DupDevTypeListCursor into @sManufacturer1,
					@sMfrId1,
					@sDevTypeCode1,
					@sDevTypeName1,
					@nAmsDevTypeId1,
					@sDevRevCode1,
					@sDevRevName1,
					@nAmsDevRevId1,
					@nDeviceCt1,
					@nTemplateCt1
if (@@fetch_status <> 0)
begin
	-- we should have got the first one here!
	--print 'Error- did not retrieve the 1st device type!'
	select @sMessage = N'did not retrieve the 1st device type. '
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	set @nReturn = -99
	goto ErrExit 
end
Fetch Next from DupDevTypeListCursor into @sManufacturer2,
					@sMfrId2,
					@sDevTypeCode2,
					@sDevTypeName2,
					@nAmsDevTypeId2,
					@sDevRevCode2,
					@sDevRevName2,
					@nAmsDevRevId2,
					@nDeviceCt2,
					@nTemplateCt2
if (@@fetch_status <> 0)
begin
	-- we should have got the second one here!
	--print 'Error- did not retrieve the 2nd device type!'
	select @sMessage = N'did not retrieve the 2nd device type. '
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	set @nReturn = -99
	goto ErrExit
end

-- cleanup
close DupDevTypeListCursor
deallocate DupDevTypeListCursor
print N'Duplicate device type summary--'
print @sManufacturer1 + N', ' + @sDevTypeName1 + N', ' + @sDevRevName1 + N', ' + cast(@nAmsDevTypeId1 as nvarchar(10)) + N', ' + cast(@nAmsDevRevId1 as nvarchar(10)) + N', ' + cast(@nDeviceCt1 as nvarchar(10)) + N', ' + cast(@nTemplateCt1 as nvarchar(10))
print @sManufacturer2 + N', ' + @sDevTypeName2 + N', ' + @sDevRevName2 + N', ' + cast(@nAmsDevTypeId2 as nvarchar(10)) + N', ' + cast(@nAmsDevRevId2 as nvarchar(10)) + N', ' + cast(@nDeviceCt2 as nvarchar(10)) + N', ' + cast(@nTemplateCt2 as nvarchar(10))

declare @nGoodOne int
declare @nBadOne int
declare @nAmsDevRevIdGood int
declare @nAmsDevRevIdBad int
select @nGoodOne = -99
select @nBadOne = -99
-- we determine which is the good versus the bad device type by the following --
-- if a devicetype does not have namedConfigs associated with it then we assume to be the
-- the bad one.
if (@nGoodOne = -99)
begin
	if (@nTemplateCt1 = 0) and (@nTemplateCt2 <> 0)
	begin
		select @nGoodOne = 2
		select @nBadOne = 1
	end
	else if (@nTemplateCt2 = 0) and (@nTemplateCt1 <> 0)
	begin
		select @nGoodOne = 1
		select @nBadOne = 2
	end
end
-- if a devicetype has no devices associated with it then we assume to be the bad one.
if (@nGoodOne = -99)
begin
	if (@nDeviceCt1 = 0) and (@nDeviceCt2 <> 0)
	begin
		select @nGoodOne = 2
		select @nBadOne = 1
	end
	else if (@nDeviceCt2 = 0) and (@nDeviceCt1 <> 0)
	begin
		select @nGoodOne = 1
		select @nBadOne = 2
	end
end
-- select the devicetype that was added later 
if (@nGoodOne = -99)
begin
	if (@nAmsDevTypeId1 > @nAmsDevTypeId2)
	begin
		select @nGoodOne = 2
		select @nBadOne = 1
	end
	else
	begin
		select @nGoodOne = 1
		select @nBadOne = 2
	end
end
-- we should have determined by now or else error.
if (@nGoodOne = -99)
begin
	-- failed to make determination !!
	--print 'Error-- failed to make determination.'
	select @sMessage = N'failed to make determination. '
	IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
		insert into ##RepairDupDevTypeInfo values (@sMessage)
	set @nReturn = -3
	goto ErrExit 
end
print N'GoodOne= ' + cast(@nGoodOne as nvarchar(10)) + N', BadOne= ' + cast(@nBadOne as nvarchar(10))

if (@nGoodOne = 1)
	begin
		set @nAmsDevRevIdGood = @nAmsDevRevId1
		set @nAmsDevRevIdBad = @nAmsDevRevId2
	end
else
	begin
		set @nAmsDevRevIdGood = @nAmsDevRevId2
		set @nAmsDevRevIdBad = @nAmsDevRevId1
	end

-- make sure that a device instance is not duplicated across these duplicate deviceTypes.
declare @nDupDeviceInstancesStatus int
exec @nDupDeviceInstancesStatus = AmsSp_FixDupDeviceInstances_1 @nAmsDevRevIdGood, -- good one
								@nAmsDevRevIdBad -- bad one
if (@nDupDeviceInstancesStatus <> 0)
	begin
		--print 'Error- unable to resolve duplicate device instances associated with this deviceType.'
		select @sMessage = N'unable to resolve duplicate device instances associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -4
		goto ErrExit 
	end

-- move the devices from the 'bad' deviceType to the 'good'.
update Devices set Devices.AmsDevRevId = @nAmsDevRevIdGood where Devices.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve devices associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -5
		goto ErrExit
	end

-- move the templates from the 'bad' deviceType to the 'good'.
update NamedConfigs set NamedConfigs.AmsDevRevId = @nAmsDevRevIdGood where NamedConfigs.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve templates associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -6
		goto ErrExit 
	end

--check if there is any dev rev assosiates with this dev type
declare @nDevTypeCount int
set @nDevTypeCount = 0
declare @nDevTypeId int
--get DeviceTypeId
set @nDevTypeId = 0
select @nDevTypeId = AmsDevTypeid from DeviceRevisions where AmsDevRevId = @nAmsDevRevIdBad
--get dev type count
select @nDevTypeCount = count (*) from DeviceRevisions
where AmsDevTypeId in (select AmsDevTypeid from DeviceRevisions where AmsDevRevId = @nAmsDevRevIdBad)
and AmsDevRevId <> @nAmsDevRevIdBad

-- delete the 'bad' DeviceRevisions extended property.
delete from DevRevExtProperty where DevRevExtProperty.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve DeviceRevisions extended property associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -7
		goto ErrExit
	end

-- delete the 'bad' extended device alert description
DELETE FROM ExtDeviceAlertDesc
FROM ExtDeviceAlertDesc INNER JOIN
     DeviceAlertDesc ON ExtDeviceAlertDesc.AlertDescId = DeviceAlertDesc.AlertDescId
WHERE DeviceAlertDesc.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve extended device alert description associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -7
		goto ErrExit
	end
	
-- delete the 'bad' alert filter for device 
DELETE FROM AlertFilterForDevice
FROM AlertFilterForDevice INNER JOIN
     DeviceAlertDesc ON AlertFilterForDevice.AlertDescId = DeviceAlertDesc.AlertDescId
WHERE DeviceAlertDesc.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve alert filter for device associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -7
		goto ErrExit
	end

-- delete the 'bad' device alert description
DELETE FROM DeviceAlertDesc WHERE AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve device alert description associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -7
		goto ErrExit
	end

-- delete the 'bad' DeviceRevisions.
delete from DeviceRevisions where DeviceRevisions.AmsDevRevId = @nAmsDevRevIdBad
if @@error <> 0
	begin
		select @sMessage = N'unable to resolve DeviceRevisions associated with this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -7
		goto ErrExit
	end

-- delete the 'bad' DeviceTypes.
if (@nDevTypeCount = 0) and (@nDevTypeId <> 0)
	delete from DeviceTypes where AmsDevTypeId = @nDevTypeId

if @@error <> 0
	begin
		select @sMessage = N'unable to remove this deviceType. '
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = -8
		goto ErrExit 
	end

if @@TRANCOUNT > 0 commit transaction 
return @nReturn

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

