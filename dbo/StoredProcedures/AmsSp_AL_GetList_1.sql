
----------------------------------------------------------------------
-- AmsSp_AL_GetList_1
--
-- Get list from AL.
--
-- Inputs -
--	@sPsNamenvarchar(max) PlantServer name.  If blank then complete list returned.
--	@sInRevisionReference nvarchar(1024) - used to determine if the al for the plantServer has changed or not.
--  @bProduceList - used to indicate if the al should be output anyway(1), if this is
--					set to false(0) then the al will output only if it has changed.
--
--
-- Outputs -
--  @bListHasBeenUpdated
--  @bListHasBeenAddedTo
--	@sOutRevisionReference nvarchar(1024) - the new revisionReference, use this with the same PsName so you
--			know if al has been added-to and/or updated.
--  
--  Recordset containing the following columns --
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_GetList_1
@sPsName nvarchar(255),
@bProduceList int,
@sInRevisionReference nvarchar(1024),
@bListHasBeenUpdated int output,
@bListHasBeenAddedTo int output,
@sOutRevisionReference nvarchar(1024) output
AS
set nocount on
declare @nReturn int
set @nReturn = 0

-- go process the NotifyQ
--exec AmsSp_NotifyQ_Process_1

-- continue on with getting the active alert list.
set @bListHasBeenUpdated = 0
set @bListHasBeenAddedTo = 0

-- trim off white space on plantServer name.
set @sPsName = rtrim(ltrim(@sPsName))

declare @dtLastGetTime datetime
set @dtLastGetTime = @sInRevisionReference -- assumes that this contains only datetime string at this point.

exec AmsSp_ALTrack_HasBeenAdded_1 @dtLastGetTime, @bListHasBeenAddedTo output;
exec AmsSp_ALTrack_HasBeenUpdated_1 @dtLastGetTime, @bListHasBeenUpdated output;

-- now go ahead and update the revisionReference.
set @dtLastGetTime = GETUTCDATE()
set @sOutRevisionReference = convert(nvarchar(30), @dtLastGetTime, 126)

-- produce the list if the override, @bProduceList, is true OR
-- if we had additions or updates.
if (@bProduceList <> 0) or 
   ((@bListHasBeenUpdated <> 0) or (@bListHasBeenAddedTo <> 0))
begin
	if (@sPsName <> '')
	begin
		WITH CheckEnabledTable AS
		(
			SELECT ebt.ExtBlockTag as AmsTag,
				isnull(hier.Area,'')
				+ '\' + isnull(hier.Unit, '') 
				+ '\' + isnull(hier.Equipment, '')
				+ '\' + isnull(hier.Control, '') as HierarchyLocation,
				convert(nvarchar(30), als.AlertTime, 126) + 'Z' as AlertTime,
				cast(dml.MonitorGroup as nvarchar(10)) as MonitorGroup,
				als.AlertId as AlertId,
				alt.Uid as AlertTypeUid,
				alt.AlertTypeName as AlertTypeName,
				isnull(el.Description, '') as EventDescription,
				isnull(ps.PlantServerId, '') as PlantServerName,
				isnull(mpr.MfrId, '') as MfrId,
				isnull(mfr.Name, '') as Manufacturer,
				isnull(pr.Name, '') as Protocol,
				isnull(affd.Enabled, 'True') as Enabled,
				cast(dev.ProtocolRevision as nvarchar(10)) as ProtocolRevision,
				isnull(dt.DeviceType, '') as DeviceTypeCode,
				isnull(dt.Name, '') as DeviceTypeName,
				isnull(dr.DeviceRevision, '') as DeviceRevisionCode,
				isnull(dev.Identifier, '') as SerialNumber,
				isnull(als.SetCount, '') as SetCount,
				cast(als.EventIdDay as nvarchar(10)) as EventIdDay,
				cast(als.EventIdFraction as nvarchar(10)) as EventIdFraction,
				cast(als.AlertState as nvarchar(10)) as AlertState,
				cast(als.AckState as nvarchar(10)) as AckState
			from extblocktags as ebt with (nolock)
			inner join blockasgms as ba with (nolock)
					on (ebt.ExtBlockTagKey = ba.ExtBlockTagKey) and (ba.EventIdDayOut = 49710)
			inner join amsvw_blocklocation as hier with (nolock)
					on hier.TableKey = ba.BlockKey
			inner join alertlist as als with (nolock)
					on als.BlockKey = ba.BlockKey
			inner join devicemonitorlist as dml with (nolock)
					on dml.BlockKey = als.BlockKey
			inner join alertLog as al with (nolock)
					on al.eventIdDay = als.eventIdDay
						and al.eventIdFraction = als.eventIdFraction
			inner join alerttypes as alt with (nolock)
					on alt.AlertTypeId = al.AlertTypeId
			inner join eventlog as el with (nolock)
					on als.eventIdDay = el.eventIdDay
						and als.eventIdFraction = el.eventIdFraction
			inner join devicelocation as dl with (nolock)
					on dl.BlockKey = als.BlockKey
			inner join networkinfo as net with (nolock)
					on net.NetworkInfoKey = dl.NetworkInfoKey
			inner join plantserver as ps with (nolock)
					on ps.PlantServerKey = net.PlantServerKey
			inner join blocks as blk with (nolock)
					on blk.BlockKey = als.BlockKey
			inner join devices as dev with (nolock)
					on dev.DeviceKey = blk.DeviceKey
			inner join devicerevisions as dr with (nolock)
					on dr.AmsDevRevId = dev.AmsDevRevId
			inner join devicetypes as dt with (nolock)
					on dt.AmsDevTypeId = dr.AmsDevTypeId
			inner join mfrprotocols as mpr with (nolock)
					on mpr.MfrProtocolId = dt.MfrProtocolId
			inner join manufacturers as mfr with (nolock)
					on mfr.AmsMfrNameId = mpr.AmsMfrNameId
			inner join deviceprotocols as pr with (nolock)
					on pr.protocolId = mpr.protocolId
			left outer join devicealertdesc as dad with (nolock)
					on dad.AmsDevRevId = dev.AmsDevRevId and dad.AlertId = als.AlertId
			left outer join alertfilterfordevice as affd with (nolock)
					on affd.BlockKey = als.BlockKey and affd.AlertDescId = dad.AlertDescId
		)
		SELECT AmsTag,
			HierarchyLocation,
			AlertTime,
			MonitorGroup,
			AlertId,
			AlertTypeUid,
			AlertTypeName,
			EventDescription,
			PlantServerName,
			MfrId,
			Manufacturer,
			Protocol,
			ProtocolRevision,
			DeviceTypeCode,
			DeviceTypeName,
			DeviceRevisionCode,
			SerialNumber,
			SetCount,
			EventIdDay,
			EventIdFraction,
			AlertState,
			AckState
		from CheckEnabledTable
		WHERE (PlantServerName = @sPsName) and (Enabled = 'True')
		ORDER BY PlantServerName, AlertTime desc;
	end
	else
	begin	-- without plantServer filter
		WITH CheckEnabledTable AS
		(
			SELECT ebt.ExtBlockTag as AmsTag,
				isnull(hier.Area,'')
				+ '\' + isnull(hier.Unit, '') 
				+ '\' + isnull(hier.Equipment, '')
				+ '\' + isnull(hier.Control, '') as HierarchyLocation,
				convert(nvarchar(30), als.AlertTime, 126) + 'Z' as AlertTime,
				cast(dml.MonitorGroup as nvarchar(10)) as MonitorGroup,
				als.AlertId as AlertId,
				alt.Uid as AlertTypeUid,
				alt.AlertTypeName as AlertTypeName,
				isnull(el.Description, '') as EventDescription,
				isnull(ps.PlantServerId, '') as PlantServerName,
				isnull(mpr.MfrId, '') as MfrId,
				isnull(mfr.Name, '') as Manufacturer,
				isnull(pr.Name, '') as Protocol,
				isnull(affd.Enabled, 'True') as Enabled,
				cast(dev.ProtocolRevision as nvarchar(10)) as ProtocolRevision,
				isnull(dt.DeviceType, '') as DeviceTypeCode,
				isnull(dt.Name, '') as DeviceTypeName,
				isnull(dr.DeviceRevision, '') as DeviceRevisionCode,
				isnull(dev.Identifier, '') as SerialNumber,
				isnull(als.SetCount, '') as SetCount,
				cast(als.EventIdDay as nvarchar(10)) as EventIdDay,
				cast(als.EventIdFraction as nvarchar(10)) as EventIdFraction,
				cast(als.AlertState as nvarchar(10)) as AlertState,
				cast(als.AckState as nvarchar(10)) as AckState
			from extblocktags as ebt with (nolock)
			inner join blockasgms as ba with (nolock)
					on (ebt.ExtBlockTagKey = ba.ExtBlockTagKey) and (ba.EventIdDayOut = 49710)
			inner join amsvw_blocklocation as hier with (nolock)
					on hier.TableKey = ba.BlockKey
			inner join alertlist as als with (nolock)
					on als.BlockKey = ba.BlockKey
			inner join devicemonitorlist as dml with (nolock)
					on dml.BlockKey = als.BlockKey
			inner join alertLog as al with (nolock)
					on al.eventIdDay = als.eventIdDay
						and al.eventIdFraction = als.eventIdFraction
			inner join alerttypes as alt with (nolock)
					on alt.AlertTypeId = al.AlertTypeId
			inner join eventlog as el with (nolock)
					on als.eventIdDay = el.eventIdDay
						and als.eventIdFraction = el.eventIdFraction
			inner join devicelocation as dl with (nolock)
					on dl.BlockKey = als.BlockKey
			inner join networkinfo as net with (nolock)
					on net.NetworkInfoKey = dl.NetworkInfoKey
			inner join plantserver as ps with (nolock)
					on ps.PlantServerKey = net.PlantServerKey
			inner join blocks as blk with (nolock)
					on blk.BlockKey = als.BlockKey
			inner join devices as dev with (nolock)
					on dev.DeviceKey = blk.DeviceKey
			inner join devicerevisions as dr with (nolock)
					on dr.AmsDevRevId = dev.AmsDevRevId
			inner join devicetypes as dt with (nolock)
					on dt.AmsDevTypeId = dr.AmsDevTypeId
			inner join mfrprotocols as mpr with (nolock)
					on mpr.MfrProtocolId = dt.MfrProtocolId
			inner join manufacturers as mfr with (nolock)
					on mfr.AmsMfrNameId = mpr.AmsMfrNameId
			inner join deviceprotocols as pr with (nolock)
					on pr.protocolId = mpr.protocolId
			left outer join devicealertdesc as dad with (nolock)
					on dad.AmsDevRevId = dev.AmsDevRevId and dad.AlertId = als.AlertId
			left outer join alertfilterfordevice as affd with (nolock)
					on affd.BlockKey = als.BlockKey and affd.AlertDescId = dad.AlertDescId
		)
		SELECT AmsTag,
			HierarchyLocation,
			AlertTime,
			MonitorGroup,
			AlertId,
			AlertTypeUid,
			AlertTypeName,
			EventDescription,
			PlantServerName,
			MfrId,
			Manufacturer,
			Protocol,
			ProtocolRevision,
			DeviceTypeCode,
			DeviceTypeName,
			DeviceRevisionCode,
			SerialNumber,
			SetCount,
			EventIdDay,
			EventIdFraction,
			AlertState,
			AckState
		from CheckEnabledTable
		WHERE (Enabled = 'True')
		ORDER BY PlantServerName, AlertTime desc;
	end
end
else
begin
	-- go ahead and return a empty resultset.
	select * from PlantServer with (nolock) where PlantServerKey = -99
end

return @nReturn

GO

