
-------------------------------------------------------------------------------
-- AmsVw_BlockChangeEvents
--
-- Get device/block information along with configuration change events.
--
-- Note: configuration change events are determined by linking the BlockData.
-- eventId's with the EventLog.eventId's.
--
-- Note: The AmsTag is the tag currently assigned to the device.
--
-- Note: USER BEWARE - linking up to the EventLog in the manner that this view
-- is doing could cause lengthy query times if a filter is not applied.  To reduce
-- the retrieval time use something like WHERE AmsTag = 'PT-101' or something
-- similar.
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
--	EventTime
--
-- Author --
--	Joe Fisher
--	08/08/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_BlockChangeEvents
AS
SELECT DISTINCT dbo.AmsVw_BlockTags.AmsTag, 
    dbo.AmsVw_BlockTags.Manufacturer, 
    dbo.AmsVw_BlockTags.Protocol, dbo.AmsVw_BlockTags.MfrId, 
    dbo.AmsVw_BlockTags.DeviceTypeCode, 
    dbo.AmsVw_BlockTags.DeviceTypeName, 
    dbo.AmsVw_BlockTags.DeviceRevisionCode, 
    dbo.AmsVw_BlockTags.DeviceRevisionName, 
    dbo.AmsVw_BlockTags.SerialNumber, 
    dbo.AmsVw_BlockTags.ProtocolRevision, 
    dbo.AmsVw_BlockTags.BlockIndex, 
    dbo.AmsVw_BlockTags.BlockKey, 
    dbo.EventLog.EventTime
FROM dbo.AmsVw_BlockTags INNER JOIN
    dbo.BlockData ON 
    dbo.AmsVw_BlockTags.BlockKey = dbo.BlockData.BlockKey INNER
     JOIN
    dbo.EventLog ON 
    dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND 
    dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction

GO

