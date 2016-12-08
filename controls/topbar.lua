local lf = love.filesystem
    
return function (editor)
    return {
        {
            icon = 'file.plugin',
            tip = 'Manage Plugins',
            press = function (self, cx, cy, cw, ch)
                local ui = editor.ui
                local panels = ui.panels
                local panel = ui.Panel(cx, cy + ch, 200, 20)
                panel.transient = true
                panels[#panels + 1] = panel
                
                local controls = {
                    {
                        text = 'Plugins Installed',
                        type = 'label',
                    },
                }
                local dir = 'plugin'
                local files = lf.getDirectoryItems(dir)
                table.sort(files)
                for _, file in ipairs(files) do
                    if file:find('%.lua$') then
                        local name = file:gsub('%.lua$', '')
                        local path = dir .. '.' .. name
                        name = name:gsub('^%d+_', ''):gsub('_', ' ')
                            :gsub('%f[%w].', string.upper)
	                    controls[#controls + 1] = {
                            text = name,
                            tip = 'Enable or disable this plugin',
                            isSelected = function ()
                                local m = package.loaded[path]
                                return m and m.pluginState == 'enabled'
                            end,
                            press = function (self)
                                if self:isSelected() then
                                    editor.pluginManager:disable(path)
                                else
                                    editor.pluginManager:enable(path)
                                end
                            end,
	                    }
                    end
                end
                
                panel:addControls(controls)
            end
        },
        {
            icon = 'file.load',
            tip = 'Load a saved scene',
            press = function (self, cx, cy, cw, ch)
                local ui = editor.ui
                local panels = ui.panels
                local panel = ui.Panel(cx, cy + ch, 200, 20)
                panel.transient = true
                panels[#panels + 1] = panel
                
                local controls = {
                    { text = 'Load Scene', type = 'label' },
                }
                
                local dir = 'scene'
                local scenes = lf.getDirectoryItems(dir)
                table.sort(scenes)
                
                for _, scene in ipairs(scenes) do
                    controls[#controls + 1] = {
                        text = scene,
                        tip = 'Load this scene, destroying unsaved changes',
                        press = function (self)
                            panel:removeFrom(ui)
                            editor:loadScene(scene)
                        end,
                    }
                end
                
                panel:addControls(controls)
                
                if #controls == 1 then
                    panel:addControls {
                        { text = '(no scenes found)' }
                    }
                end
            end
        },
        {
            icon = 'file.save',
            tip = 'Save current scene',
            press = function (self, cx, cy, cw, ch)
                local ui = editor.ui
                local panels = ui.panels
                local panel = ui.Panel(cx, cy + ch, 200, 20)
                panel.transient = true
                panels[#panels + 1] = panel
                panel:addControls {
                    { text = 'Save New Scene', type = 'label' },
                    require 'ui.textbox' {
                        value = '',
                        returned = function (self, value)
                            panel:removeFrom(ui)
                            editor:saveScene(value)
                        end,
                    },
                }
                if not editor.currentScene then return end
                panel:addControls {
                    { text = 'Save Current Scene', type = 'label' },
                    {
                        text = editor.currentScene,
                        press = function (self)
                            panel:removeFrom(ui)
                            if self.text then
                                editor:saveScene(self.text)
                            end
                        end,
                    },
                }
            end
        },
        --[[
        {
            icon = 'file.import',
            tip = 'Import a saved scene into current scene',
        },
        --]]
    }
end

