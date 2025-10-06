
-----------------------------------------------------------------------
-- AmsSp_DeviceTags_1
--
-- Get device info.
-- Additionally gets the Major and Minor categories and the latest
--	descriptor parameter value.
--
-- Inputs -
-- 	@sSelectClause - select clause
--	@sWhereClause - where clause
--
-- Outputs -
--		(see temporary table column names.)
--
-- Returns -
--	returns 0 if successful.
--	-1 - if error.
--
-- Ying Xu, 8/27/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_DeviceTags_1
@sSelectClause nvarchar(2048),
@sWhereClause nvarchar(2048)
AS
declare @iReturnVal int
set @iReturnVal = 0

create table #AmsSp_DeviceTags_1
(
	AmsTag		nvarchar(40),
	Manufacturer	nvarchar(255),
	Protocol	nvarchar(255),
	MfrId		nvarchar(255),
	DeviceTypeCode	nvarchar(255),
	DeviceTypeName	nvarchar(255),
	DeviceRevisionCode nvarchar(255),
	DeviceRevisionName nvarchar(255),
	SerialNumber	nvarchar(255),
	ProtocolRevision nvarchar(50),
	SisDevice	nvarchar(2),
	MajorCategory	nvarchar(255),
	MinorCategory	nvarchar(255),
	DeviceDescription	nvarchar(255)

)

INSERT #AmsSp_DeviceTags_1
	SELECT	dbo.ExtBlockTags.ExtBlockTag AS AmsTag, dbo.Manufacturers.Name AS Manufacturer, dbo.DeviceProtocols.Name AS Protocol, 
		dbo.MfrProtocols.MfrId, dbo.DeviceTypes.DeviceType AS DeviceTypeCode, dbo.DeviceTypes.Name AS DeviceTypeName, 
		dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, dbo.DeviceRevisions.Name AS DeviceRevisionName, 
		dbo.Devices.Identifier AS SerialNumber, dbo.Devices.ProtocolRevision, dbo.DeviceLocation.SisStatus AS SisDevice, 
		dbo.MajorDeviceCategories.Name, dbo.MinorDeviceCategories.Name,
		dbo.AmsUdf_CurrentDescriptor(dbo.Blocks.BlockKey) AS DeviceDescription
	FROM	dbo.Manufacturers INNER JOIN
		dbo.MfrProtocols ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
		dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
		dbo.DeviceTypes ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
		dbo.DeviceRevisions ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
		dbo.Devices ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
		dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
		dbo.BlockAsgms ON dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
		dbo.ExtBlockTags ON dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey INNER JOIN
		dbo.DeviceCategories ON dbo.DeviceRevisions.DeviceCategoryId = dbo.DeviceCategories.DeviceCategoryId INNER JOIN
		dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
		dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId LEFT OUTER JOIN
		dbo.DeviceLocation ON dbo.Blocks.BlockKey = dbo.DeviceLocation.BlockKey
	WHERE	(dbo.BlockAsgms.EventIdDayOut = 49710)

EXEC (@sSelectClause  +' from #AmsSp_DeviceTags_1 ' +  @sWhereClause)

if (@@ERROR <> 0)
	set @iReturnVal = -1

drop table #AmsSp_DeviceTags_1

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

