
-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByAmsTag_1
--
-- Get device type info by current AmsTag.
--
-- Inputs -
--	@sAmsTag	nvarchar(256)
--
-- Outputs -
--	ManufacturerName
--	ProtocolName
--	MfrId
--	DeviceTypeName
--	DeviceTypeCode
--	DeviceRevisionName
--	DeviceRevisionCode
--  	SerialNumber
--	AlarmBlockIndex
-- Returns -
--	returns the number of rows in the resultset.
--      -1 - device type info not found.
--	-2 - general error.
--	-3 - error on getting AlarmBlockIndex
-- Joe Fisher, 08/13/2003
-- Nghy Hong   07/19/2006  //Also get alarm block index for FF devices (AOEP00019771)
--
CREATE  PROCEDURE AmsSp_GetDevTypeInfoByAmsTag_1
@sAmsTag	nvarchar(256),
@sOutManufacturer		nvarchar(255) output,
@sOutProtocolName		nvarchar(255) output,
@nOutMfrId			int output,
@sOutDeviceTypeName	nvarchar(255) output,
@nOutDeviceTypeCode	int output,
@sOutDeviceRevisionName nvarchar(255) output,
@nOutDeviceRevisionCode int output,
@sOutSerialNumber nvarchar(255) output,
@nOutAlarmBlockIndex int output 
AS
DECLARE @sErrorMsg nvarchar(256)
DECLARE @iReturnVal int
set @iReturnVal = 0

set nocount on

set @nOutAlarmBlockIndex = -999
declare @iAmsDevRevId int
-- go ahead and select based on supplied parameters

SELECT     @sOutManufacturer = dbo.Manufacturers.Name,
	   @nOutMfrId = dbo.MfrProtocols.MfrId,
	   @sOutProtocolName = dbo.DeviceProtocols.Name, 
           @sOutDeviceTypeName = dbo.DeviceTypes.Name,
	   @nOutDeviceTypeCode = dbo.DeviceTypes.DeviceType, 
           @sOutDeviceRevisionName = dbo.DeviceRevisions.Name,
	   @nOutDeviceRevisionCode = dbo.DeviceRevisions.DeviceRevision, 
	   @iAmsDevRevId = dbo.DeviceRevisions.AmsDevRevId,
	   @sOutSerialNumber = dbo.Devices.Identifier
FROM      dbo.Manufacturers with (nolock) INNER JOIN
          dbo.MfrProtocols with (nolock) ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
          dbo.DeviceProtocols with (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
          dbo.DeviceTypes with (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
          dbo.DeviceRevisions with (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
          dbo.Devices with (nolock) ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
          dbo.Blocks with (nolock) ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
          dbo.BlockAsgms with (nolock) ON dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
          dbo.ExtBlockTags with (nolock) ON dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
WHERE     (dbo.BlockAsgms.EventIdDayOut = 49710) AND
	  (dbo.ExtBlockTags.ExtBlockTag = @sAmsTag)

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
end

-- Get AlarmBlockIndex if this is a FF Device Type
if (@sOutProtocolName = 'FF' and @iReturnVal = 0)
begin

  SELECT @nOutAlarmBlockIndex = dbo.AmsUdf_BinaryToInt(cast(dbo.NamedConfigData.ParamData as varbinary(4)))
  FROM  dbo.NamedConfigData INNER JOIN dbo.NamedConfigs ON dbo.NamedConfigData.ConfigKey = dbo.NamedConfigs.ConfigKey
  WHERE (dbo.NamedConfigData.ParamName = 'frsi.AlarmBlockIndex') AND (dbo.NamedConfigs.AmsDevRevId = @iAmsDevRevId)
 
  declare @Err int, @RCount int
  -- Check for error and a record fetched
  select @Err = @@ERROR, @RCount = @@ROWCOUNT
  if (@Err <> 0 or @RCount = 0)
  begin
	PRINT 'Getting alarm block index failed'
	set @iReturnVal = -3
  end
end

return @iReturnVal

errorHandler:
PRINT 'AmsSp_GetDevTypeInfoByAmsTag_1: ' + @sErrorMsg
RETURN -2

GO

