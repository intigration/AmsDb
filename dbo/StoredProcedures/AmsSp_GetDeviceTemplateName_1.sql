-----------------------------------------------------------------------
-- AmsSp_GetDeviceTemplateName_1
--
-- Get device template name.
--
-- if there are more than one templates for the given device type and template type,
-- the top 1 template name in ascending order will be returned.
--
-- Inputs -
-- @MfrId				int,			Manufacturer id
-- @nDeviceTypeCode		int,			Device type number
-- @nDeviceRevisionCode	int,			Device revision number
-- @sProtocol			nvarchar(255),	Device Protocol
-- @sDeviceTemplateType	nvarchar(1),	Device Template type
--
-- Outputs -
--	@sDeviceTemplateName	- device template name
--
-- Returns -
--	returns the number of rows in the resultset.
--      -1 - device template not found.
--		-2 - general error.
--
-- Nghy Hong, 4/13/2010
--
CREATE PROCEDURE AmsSp_GetDeviceTemplateName_1
@MfrId					int,
@nDeviceTypeCode		int,
@nDeviceRevisionCode	int,
@sProtocol				nvarchar(255),
@sDeviceTemplateType	nvarchar(1),
@sDeviceTemplateName	nvarchar(255) output
AS
DECLARE @iReturnVal int
set @iReturnVal = 0

set nocount on;

Begin Try

	SELECT TOP 1 @sDeviceTemplateName = NamedConfigs.ConfigName
	FROM  NamedConfigs INNER JOIN
		  DeviceRevisions ON NamedConfigs.AmsDevRevId = DeviceRevisions.AmsDevRevId INNER JOIN
		  DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId INNER JOIN
		  MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId INNER JOIN
		  DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId INNER JOIN
		  Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId
	WHERE (MfrProtocols.MfrId = @MfrId) 
		  AND (DeviceTypes.DeviceType = @nDeviceTypeCode) 
		  AND (DeviceRevisions.DeviceRevision = @nDeviceRevisionCode)  
		  AND (DeviceProtocols.Name = @sProtocol)
		  AND (NamedConfigs.ConfigType = @sDeviceTemplateType)
	ORDER BY NamedConfigs.ConfigName ASC

	if (@@ROWCOUNT = 0)
	begin
		set @iReturnVal = -1;
	end

End try
Begin Catch
	set @iReturnVal = -2;
	PRINT 'AmsSp_GetDeviceTemplateName_1: ' + ERROR_MESSAGE();
End Catch;

return @iReturnVal

GO

