
/****** Object:  View dbo.IdAllTagView    Script Date: 1/19/00 2:09:53 PM ******/
-- do them all!!

--
-- standard views.
--
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
Create View IdAllTagView As
SELECT DISTINCT ExtBlockTags.ExtBlockTag, BlockAsgms.BlockKey
FROM ExtBlockTags INNER JOIN
    BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey

GO

