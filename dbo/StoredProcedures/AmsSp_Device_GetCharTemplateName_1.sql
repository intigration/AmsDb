
-----------------------------------------------------------------------
-- AmsSp_Device_GetCharTemplateName_1
--
-- Get the FF device's characteristics template name.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		This is the device identifier.
-- Outputs -
--	@sConfigName nvarchar(256)
--		This is the template name
--
-- Returns -
--	0 if successful else non-zero.
--
-- Joe Fisher, 07/15/2003
--
CREATE  PROCEDURE AmsSp_Device_GetCharTemplateName_1
@strDeviceID nvarchar(256),
@sConfigName nvarchar(256) output
AS
declare @devRevId int

set @sConfigName = ''

-- need to get the device's devRevId.
select top 1 @devRevId = AmsDevRevId from Devices where Identifier COLLATE SQL_Latin1_General_CP1_CS_AS = @strDeviceID
if @@ROWCOUNT = 0
	return -1	-- device not found.

-- now get the characteristics template name based on the deviceRevisionId and the
-- fact that we should have one and only one template of the deviceRevision and with
-- the configuration type of 'C'.
select top 1 @sConfigName = ConfigName from NamedConfigs
	where (AmsDevRevId = @devRevId) and (ConfigType = 'C')

return 0

Grant Execute on AmsSp_Device_GetCharTemplateName_1 to AmsDbUser, AmsDbViewer

GO

