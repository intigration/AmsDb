
-------------------------------------------------------------------------------
-- AmsVw_BlockTags
--
-- Get device and block information currently assigned to the tag.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag
--	Manufacturer
--	Protocol
-- 	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--	BlockIndex
--	BlockKey
--
-- Author --
--	Joe Fisher
--	08/08/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_BlockTags
AS
SELECT dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
    dbo.Manufacturers.Name AS Manufacturer, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.MfrProtocols.MfrId,
    dbo.DeviceTypes.DeviceType as DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision as DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.Devices.ProtocolRevision, dbo.Blocks.BlockIndex, 
    dbo.Blocks.BlockKey
FROM dbo.Manufacturers INNER JOIN
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
    dbo.Devices ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
     INNER JOIN
    dbo.Blocks ON 
    dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
    dbo.BlockAsgms ON 
    dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
    dbo.ExtBlockTags ON 
    dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

