-----------------------------------------------------------------------
-- AmsSp_GetBlockKey_ByAmsTag_1
--
-- Gets the Device Block Key; if not found then returns -999.
--
-- Inputs -
--	@strAmsTag nvarchar(255)
--		This is the Ams Tag Name.
--
-- Outputs -
--	@nBlockKey int
--		The BlockKey.
--
-- Returns -
--	0 - successful.
--	-1 - Error
--      -2 - Found more than one BlockKey
--
-- Jane Xiao, 06/20/2003
--
CREATE PROCEDURE AmsSp_GetBlockKey_ByAmsTag_1
@strTag nvarchar(255),
@nBlockKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0
set @nBlockKey = -999
declare @Err int, @Rowcount int

-- get BlockKey if present.
select @nBlockKey = BlockAsgms.BlockKey
from ExtBlockTags, BlockAsgms
where ExtBlockTags.ExtBlockTag =  @strTag
and BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
AND BlockAsgms.EventIdDayOut = 49710	-- the magic number for current assignment!!

select @Err = @@ERROR, @Rowcount = @@ROWCOUNT

if (@Rowcount = 0)
   begin
	set @nBlockKey = -999
   end

if (@Rowcount > 1)
   begin
	set @iReturnVal = -2
   end

if @Err != 0 
    set @iReturnVal = -1

return @iReturnVal

GO

