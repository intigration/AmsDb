


-----------------------------------------------------------------------
-- AmsSp_GetAmsTagProperties_2
--
-- Get AmsTag properties including FF block info.
-- This Sp is a updated version of AmsSp_GetAmsTagProperties_1
-- Note: A AmsTag can refer to a 'placeholder' for a device or the
--	AmsTag can refer to a 'template' name.  If the AmsTag is a
--	template type then pointInTime is disregarded.
--
-- Note: If tag is a placeholder and is not assigned to a device for
--	the specified point-in-time then a empty recordset is returned
--	along with a return value of 1.
--
-- Inputs -
--	AmsTag
--	pointInTime - datetime, in GMT, of tag properties.
--
-- Outputs -
--	Recordset containing AmsTag property / value pair.
--
-- Returns -
--	returns 0 if ok.
--	1 if tag is not assigned to a device at this time.
--	-1 - Error, unable to get information.
--
-- Ying Xu, 09/22/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE  PROCEDURE AmsSp_GetAmsTagProperties_2
@sAmsTag as nvarchar(255),
@dtGmtTime as datetime
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

-- create the temp properties table
create table #Props
(
	Property	nvarchar(256)	not null,
	Value		nvarchar(4000)
)

-- declare the properties cursor
-- a massive select-union-select statement which will get tag as either
-- a 'placeholder' or a 'template'
declare PropsCursor CURSOR
FORWARD_ONLY STATIC FOR
SELECT DISTINCT 
    Manufacturers.Name AS Manufacturer, 
    DeviceProtocols.Name AS Protocol, MfrProtocols.MfrId, 
    DeviceTypes.DeviceType AS DeviceTypeCode, 
    DeviceTypes.Name AS DeviceTypeName, 
    DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    DeviceRevisions.Name AS DeviceRevisionName, 
    'na' AS SerialNumber, 
    NamedConfigs.ConfigName AS AmsTag, 'na' AS AmsDeviceId, 
    'na' AS Disposition, 
    MajorDeviceCategories.Name AS MajorCategory, 
    MinorDeviceCategories.Name AS MinorCategory, 
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then '0'
	    else NamedConfigs.UniversalId
	end,
    'template' as TagType,
    'na' as PlantServerId
FROM Manufacturers INNER JOIN
    MfrProtocols ON 
    Manufacturers.AmsMfrNameId = MfrProtocols.AmsMfrNameId INNER
     JOIN
    DeviceProtocols ON 
    MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId INNER JOIN
    DeviceTypes ON 
    MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId INNER JOIN
    DeviceRevisions ON 
    DeviceTypes.AmsDevTypeId = DeviceRevisions.AmsDevTypeId
     INNER JOIN
    NamedConfigs ON 
    DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId INNER
     JOIN
    DeviceCategories ON 
    DeviceRevisions.DeviceCategoryId = DeviceCategories.DeviceCategoryId
     INNER JOIN
    MajorDeviceCategories ON 
    DeviceCategories.MajorDeviceCategoryId = MajorDeviceCategories.MajorDeviceCategoryId
     INNER JOIN
    MinorDeviceCategories ON 
    DeviceCategories.MinorDeviceCategoryId = MinorDeviceCategories.MinorDeviceCategoryId
where (NamedConfigs.ConfigName = @sAmsTag)
union
SELECT DISTINCT 
    dbo.Manufacturers.Name AS Manufacturer, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
    dbo.Devices.AmsDeviceId, 
    dbo.Dispositions.Name AS Disposition, 
    dbo.MajorDeviceCategories.Name AS MajorCategory, 
    dbo.MinorDeviceCategories.Name AS MinorCategory, 
    dbo.Devices.ProtocolRevision AS ProtocolRevision, 
    'placeholder' AS TagType,
    dbo.PlantServer.PlantServerId as PlantServerId
FROM dbo.PlantServer INNER JOIN
    dbo.DeviceLocation ON 
    dbo.PlantServer.PlantServerKey = dbo.DeviceLocation.PlantServerKey
     RIGHT OUTER JOIN
    dbo.Manufacturers INNER JOIN
    dbo.MfrProtocols ON 
    dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId
     INNER JOIN
    dbo.DeviceProtocols ON 
    dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER
     JOIN
    dbo.DeviceTypes ON 
    dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId
     INNER JOIN
    dbo.DeviceRevisions ON 
    dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId
     INNER JOIN
    dbo.DeviceCategories ON 
    dbo.DeviceRevisions.DeviceCategoryId = dbo.DeviceCategories.DeviceCategoryId
     INNER JOIN
    dbo.MajorDeviceCategories ON 
    dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId
     INNER JOIN
    dbo.MinorDeviceCategories ON 
    dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId
     INNER JOIN
    dbo.Devices ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
     INNER JOIN
    dbo.Dispositions ON 
    dbo.Devices.DispositionId = dbo.Dispositions.DispositionId INNER
     JOIN
    dbo.Blocks ON 
    dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
    dbo.BlockAsgms ON 
    dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
    dbo.ExtBlockTags ON 
    dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
     INNER JOIN
    dbo.EventLog ON 
    dbo.BlockAsgms.EventIdDayOut = dbo.EventLog.EventIdDay AND
     dbo.BlockAsgms.EventIdFractionOut = dbo.EventLog.EventIdFraction
     INNER JOIN
    dbo.EventLog EventLog1 ON 
    dbo.BlockAsgms.EventIdDayIn = EventLog1.EventIdDay AND 
    dbo.BlockAsgms.EventIdFractionIn = EventLog1.EventIdFraction
     ON dbo.DeviceLocation.BlockKey = dbo.Blocks.BlockKey
WHERE (eventlog.eventtime >= @dtGmtTime AND 
    eventlog1.eventtime <= @dtGmtTime) and
    (ExtBlockTags.ExtBlockTag = @sAmsTag)
-- end of properties cursor declaration.

open PropsCursor

declare @sMfr as nvarchar(256)
declare @sProt as nvarchar(256)
declare @sDevTypeName as nvarchar(256)
declare @sDevTypeCode as nvarchar(256)
declare @sDevRevName as nvarchar(256)
declare @sDevRevCode as nvarchar(256)
declare @sSerial as nvarchar(256)
declare @sProtRev as nvarchar(256)
declare @sAmsTagProp as nvarchar(256)
declare @sAmsDeviceId as nvarchar(256)
declare @sDisp as nvarchar(256)
declare @sMajCat as nvarchar(256)
declare @sMinCat as nvarchar(256)
declare @sMfrId as nvarchar(256)
declare @sTagType as nvarchar(256)
declare @sPlantServerId as nvarchar(256)

Fetch Next from PropsCursor into @sMfr, @sProt, @sMfrId, @sDevTypeCode, @sDevTypeName, @sDevRevCode, @sDevRevName, @sSerial, @sAmsTag, @sAmsDeviceId, @sDisp, @sMajCat, @sMinCat, @sProtRev, @sTagType, @sPlantServerId

if (@@fetch_status = 0)
begin
	-- for each column in result set add a property/value pair row to the temporary table.
	declare @ordinalPosition as int
	declare @sColumnName as nvarchar(256), @sColumnValue as nvarchar(4000)
	select @ordinalPosition = 0
	while (@ordinalPosition < 16)
	begin
		if (@ordinalPosition = 0)
		begin
		select @sColumnName = 'Manufacturer'
		select @sColumnValue = @sMfr
		end
		else if (@ordinalPosition = 1)
		begin
		select @sColumnName = 'Protocol'
		select @sColumnValue = @sProt
		end
		else if (@ordinalPosition = 2)
		begin
		select @sColumnName = 'MfrId'
		select @sColumnValue = @sMfrId
		end
		else if (@ordinalPosition = 3)
		begin
		select @sColumnName = 'DeviceTypeCode'
		select @sColumnValue = @sDevTypeCode
		end
		else if (@ordinalPosition = 4)
		begin
		select @sColumnName = 'DeviceTypeName'
		select @sColumnValue = @sDevTypeName
		end
		else if (@ordinalPosition = 5)
		begin
		select @sColumnName = 'DeviceRevisionCode'
		select @sColumnValue = @sDevRevCode
		end
		else if (@ordinalPosition = 6)
		begin
		select @sColumnName = 'DeviceRevisionName'
		select @sColumnValue = @sDevRevName
		end
		else if (@ordinalPosition = 7)
		begin
		select @sColumnName = 'SerialNumber'
		select @sColumnValue = @sSerial
		end
		else if (@ordinalPosition = 8)
		begin
		select @sColumnName = 'AmsTag'
		select @sColumnValue = @sAmsTag
		end
		else if (@ordinalPosition = 9)
		begin
		select @sColumnName = 'AmsDeviceId'
		select @sColumnValue = @sAmsDeviceId
		end
		else if (@ordinalPosition = 10)
		begin
		select @sColumnName = 'Disposition'
		select @sColumnValue = @sDisp
		end
		else if (@ordinalPosition = 11)
		begin
		select @sColumnName = 'MajorCategory'
		select @sColumnValue = @sMajCat
		end
		else if (@ordinalPosition = 12)
		begin
		select @sColumnName = 'MinorCategory'
		select @sColumnValue = @sMinCat
		end
		else if (@ordinalPosition = 13)
		begin
		select @sColumnName = 'ProtocolRevision'
		select @sColumnValue = @sProtRev
		end
		else if (@ordinalPosition = 14)
		begin
		select @sColumnName = 'TagType'
		select @sColumnValue = @sTagType
		end
		else if (@ordinalPosition = 15)
		begin
		select @sColumnName = 'PlantServerId'
		select @sColumnValue = @sPlantServerId
		end
		else
		begin
		select @sColumnName = 'Property'
		select @sColumnValue = 'NotFound'
		end

		insert #Props values (@sColumnName, @sColumnValue)
		select @ordinalPosition = @ordinalPosition + 1
	end

	-- get the location information.
	select @sColumnName = 'LocationMoniker'
	select @sColumnValue = ''
	if (@sDisp = 'Assigned')
	begin
		declare @sLoc nvarchar(512)
		declare @sArea nvarchar(256)
		declare @sUnit nvarchar(256)
		declare @sEquip nvarchar(256)
		declare @sControl nvarchar(256)
		select @sLoc = ''

		-- from the location view select the location information
		-- using the AmsTag property.
		select @sArea = Area,
		   @sUnit = Unit,
      		   @sEquip = Equipment,
		   @sControl = Control
		from AmsVw_BlockTagLocation
		where (ExtBlockTag = @sAmsTag)
    
		select @sLoc = @sArea
		select @sLoc = @sLoc + '|'
		select @sLoc = @sLoc + @sUnit
		select @sLoc = @sLoc + '|'
		select @sLoc = @sLoc + @sEquip
		select @sLoc = @sLoc + '|'
		select @sLoc = @sLoc + @sControl

		select @sColumnValue = @sLoc
	end
	insert #Props values (@sColumnName, @sColumnValue)

	-- add the pointInTime to the property list.
	select @sColumnName = 'PointInTime'
	select @sColumnValue = @dtGmtTime
	if (@sTagType = 'template') select @sColumnValue = 'na'	-- not applicable if template type
	insert #Props values (@sColumnName, @sColumnValue)

	-- add BlockInfoAsXml to the property list
	declare @sBlockInfo as nvarchar(4000)
	exec @iReturnVal =AmsSp_GetDeviceBlockInfo_1 @sMfr, @sProt, @sDevTypeName, @sDevRevName, @sSerial, @sBlockInfo OUTPUT
	if (@iReturnVal <> 0) 
	begin
		return -1
	end
	else
	begin
		select @sColumnName = 'BlockInfoAsXml'
		select @sColumnValue = @sBlockInfo
		insert #Props values (@sColumnName, @sColumnValue)
	end
	
	
	-- indicate that tag is assigned whether a template or placeholder.
	select @sColumnName = 'Assigned'
	select @sColumnValue = '1'
	insert #Props values (@sColumnName, @sColumnValue)
end
else
begin
	-- we do not have a device associated to this tag at this time.

	-- indicate that tag is not assigned.
	select @sColumnName = 'Assigned'
	select @sColumnValue = '0'
	insert #Props values (@sColumnName, @sColumnValue)

	select @iReturnVal = 1
end

-- send recordset to client
select * from #Props

-- cleanup cursor
close PropsCursor
deallocate PropsCursor

-- cleanup the temporary table.
drop table #Props

return @iReturnVal

GO

