
-- =============================================
-- AmsSp_HostDevDef_GetAmsDeviceTag_1
--
-- Author:		Jeffrey Hagen
-- Create date: 03-SEPT-2010
-- Description:	Stored procedure for retrieving AmsDeviceTag
--		from the Devices Table using Identifier
-- Return Values:
-- 0  - Procedure executed successfully
-- -1 - Device is either not in the table or is listed more than once
-- -2 - Exception thrown curing execution
-- =============================================
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_GetAmsDeviceTag_1]
@sDeviceIdentifier nvarchar(255),
@sAmsDeviceTag nvarchar(255) output
AS
BEGIN
	set nocount on
	declare @nReturn int

	begin try
		select @sAmsDeviceTag = AmsTag from AmsVw_BlockTags
		where SerialNumber = @sDeviceIdentifier
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

