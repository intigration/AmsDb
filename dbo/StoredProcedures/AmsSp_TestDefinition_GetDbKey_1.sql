----------------------------------------------------------------------
-- AmsSp_TestDefinition_GetDbKey_1
--
-- Get the database key for the test definition name.
--
-- Inputs -
--	@sTestDefinitinoName nvarchar(255)
--		This is the test definition name.
--
-- Outputs -
--	@nDbKey int
--		The database key.  Will be -999 if test definition not found.
--
-- Returns -
--	0 - successful.
--	-1 - Error, test definition not present.
--  -2 - Error, general error.
--
-- Joe Fisher 9/24/2003
--
CREATE PROCEDURE AmsSp_TestDefinition_GetDbKey_1
@sTestDefinitinoName nvarchar(255),
@nDbKey int output
AS
declare @nReturn int
set @nReturn = 0
set @nDbKey = null

select @nDbKey = TestDefinitionId from TestDefinition where TestDefinition.Name = @sTestDefinitinoName

print 'dbKey = ' + convert(nvarchar(10), @nDbKey)

if (@nDbKey is null)
begin
	set @nReturn = -1
	set @nDbKey = -999
end

return @nReturn

GO

