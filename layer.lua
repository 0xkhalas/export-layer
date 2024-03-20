local function getLayer(layer)
    if not layer then return app.alert("There's no active layer") end

    local cel = layer:cel(app.activeFrame)
    if not cel then return app.alert("The layer has no cel in the current frame") end

    local img = cel.image:clone()

    local function calcTrimmedBounds(image)
        local left, top, right, bottom = image.width, image.height, 0, 0

        for x = 0, image.width - 1 do
            for y = 0, image.height - 1 do
                if image:getPixel(x, y) ~= Color{ a=0 } then
                    if x < left then left = x end
                    if x > right then right = x end
                    if y < top then top = y end
                    if y > bottom then bottom = y end
                end
            end
        end

        if left > right or top > bottom then return nil end
        return { x = left, y = top, width = right - left + 1, height = bottom - top + 1 }
    end

    local bounds = calcTrimmedBounds(img)
    if not bounds then return app.alert("The layer is empty or fully transparent") end

    local trimmedImg = Image(bounds.width, bounds.height, img.colorMode)
    trimmedImg:drawImage(img, -bounds.x, -bounds.y)

    return trimmedImg
end

local function saveImage(data)
    local spr = app.activeSprite
    if not spr then return app.alert("There's no active sprite") end

    if not data[4] then
        for _,layer in ipairs(spr.layers) do
            if layer.isVisible then
                local trimmedImage = getLayer(layer)
                local path = data[1] .. "\\" .. layer.name .. "." .. data[2]

                trimmedImage:resize(trimmedImage.width * data[3], trimmedImage.height * data[3])
                trimmedImage:saveAs(path)
            end
        end
    else
        local trimmedImage = getLayer(app.activeLayer)
        local path = data[1] .. "." .. data[2]

        trimmedImage:resize(trimmedImage.width * data[3], trimmedImage.height * data[3])
        trimmedImage:saveAs(path)
    end
end

local dlg = Dialog("Save Trimmed Image")

dlg:file{
    id = "filepath",
    title = "Enter Folder name:",
    open = false,
    save = true,
    filetypes = { "" },
}

dlg:combobox{
    id = 'format',
    label = 'Export Format:',
    option = 'png',
    options = {'png', 'jpg'}
}

dlg:check{
    id = "onelayer",
    label = "Is One Layer:",
}

dlg:slider{id = 'scale', label = 'Export Scale:', min = 1, max = 10, value = 1}

dlg:button{
    text = "Save",
    onclick = function()
        local path = dlg.data.filepath
        if path then
            saveImage({dlg.data.filepath, dlg.data.format, dlg.data.scale, dlg.data.onelayer})
            dlg:close()
        end
    end
}

dlg:button{ text = "Cancel", onclick = function() dlg:close() end }
dlg:show{ wait = false }
