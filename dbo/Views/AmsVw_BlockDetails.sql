
-------------------------------------------------------------------------------
-- AmsVw_BlockDetails
--
-- Get detailed device and block information.
--
-- Inputs --
--	none.
--
-- Outputs --
--	ExtBlockTag
--	ManufacturerName
--	DeviceProtocolName
--	MfrId
--	DeviceType
--	DeviceTypeName
--	DeviceRevision
--	DeviceRevisionName
--	Identifier
--	ProtocolRevision
--	BlockIndex
--	BlockKey
--	AmsMfrNameId
--	ManufacturerDescription
--	ProtocolId
--	DeviceProtocolDescription
--	MfrProtocolId
--	AmsDevTypeId
--	DeviceTypeDescription
--	AmsDevRevId
--	DeviceRevisionDescription
--	DeviceKey
--	AmsDeviceTag
--	AmsDeviceId
--	BlockType
--	DeviceCategoryId
--	DispositionId
--	EventIdDayOut
--	EventIdFractionOut
--	EventIdDayIn
--	EventIdFractionIn
--
-- Author --
--	Todd Lindsey
--	07/22/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_BlockDetails
AS
SELECT
	dbo.ExtBlockTags.ExtBlockTag, 
	dbo.Manufacturers.Name AS ManufacturerName, 
	dbo.DeviceProtocols.Name AS DeviceProtocolName, 
	dbo.MfrProtocols.MfrId, 
	dbo.DeviceTypes.DeviceType, 
	dbo.DeviceTypes.Name AS DeviceTypeName, 
	dbo.DeviceRevisions.DeviceRevision, 
	dbo.DeviceRevisions.Name AS DeviceRevisionName, 
	dbo.Devices.Identifier, 
	dbo.Devices.ProtocolRevision, 
	dbo.Blocks.BlockIndex, 
    dbo.Blocks.BlockKey, 
    dbo.Manufacturers.AmsMfrNameId, 
    dbo.Manufacturers.Description AS ManufacturerDescription, 
    dbo.DeviceProtocols.ProtocolId, 
	dbo.DeviceProtocols.Description AS DeviceProtocolDescription, 
	dbo.MfrProtocols.MfrProtocolId, 
	dbo.DeviceTypes.AmsDevTypeId, 
	dbo.DeviceTypes.Description AS DeviceTypeDescription, 
	dbo.DeviceRevisions.AmsDevRevId, 
	dbo.DeviceRevisions.Description AS DeviceRevisionDescription, 
	dbo.Devices.DeviceKey, 
	dbo.Devices.AmsDeviceTag, 
	dbo.Devices.AmsDeviceId, 
	dbo.Blocks.BlockType, 
	dbo.DeviceRevisions.DeviceCategoryId, 
	dbo.Devices.DispositionId, 
	dbo.BlockAsgms.EventIdDayOut, 
	dbo.BlockAsgms.EventIdFractionOut, 
	dbo.BlockAsgms.EventIdDayIn, 
	dbo.BlockAsgms.EventIdFractionIn
FROM 
	dbo.ExtBlockTags
	INNER JOIN dbo.BlockAsgms ON
		dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
	INNER JOIN dbo.AmsVw_DeviceLevelBlockKey ON
		dbo.AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey = dbo.BlockAsgms.BlockKey
	INNER JOIN dbo.Blocks ON 
		dbo.Blocks.BlockKey = dbo.AmsVw_DeviceLevelBlockKey.BlockKey
	INNER JOIN dbo.Devices ON 
		dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey
	INNER JOIN dbo.DeviceRevisions ON 
		dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
	INNER JOIN dbo.DeviceTypes ON 
		dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId 
    INNER JOIN dbo.MfrProtocols ON 
		dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId 
    INNER JOIN dbo.Manufacturers ON
		dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId
	INNER JOIN dbo.DeviceProtocols ON 
		dbo.DeviceProtocols.ProtocolId = dbo.MfrProtocols.ProtocolId

GO

