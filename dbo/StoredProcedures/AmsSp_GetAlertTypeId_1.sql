
--------------------------------------------------------------------
-- AmsSp_GetAlertTypeId_1
-- Get AlertTypeId for the given Uid
-- Input - 
--	@strUid		nvarchar(255)
-- Output -
--	@iAlertTypeId	Alert Type Id
-- Returns -
--	0 - successful.
--	-1 - Error, unvalid input Uid.

CREATE PROCEDURE AmsSp_GetAlertTypeId_1
@strUid nvarchar(255),
@iAlertTypeId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0
declare @iTempAlertTypeId int

select @iTempAlertTypeId = AlertTypeId 
from AlertTypes with (nolock)
where Uid = @strUid

if (@@ERROR <> 0)
begin
	set @iReturnVal = -1
end
else if (@iTempAlertTypeId is null)
begin
	set @iReturnVal = -1
end
else
begin
	set @iAlertTypeId = @iTempAlertTypeId
end

return @iReturnVal

GO

