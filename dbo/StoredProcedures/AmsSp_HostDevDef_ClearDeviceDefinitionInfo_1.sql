
-- =============================================
-- AmsSp_HostDevDef_ClearDeviceDefinitionInfo_1
--
--Delete host device from the given plant server network
--Used in Ovation Identify PROFIBUS Device
--
-- Author:		Jeffrey Hagen
-- Create date: 03-SEPT-2010
-- Description:	Stored procedure for clearing PROFIBUS device identification
--				information from the HostDeviceDefinition Table
-- Return Values:
-- 0  - Procedure executed successfully
-- -1 - Exception thrown curing execution
-- =============================================
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_ClearDeviceDefinitionInfo_1]
@nNetworkInfoKey int,
@sHostDeviceId nvarchar(255)
AS
BEGIN
	set nocount on
	declare @nReturn int

	begin try
		delete from HostDeviceDefinition
		where (NetworkInfoKey = @nNetworkInfoKey) and (HostDeviceId = @sHostDeviceId)
		set @nReturn = 0 -- success
	end try
	begin catch
		set @nReturn = -1 -- exception - signal calling code
	end catch
	return @nReturn
END

GO

