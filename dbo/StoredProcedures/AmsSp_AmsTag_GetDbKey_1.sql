----------------------------------------------------------------------
-- AmsSp_AmsTag_GetDbKey_1
--
-- Get the database key for AmsTag.
--
-- Inputs -
--	@sAmsTag nvarchar(255)
--		This is the tag name.
--
-- Outputs -
--	@nDbKey int
--		The database key.  Will be -999 if AmsTag not found.
--
-- Returns -
--	0 - successful.
--	-1 - Error, tag not present.
--  -2 - Error, general error.
--
-- Joe Fisher 9/24/2003
--
CREATE PROCEDURE AmsSp_AmsTag_GetDbKey_1
@sAmsTag nvarchar(255),
@nDbKey int output
AS
declare @nReturn int
set @nReturn = 0
set @nDbKey = null

select @nDbKey = ExtBlockTagKey from ExtBlockTags with (nolock) where ExtBlockTag = @sAmsTag

if (@nDbKey is null)
begin
	set @nReturn = -1
	set @nDbKey = -999
end

return @nReturn

GO

