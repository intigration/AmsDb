-----------------------------------------------------------------------
-- AmsSp_LocalizeTestDefinition_1
--
-- Localize the TestDefinition table
--
-- Inputs -
-- @nTestDefinitionId int
-- @sName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeTestDefinition_1
@nTestDefinitionId int,
@sName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update TestDefinition set Name = @sName
		where TestDefinitionId = @nTestDefinitionId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

