
-- =============================================
-- AmsSp_HostDevDef_SetDefinitionInfo_1
--
--Add host device to the given plant server network
--Used in Ovation Identify PROFIBUS Device
--
-- Author:		Jeffrey Hagen
-- Create date: 03-SEPT-2010
-- Description:	Stored procedure for inserting PROFIBUS device identification
--				information into the HostDeviceDefinition Table
-- Return Values:
-- 0  - Procedure executed successfully
-- -1 - Exception thrown curing execution
-- =============================================
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_SetDefinitionInfo_1]
@nNetworkInfoKey int,
@sHostDeviceId nvarchar(255),
@sDeviceDefinition nvarchar(255),
@nGSDId int
AS
BEGIN
	set nocount on
	declare @nReturn int

	begin try
		-- see if the device is already define - if so update
		if (Exists(select * from HostDeviceDefinition where NetworkInfoKey = @nNetworkInfoKey and HostDeviceId = @sHostDeviceId))
		begin
			update HostDeviceDefinition
			set DeviceDefinition = @sDeviceDefinition, GSDId = @nGSDId
			where NetworkInfoKey = @nNetworkInfoKey and HostDeviceId = @sHostDeviceId
		end
		else -- otherwise add new entry
		begin
			insert into HostDeviceDefinition 
			(NetworkInfoKey, HostDeviceId, DeviceDefinition, GSDId) 
			values (@nNetworkInfoKey, @sHostDeviceId, @sDeviceDefinition, @nGSDId)
		end
		set @nReturn = 0 -- success
	end try
	begin catch
		set @nReturn = -1 -- something failed - signal calling code
	end catch
	return @nReturn
END

GO

