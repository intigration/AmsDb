
-------------------------------------------------------------------------------
-- AmsVw_DeviceLocation
--
-- Present device information along with where it is assigned (if it is.)
-- Note: this does not include future devices- only 'real' devices.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Manufacturer
--	MfrId
--	Protocol
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	AmsDeviceId
--	BlockIndex
--	DeviceDisposition
--	Area
--  Unit
--	Equipment
--	Control
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_DeviceLocation
AS
SELECT dbo.Manufacturers.Name AS Manufacturer, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.Devices.ProtocolRevision, dbo.Devices.AmsDeviceId, 
    dbo.Blocks.BlockIndex, 
    dbo.Dispositions.Name AS DeviceDisposition, 
    dbo.AmsVw_BlockLocation.Area, 
    dbo.AmsVw_BlockLocation.Unit, 
    dbo.AmsVw_BlockLocation.Equipment, 
    dbo.AmsVw_BlockLocation.Control
FROM dbo.DeviceRevisions INNER JOIN
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
    dbo.Devices.DispositionId = dbo.Dispositions.DispositionId LEFT
     OUTER JOIN
    dbo.AmsVw_BlockLocation ON 
    dbo.Blocks.BlockKey = dbo.AmsVw_BlockLocation.TableKey

GO

