
-- =============================================
-- AmsSp_HostDevDef_GetHostDevDefInfoFromNetworkInfo_1
--
--Get host device from the given plant server network
--Used in Ovation Identify PROFIBUS Device
--
-- Author:		Jeffrey Hagen
-- Create date: 03-SEPT-2010
-- Description:	Stored procedure for retrieving PROFIBUS device identification
--				information from the HostDeviceDefinition Table
-- Return Values:
-- 0  - Procedure executed successfully
-- -1 - Device is either not in the table or is listed more than once
-- -2 - Exception thrown curing execution
-- =============================================
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_GetHostDevDefInfoFromNetworkInfo_1]
@nNetworkInfoKey int,
@sHostDeviceId nvarchar(255),
@sDeviceDefinition nvarchar(255) output,
@nGSDId int output
AS
BEGIN
	set nocount on
	declare @nReturn int

	begin try
		select @sDeviceDefinition = DeviceDefinition, @nGSDId = GSDId from HostDeviceDefinition
		where (NetworkInfoKey = @nNetworkInfoKey) and (HostDeviceId = @sHostDeviceId)
		if (@@ROWCOUNT = 1)
		begin
			set @nReturn = 0 -- success
		end
		else
		begin
			set @nReturn = -1 -- failed - device not in table or listed multiple times
		end
	end try
	begin catch
		set @nReturn = -2 -- exception - signal calling code
	end catch
	return @nReturn
END

GO

