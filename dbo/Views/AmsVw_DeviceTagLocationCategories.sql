

-------------------------------------------------------------------------------
-- AmsVw_DeviceTagLocationCategories
--
-- Get device information currently assigned to the tag along with location
--	information and the plant server where this device is connected to.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Manufacturer
--	MfrId
--	ProtocolId
--	Protocol
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--  MajorCategory
--  MinorCategory
--	SerialNumber
--	ProtocolRevision
--	AmsDeviceId
--	BlockKey
--	BlockIndex
--	DispositionId
--	DeviceDisposition
--	Area
--  Unit
--	Equipment
--	Control
--	AmsTag
--	PlantServerId	(ie. plant server machine name.)
--	PlantServerKey
--
-- Author --
--	Nghy Hong
--	02/21/2012
--
--
CREATE VIEW dbo.AmsVw_DeviceTagLocationCategories
AS
SELECT dbo.Manufacturers.Name AS Manufacturer, 
	dbo.MfrProtocols.MfrId, 
	dbo.DeviceProtocols.ProtocolId, 
	dbo.DeviceProtocols.Name AS Protocol, 
	dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
	dbo.DeviceTypes.Name AS DeviceTypeName, 
	dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.MajorDeviceCategories.Name AS MajorCategory, 
    dbo.MajorDeviceCategories.MajorDeviceCategoryId, 
    dbo.MinorDeviceCategories.Name AS MinorCategory, 
    dbo.MinorDeviceCategories.MinorDeviceCategoryId, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.Devices.ProtocolRevision, 
    dbo.Devices.AmsDeviceId, 
    dbo.Blocks.BlockKey, 
    dbo.Blocks.BlockIndex, 
    dbo.Dispositions.DispositionId, 
    dbo.Dispositions.Name AS DeviceDisposition, 
    dbo.AmsVw_BlockLocation.Area, 
    dbo.AmsVw_BlockLocation.Unit, 
    dbo.AmsVw_BlockLocation.Equipment, 
    dbo.AmsVw_BlockLocation.Control, 
    dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
    dbo.PlantServer.PlantServerId, 
    dbo.PlantServer.PlantServerKey
FROM dbo.DeviceCategories INNER JOIN
   dbo.DeviceRevisions INNER JOIN
   dbo.Devices ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
   dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
   dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
   dbo.Manufacturers ON dbo.MfrProtocols.AmsMfrNameId = dbo.Manufacturers.AmsMfrNameId INNER JOIN
   dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
   dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
   dbo.Dispositions ON dbo.Devices.DispositionId = dbo.Dispositions.DispositionId INNER JOIN
   dbo.BlockAsgms ON dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
   dbo.ExtBlockTags ON dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey ON 
   dbo.DeviceCategories.DeviceCategoryId = dbo.DeviceRevisions.DeviceCategoryId INNER JOIN
   dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
   dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId LEFT OUTER JOIN
   dbo.PlantServer INNER JOIN
   dbo.DeviceLocation ON dbo.PlantServer.PlantServerKey = dbo.DeviceLocation.PlantServerKey ON 
   dbo.Blocks.BlockKey = dbo.DeviceLocation.BlockKey LEFT OUTER JOIN
   dbo.AmsVw_BlockLocation ON dbo.Blocks.BlockKey = dbo.AmsVw_BlockLocation.TableKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

