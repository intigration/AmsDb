-----------------------------------------------------------------------
-- AmsSp_IsTagAssigned_1
--
-- Indicate whether the tag is currently assigned (1) or not (0).
--
-- Inputs -
--	sAmsTagName nvarchar(255)
--
-- Outputs -
--	CurrentlyAssigned -- either 1 or 0, currently assigned or not.
--
-- Returns -
--	0  - Succeeded
--	-1 - Error, unable to get information.
--
-- Jane Xiao, 7/3/2003
--
--
CREATE  PROCEDURE AmsSp_IsTagAssigned_1
@sAmsTagName nvarchar(255),
@nCurrentlyAssigned int output
AS

declare @iReturnVal int
declare @Assigned int
set @iReturnVal = 0
set @nCurrentlyAssigned = 0

SELECT	@nCurrentlyAssigned = (case max(dbo.BlockAsgms.EventIdDayOut)
	     		       when 49710 then 1
					  else 0
			       end) 
FROM	ExtBlockTags LEFT OUTER JOIN BlockAsgms 
		     ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
WHERE	ExtBlockTags.ExtBlockTag = @sAmsTagName

if (@@ERROR <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = 0

-- need to also take into account NamedConfigs- the ConfigName shares the same
-- domain as the AmsTag and all have to be unique.
if (@nCurrentlyAssigned = 0)
begin
	select @nCurrentlyAssigned = count(*)
	from NamedConfigs
	where ConfigName = @sAmsTagName
end

if (@@ERROR <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = 0

return @iReturnVal

GO

