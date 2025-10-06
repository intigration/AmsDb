
----------------------------------------------------------------------
-- AmsSp_AL_GetListOfPlantServerNames
--
-- obtains a list of all plant servers.
--
-- Inputs -
--  plantServerKey.
--  updateCounterCheckValue
--
-- Outputs -
--  bVal - true or false.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_GetListOfPlantServerNames
@sPsNameList nvarchar(max) output
AS
set nocount on
set @sPsNameList = ''

declare @cr1 cursor
set @cr1 = cursor for
SELECT  PlantServer.PlantServerId
FROM  PlantServer with (nolock) WHERE PlantServerKey <> -1

Open @cr1

declare @sPsName nvarchar(255)
declare @nCt int
set @nCt = 0
fetch next from @cr1 into @sPsName
while (@@FETCH_STATUS = 0)
begin
	set @sPsName = '''' + @sPsName + ''''
	if (@nCt = 0)
	begin
		set @sPsNameList = @sPsName
	end
	else
	begin
		set @sPsNameList = @sPsNameList + ',' + @sPsName
	end
	set @nCt = @nCt + 1
	fetch next from @cr1 into @sPsName
end	-- while

close @cr1
deallocate @cr1

return

GO

