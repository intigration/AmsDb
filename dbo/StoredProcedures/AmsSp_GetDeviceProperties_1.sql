
-----------------------------------------------------------------------
-- AmsSp_GetDeviceProperties_1
--
-- Get device properties.
--
-- Inputs -
--	Manufacturer.
--	Protocol.
--	DeviceTypeName.
--	DeviceRevisionName.
--	SerialNumber.
--
-- Outputs -
--	Recordset containing device property / value pair.
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/27/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDeviceProperties_1
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sSerialNumber as nvarchar(255)
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
declare PropsCursor CURSOR
FORWARD_ONLY STATIC FOR
SELECT dbo.Manufacturers.Name AS Manufacturer, 
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
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then '0'
	    else NamedConfigs.UniversalId
	end,
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
     ON 
    dbo.DeviceLocation.BlockKey = dbo.Blocks.BlockKey LEFT OUTER
     JOIN
    dbo.NamedConfigs ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.NamedConfigs.AmsDevRevId
WHERE (BlockAsgms.EventIdDayOut = 49710) AND 
    (Manufacturers.Name = @sMfrName) AND
    (DeviceProtocols.Name = @sProtocolName) AND
    (DeviceTypes.Name = @sDeviceTypeName) AND
    (DeviceRevisions.Name = @sDeviceRevisionName) AND
    (Devices.Identifier = @sSerialNumber)
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
declare @sAmsTag as nvarchar(256)
declare @sAmsDeviceId as nvarchar(256)
declare @sDisp as nvarchar(256)
declare @sMajCat as nvarchar(256)
declare @sMinCat as nvarchar(256)
declare @sMfrId as nvarchar(256)
declare @sPlantServerId as nvarchar(256)

Fetch Next from PropsCursor into @sMfr, @sProt, @sMfrId, @sDevTypeCode, @sDevTypeName, @sDevRevCode, @sDevRevName, @sSerial, @sAmsTag, @sAmsDeviceId, @sDisp, @sMajCat, @sMinCat, @sProtRev, @sPlantServerId

-- for each column in result set add a property/value pair row to the temporary table.
declare @ordinalPosition as int
declare @sColumnName as nvarchar(256), @sColumnValue as nvarchar(4000)
select @ordinalPosition = 0
while (@ordinalPosition < 15)
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

-- if disposition Assigned then get the location information.
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
	-- using the AmsDeviceId property.
    select @sArea = Area,
	   @sUnit = Unit,
      	   @sEquip = Equipment,
	   @sControl = Control
    from AmsVw_DeviceLocation
    where (AmsDeviceId = @sAmsDeviceId)
    
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

select * from #Props

-- cleanup cursor
close PropsCursor
deallocate PropsCursor

-- cleanup the temporary table.
drop table #Props

return @iReturnVal

GO

