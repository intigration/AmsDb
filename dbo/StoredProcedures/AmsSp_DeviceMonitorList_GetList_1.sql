
-----------------------------------------------------------------------
-- AmsSp_DeviceMonitorList_GetList_1
--
--	Get the device polling list (i.e. DeviceMonitorList)
--
--  Note: this outputs Frequency in minutes.
--
-- Inputs --
--  @sAmsTag - Ams tag name - if not empty ignore @sPsName (input parameter) 
--	@sPsName - plant server name - empty string returns all of them
--
-- Outputs --
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 11/26/2007
-- Nghy Hong	07/15/2008	Added one more input parameter (@sAmsTag)
CREATE PROCEDURE [dbo].[AmsSp_DeviceMonitorList_GetList_1]
@sPsName nvarchar(255), 
@sAmsTag nvarchar(255)
AS

set nocount on
declare @nReturn int
set @nReturn = 0

BEGIN TRY
	set @sPsName = (ltrim(rtrim(@sPsName)))
	set @sAmsTag = (ltrim(rtrim(@sAmsTag)))

	-- Using table variable for the benefit of no over-head and manual cleanup.
	declare @TmpTableVar table(
	AmsTag nvarchar(255),
	HierarchyLocation nvarchar(255),
	MonitorGroup tinyint,
	Frequency int,
	DVMEnabled nvarchar(2),
	PlantServerName nvarchar(255),
	MfrId nvarchar(255),
	Manufacturer nvarchar(255),
	Protocol nvarchar(255),
	ProtocolRevision nvarchar(10),
	DeviceTypeCode nvarchar(255),
	DeviceRevisionCode nvarchar(255),
	SerialNumber nvarchar(255),
	DeviceTypeName nvarchar(255),
	PlantServerId  nvarchar(255)
	)

	-- Fetch the data to our table variable
	Insert into @TmpTableVar(
	AmsTag,
	HierarchyLocation,
	MonitorGroup,
	Frequency,
	DVMEnabled,
	PlantServerName,
	MfrId,
	Manufacturer,
	Protocol,
	ProtocolRevision,
	DeviceTypeCode,
	DeviceRevisionCode,
	SerialNumber,
	DeviceTypeName,
	PlantServerId
	)
	SELECT AmsVw_AlertMonitorStartup.AmsTag,
	isnull(AmsVw_AlertMonitorStartup.Area, '') + '\' + 
	isnull(AmsVw_AlertMonitorStartup.Unit, '') + '\' + 
	isnull(AmsVw_AlertMonitorStartup.Equipment, '') + '\' + 
	isnull(AmsVw_AlertMonitorStartup.Control, '') as HierarchyLocation,
	cast(AmsVw_AlertMonitorStartup.MonitorGroup as nvarchar(10)) as MonitorGroup,
	cast(AmsVw_AlertMonitorStartup.Frequency/60000 as nvarchar(10)) as Frequency,
	case AmsVw_AlertMonitorStartup.DVMEnabled when 0 then '0' else '1' end as DVMEnabled,
	isnull(PlantServer.PlantServerId, '') as PlantServerName,
	isnull(AmsVw_AlertMonitorStartup.MfrId, '') as MfrId,
	isnull(AmsVw_AlertMonitorStartup.Manufacturer, '') as Manufacturer,
	isnull(AmsVw_AlertMonitorStartup.Protocol, '') as Protocol,
	cast(AmsVw_AlertMonitorStartup.ProtocolRev as nvarchar(10)) as ProtocolRevision,
	isnull(AmsVw_AlertMonitorStartup.DeviceTypeCode, '') as DeviceTypeCode,
	isnull(AmsVw_AlertMonitorStartup.DeviceRevisionCode, '') as DeviceRevisionCode,
	isnull(AmsVw_AlertMonitorStartup.SerialNumber, '') as SerialNumber,
	isnull(AmsVw_AlertMonitorStartup.DeviceTypeName, '') as DeviceTypeName,
	PlantServer.PlantServerId
	FROM AmsVw_AlertMonitorStartup with (nolock) 
	INNER JOIN PlantServer with (nolock) ON AmsVw_AlertMonitorStartup.PlantServerKey = PlantServer.PlantServerKey
	order by PlantServer.PlantServerId, AmsVw_AlertMonitorStartup.AmsTag

	-- Output the result based on the input parameters
	if (Len(@sAmsTag) > 0)
	begin
		-- For the AMS Tag provided
		SELECT AmsTag, HierarchyLocation, MonitorGroup, Frequency, DVMEnabled, PlantServerName, MfrId, 
		Manufacturer, Protocol, ProtocolRevision, DeviceTypeCode, DeviceRevisionCode, SerialNumber, DeviceTypeName
		from @TmpTableVar
		WHERE AmsTag = @sAmsTag
	end
	else if (Len(@sPsName) > 0)
	begin
		-- For the Plant server provided
		SELECT AmsTag, HierarchyLocation, MonitorGroup, Frequency, DVMEnabled, PlantServerName, MfrId, 
		Manufacturer, Protocol, ProtocolRevision, DeviceTypeCode, DeviceRevisionCode, SerialNumber, DeviceTypeName
		from @TmpTableVar
		WHERE PlantServerId = @sPsName
	end
	else
	begin
		-- All devices in the monitor list
		SELECT AmsTag, HierarchyLocation, MonitorGroup, Frequency, DVMEnabled, PlantServerName, MfrId, 
		Manufacturer, Protocol, ProtocolRevision, DeviceTypeCode, DeviceRevisionCode, SerialNumber, DeviceTypeName
		from @TmpTableVar
	end
END TRY
BEGIN CATCH
	set @nReturn = -1
END CATCH

return @nReturn

GO

