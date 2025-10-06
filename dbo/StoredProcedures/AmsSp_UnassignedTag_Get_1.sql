-----------------------------------------------------------------------
-- AmsSp_UnassignedTag_Get_1
--
-- Get a unassigned tag name.
--
-- Inputs -
--	@sAmsTag nvarchar(255)
--		This is the tag name.
--
-- Outputs -
--	AmsTagName
--	ExtBlockTagKey
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Jane Xiao, 7/3/2003
--
CREATE PROCEDURE AmsSp_UnassignedTag_Get_1
@sTag nvarchar(255),
@sAmsTagName nvarchar(255) output,
@nTagExist int output  -- 0: exists, -1: not exists  
AS
declare @sTempTag nvarchar(255)
declare @nRowCount int
declare @nTagCount int
declare @iReturn int
declare @nCurrentlyAssigned int
declare	@nExitLoop int

set @sTempTag = @sTag
set @nRowCount = 0
set @nTagCount = 0
set @nExitLoop = 0
set @nTagExist = 0

while @nExitLoop = 0 and @nTagCount < 99
begin 
	-- must include namedConfigs in determining if tag exists or not.
	select     ExtBlockTag as AmsTag
	from       ExtBlockTags
	where	   ExtBlockTag = @sTempTag 
	union all
	select	   ConfigName as AmsTag
	from	   NamedConfigs
	where 	   ConfigName = @sTempTag

	set @nRowCount = @@rowcount
	if @nRowCount <> 0  --the tag exists in db
	    begin
		set @nTagExist = 0	-- the tag does exist
		--is the tag currently assigned?
		exec AmsSp_IsTagAssigned_1 @sTempTag, @nCurrentlyAssigned output
		--check if the tag is assigned, if yes, add _nn suffix and try again
		if @nCurrentlyAssigned = 1
		begin
			set @nExitLoop = 0
			set @nTagCount = @nTagCount + 1
			if @nTagCount < 10
				set @sTempTag = @sTag + '_0' + cast(@nTagCount as char(1))
			else
				set @sTempTag = @sTag + '_' + cast(@nTagCount as char(2))
		end
		else	--to exit loop
			set @nExitLoop = -1 
	    end
	else	--to exit loop
	   begin
		set @nExitLoop = -1 
		set @nTagExist = -1	-- the tag does not exist
           end
end
if @nExitLoop = 0
    begin
	--use current datetime as tag name
	set @sAmsTagName = convert(nvarchar(50), getdate(), 126)  
	set @nTagExist = -1	-- the tag does not exist
    end
else
    begin
	set @sAmsTagName = @sTempTag
    end

if @@error > 0
	set @iReturn = -1
else
	set @iReturn = 0

return @iReturn

GO

