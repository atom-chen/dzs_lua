--[[
 --
 -- add by vicky
 -- 2014.11.26 
 --
 --]]
local YueqianMsgbox =
    class(
    "YueqianMsgbox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function YueqianMsgbox:ctor(param)
    local confirmFunc = param.confirmFunc
    local cancleFunc = param.cancleFunc
    local itemData = param.itemData
    local isCanGet = param.isCanGet

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBReaderLoad("nbhuodong/yueqian_msgbox.ccbi", proxy, rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    rootnode["titleLabel"]:setString("提示")
    rootnode["day_lbl"]:setString(tostring(itemData.day))

    if itemData.vip > 0 then
        rootnode["vip_node"]:setVisible(true)
        rootnode["vip_lbl"]:setString("VIP" .. tostring(itemData.vip))
    else
        rootnode["vip_node"]:setVisible(false)
    end

    if isCanGet == true then
        rootnode["getRewardBtn"]:setVisible(true)
        rootnode["confirmBtn"]:setVisible(false)
    else
        rootnode["confirmBtn"]:setVisible(true)
        rootnode["getRewardBtn"]:setVisible(false)
    end

    rootnode["itemDesLbl"]:setString(itemData.describe)

    -- 图标
    local rewardIcon = rootnode["itemIcon"]
    rewardIcon:removeAllChildren(true)
    ResMgr.refreshIcon(
        {
            id = itemData.id,
            resType = itemData.iconType,
            itemBg = rewardIcon
        }
    )

    -- 属性图标
    local canhunIcon = rootnode["reward_canhun"]
    local suipianIcon = rootnode["reward_suipian"]
    canhunIcon:setVisible(false)
    suipianIcon:setVisible(false)
    if itemData.type == 3 then
        -- 装备碎片
        suipianIcon:setVisible(true)
    elseif itemData.type == 5 then
        -- 残魂(武将碎片)
        canhunIcon:setVisible(true)
    end

    -- 名称
    local nameKey = "name_lbl"
    local nameColor = cc.c3b(255, 255, 255)
    if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then
        nameColor = ResMgr.getItemNameColor(itemData.id)
    elseif itemData.iconType == ResMgr.HERO then
        nameColor = ResMgr.getHeroNameColor(itemData.id)
    end

    local nameLbl =
        newTTFLabelWithShadow(
        {
            text = itemData.name,
            size = 22,
            color = nameColor,
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_fzcy,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )

    nameLbl:setPosition(0, nameLbl:getContentSize().height / 2)
    rootnode[nameKey]:removeAllChildren()
    rootnode[nameKey]:addChild(nameLbl)

    -- 数量
    local numLbl =
        newTTFLabelWithOutline(
        {
            text = "数量：" .. tostring(itemData.num),
            size = 22,
            color = cc.c3b(255, 255, 255),
            outlineColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_fzcy,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )

    numLbl:setPosition(0, numLbl:getContentSize().height / 2)
    rootnode["num_lbl"]:removeAllChildren()
    rootnode["num_lbl"]:addChild(numLbl)

    local function closeFunc()
        if cancleFunc ~= nil then
            cancleFunc()
        end
        self:removeFromParent(true)
    end

    rootnode["tag_close"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["confirmBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["getRewardBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if confirmFunc ~= nil then
                confirmFunc()
            end
            self:removeFromParent(true)
        end,
        CCControlEventTouchUpInside
    )
end

return YueqianMsgbox
