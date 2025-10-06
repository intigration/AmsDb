
-----------------------------------------------------------------------
-- AmsSp_DeviceMonitorList_GetCandidates_1
--
--	Get the list of devices that are candidates for the DeviceMonitorList
--
-- Inputs --
--	@sPsName - plant server name
--				Note: if blank then all plant server devices are returned.
--
-- Outputs --
--
-- Recordset output --
--
-- Returns -
--
-- James Kramer 11/26/2007
-- James Kramer 9/30/2008 - AOEP00027934 modified candidates to exclude devices with no plantserver
-- Nghy Hong 11/13/2009 - Add PROFIBUS-DP protocol to the filter
-- Peter Hilpisch 1/19/2012 - Add PROFIBUS-PA
-- Nghy Hong 2/21/2012	- Add NonDD Conventinal protocol to the filter 
--
CREATE PROCEDURE AmsSp_DeviceMonitorList_GetCandidates_1
@sPsName nvarchar(255)
AS

set nocount on

set @sPsName = (ltrim(rtrim(@sPsName)))
declare @sSql nvarchar(max)
set @sSql = ''
set @sSql = @sSql + 'SELECT AmsVw_DeviceTagLocationCategories.AmsTag,' 
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.Area,'''')'
set @sSql = @sSql + ' + ''\'' + isnull(AmsVw_DeviceTagLocationCategories.Unit, '''')' 
set @sSql = @sSql + ' + ''\'' + isnull(AmsVw_DeviceTagLocationCategories.Equipment, '''')'
set @sSql = @sSql + ' + ''\'' + isnull(AmsVw_DeviceTagLocationCategories.Control, '''') as HierarchyLocation,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.PlantServerId, '''') as PlantServerName,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.MfrId, '''') as MfrId,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.Manufacturer, '''') as Manufacturer,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.Protocol, '''') as Protocol,'
set @sSql = @sSql + ' cast(AmsVw_DeviceTagLocationCategories.ProtocolRevision as nvarchar(10)) as ProtocolRevision,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.DeviceTypeCode, '''') as DeviceTypeCode,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.DeviceRevisionCode, '''') as DeviceRevisionCode,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.SerialNumber, '''') as SerialNumber,'
set @sSql = @sSql + ' isnull(AmsVw_DeviceTagLocationCategories.DeviceTypeName, '''') as DeviceTypeName,'
set @sSql = @sSql + ' case DeviceMonitorList.DVMEnabled when 0 then ''0'' else ''1'' end as DVMEnabled,'
set @sSql = @sSql + ' isnull(DeviceMonitorList.MonitorGroup,'''') as MonitorGroup,'
set @sSql = @sSql + ' cast(DeviceMonitorList.Frequency/60000 as nvarchar(10)) as Frequency'
set @sSql = @sSql + ' FROM AmsVw_DeviceTagLocationCategories with (nolock) LEFT OUTER JOIN DeviceMonitorList with (nolock) ON AmsVw_DeviceTagLocationCategories.BlockKey = DeviceMonitorList.BlockKey'
set @sSql = @sSql + ' WHERE (AmsVw_DeviceTagLocationCategories.Protocol = ''HART'' OR AmsVw_DeviceTagLocationCategories.Protocol = ''FF'' '
set @sSql = @sSql + ' OR AmsVw_DeviceTagLocationCategories.Protocol = ''PROFIBUS-DP'' OR AmsVw_DeviceTagLocationCategories.Protocol = ''PROFIBUS-PA'' '
set @sSql = @sSql + ' OR (AmsVw_DeviceTagLocationCategories.Protocol = ''CONVENTIONAL'' and AmsVw_DeviceTagLocationCategories.MinorDeviceCategoryId = 83) )'
set @sSql = @sSql + ' AND (AmsVw_DeviceTagLocationCategories.DispositionId = 1)'
if (@sPsName <> '')
begin
	set @sSql = @sSql + ' AND (AmsVw_DeviceTagLocationCategories.PlantServerId = ''' + @sPsName + ''')'
end
else
begin
	set @sSql = @sSql + ' AND (AmsVw_DeviceTagLocationCategories.PlantServerId <> '''')'
end
--print @sSql
exec (@sSql)

return

GO

