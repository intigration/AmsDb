
-------------------------------------------------------------------------------
-- AmsVw_DeviceTags
--
-- Get device information currently assigned to the tag.
-- Note: for real devices only.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag
--	Manufacturer
--	Protocol
--  	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_DeviceTags
AS
SELECT ExtBlockTags.ExtBlockTag AS AmsTag, 
    Manufacturers.Name AS Manufacturer, 
    DeviceProtocols.Name AS Protocol, MfrProtocols.MfrId, 
    DeviceTypes.DeviceType as DeviceTypeCode, 
    DeviceTypes.Name AS DeviceTypeName, 
    DeviceRevisions.DeviceRevision as DeviceRevisionCode, 
    DeviceRevisions.Name AS DeviceRevisionName, 
    Devices.Identifier AS SerialNumber, 
    Devices.ProtocolRevision
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
    Devices ON 
    DeviceRevisions.AmsDevRevId = Devices.AmsDevRevId INNER
     JOIN
    Blocks ON 
    Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
    BlockAsgms ON 
    Blocks.BlockKey = BlockAsgms.BlockKey INNER JOIN
    ExtBlockTags ON 
    BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
WHERE (BlockAsgms.EventIdDayOut = 49710)

GO

