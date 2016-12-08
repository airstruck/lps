local Plugin = {}

local function createControls (editor)
    return {
        {
            -- text = 'Undo',
            icon = 'edit.undo',
            tip = 'Undo the last command.',
            press = function ()
                editor:undo()
            end,
        },
        {
            -- text = 'Redo',
            icon = 'edit.redo',
            tip = 'Redo the last command.',
            press = function ()
                editor:redo()
            end,
        },
        {
            -- text = 'Delete',
            icon = 'edit.delete',
            tip = 'Delete the current selection.',
            press = function ()
                editor:delete()
            end,
        },
        {
            -- text = 'Cut',
            icon = 'edit.cut',
            tip = 'Cut the current selection.',
            press = function ()
                editor:cut()
            end,
        },
        {
            -- text = 'Copy',
            icon = 'edit.copy',
            tip = 'Copy the current selection.',
            press = function ()
                editor:copy()
            end,
        },
        {
            -- text = 'Paste',
            icon = 'edit.paste',
            tip = 'Paste objects from cliboard.',
            press = function ()
                editor:paste(editor.width * 0.5, editor.height * 0.5)
            end,
        },
    }
end

function Plugin:enable (editor)
    local panel = editor.topbarPanel
    local oldControls = panel.controls
    panel.controls = {}
    for i, control in ipairs(oldControls) do
        panel.controls[i] = control
    end
    panel:addControls(createControls(editor))
    self.oldControls = oldControls
end

function Plugin:disable (editor)
    editor.topbarPanel.controls = self.oldControls
end

return Plugin

