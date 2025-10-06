
----------------------------------------------------------------------
-- AmsSp_SystemDefaults_GetValue_1
--
-- returns the value given the parameter you pass in.
--
-- Inputs -
--  @sParameter nvarchar(256) Parameter name.
--
-- Outputs -
--  the value of the parameter
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - DB error
--
-- James Kramer 10/20/2008
--
CREATE PROCEDURE AmsSp_SystemDefaults_GetValue_1
@sParameter nvarchar(50),
@sData nvarchar(50) output
AS

declare @rtn int
declare @error int
declare @count int

set @rtn = 0

BEGIN TRY
select @sData = Data from SystemDefaults where Parameter = @sParameter

select @error = @@ERROR, @count = @@ROWCOUNT

if (@count = 0)
begin
	set @rtn = -1
end

if (@error > 0)
begin
	set @rtn = -2
end

END TRY
BEGIN CATCH
	set @rtn = -2
END CATCH

return @rtn

GO

