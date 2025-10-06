
-------------------------------------------------------------------------------
-- AmsVw_DevTagAsgms_1
--
-- Get BlockAsgms information except we are using EventTime instead of
--	EventIdDay's and fraction's and getting device identification
--	information (ie. Manufacturer, Protocol, DeviceType, etc.)
--
-- REMEMBER-- all times are GMT.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Manufacturer
--	Protocol
--	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--	AmsTag
--	TimeIn
--	TimeOut
--
-- Author --
--	Joe Fisher
--	06/28/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_DevTagAsgms_1
AS
SELECT dbo.Manufacturers.Name AS Manufacturer, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.Devices.ProtocolRevision, 
    dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
    EventLog1.EventTime AS TimeIn, 
    dbo.EventLog.EventTime AS TimeOut
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
     LEFT OUTER JOIN
    dbo.EventLog EventLog1 ON 
    dbo.BlockAsgms.EventIdDayIn = EventLog1.EventIdDay AND 
    dbo.BlockAsgms.EventIdFractionIn = EventLog1.EventIdFraction
     LEFT OUTER JOIN
    dbo.EventLog ON 
    dbo.BlockAsgms.EventIdDayOut = dbo.EventLog.EventIdDay AND
     dbo.BlockAsgms.EventIdFractionOut = dbo.EventLog.EventIdFraction

GO

