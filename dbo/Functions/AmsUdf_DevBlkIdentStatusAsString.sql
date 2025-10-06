
-------------------------------------------------------------------------------
-- AmsUdf_DevBlkIdentStatusAsString 
--
-- Return the device-block identStatus (from DeviceLocation table) as a string.
--
-- Inputs --
--	@nIdentStatus - The device-block identStatus.
--
-- Outputs --
--	IdentStatusAsString as string.
--
-- Author --
--	Joe Fisher
--	10/09/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE FUNCTION AmsUdf_DevBlkIdentStatusAsString 
(@nIdentStatus int)  
RETURNS nvarchar(255) 
AS  
BEGIN 
Declare @sIdentStatus nvarchar(255)
set @sIdentStatus = N''

set @sIdentStatus = case @nIdentStatus
		when 0 then N'unknown'
		when 1 then N'identified'
		else N'unknown'
	end

Return (Select @sIdentStatus As IdentStatusAsString)

END

GO

