
-------------------------------------------------------------------------------
-- AmsVw_DeviceTagLocation
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
--	SerialNumber
--	ProtocolRevision
--	AmsDeviceId
--	BlockKey
--	BlockIndex
--	DispositionId
--	DeviceDisposition
--	Area
--  	Unit
--	Equipment
--	Control
--	AmsTag
--	PlantServerId	(ie. plant server machine name.)
--	PlantServerKey
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_DeviceTagLocation
AS
SELECT Manufacturers.Name AS Manufacturer, MfrProtocols.MfrId, 
    DeviceProtocols.ProtocolId,
    DeviceProtocols.Name AS Protocol, 
    DeviceTypes.DeviceType AS DeviceTypeCode, 
    DeviceTypes.Name AS DeviceTypeName, 
    DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    DeviceRevisions.Name AS DeviceRevisionName, 
    Devices.Identifier AS SerialNumber, Devices.ProtocolRevision, 
    Devices.AmsDeviceId,
    Blocks.BlockKey,
    Blocks.BlockIndex, 
    Dispositions.DispositionId,
    Dispositions.Name AS DeviceDisposition, 
    AmsVw_BlockLocation.Area, AmsVw_BlockLocation.Unit, 
    AmsVw_BlockLocation.Equipment, 
    AmsVw_BlockLocation.Control, 
    ExtBlockTags.ExtBlockTag AS AmsTag, 
    PlantServer.PlantServerId, PlantServer.PlantServerKey
FROM dbo.PlantServer INNER JOIN
    dbo.DeviceLocation ON 
    dbo.PlantServer.PlantServerKey = dbo.DeviceLocation.PlantServerKey
     RIGHT OUTER JOIN
    dbo.DeviceRevisions INNER JOIN
    dbo.Devices ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
     INNER JOIN
    dbo.DeviceTypes ON 
    dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId
     INNER JOIN
    dbo.MfrProtocols ON 
    dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId
     INNER JOIN
    dbo.Manufacturers ON 
    dbo.MfrProtocols.AmsMfrNameId = dbo.Manufacturers.AmsMfrNameId
     INNER JOIN
    dbo.DeviceProtocols ON 
    dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER
     JOIN
    dbo.Blocks ON 
    dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
    dbo.Dispositions ON 
    dbo.Devices.DispositionId = dbo.Dispositions.DispositionId INNER
     JOIN
    dbo.BlockAsgms ON 
    dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
    dbo.ExtBlockTags ON 
    dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
     ON 
    dbo.DeviceLocation.BlockKey = dbo.Blocks.BlockKey LEFT OUTER
     JOIN
    dbo.AmsVw_BlockLocation ON 
    dbo.Blocks.BlockKey = dbo.AmsVw_BlockLocation.TableKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

