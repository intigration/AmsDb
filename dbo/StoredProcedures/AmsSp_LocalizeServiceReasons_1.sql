-----------------------------------------------------------------------
-- AmsSp_LocalizeServiceReasons_1
--
-- Localize the ServiceReasons table
--
-- Inputs -
-- @nSvcId int
-- @sSvcDesc
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeServiceReasons_1
@nSvcId int,
@sSvcDesc nvarchar(50)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update ServiceReasons set ServiceDesc = @sSvcDesc
		where ServiceId = @nSvcId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

