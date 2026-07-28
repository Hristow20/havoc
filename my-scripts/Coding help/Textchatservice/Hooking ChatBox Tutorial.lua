local CoreGui = game:GetService("CoreGui")

-- grab the chat textbox
local chatPath = CoreGui:WaitForChild("ExperienceChat")
local textBox  = chatPath.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox

-- block the original send connections
for _, conn in pairs(getconnections(textBox.FocusLost)) do conn:Disable() end

-- hook into the chat
textBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed or textBox.Text == "" then return end
    local message = textBox.Text -- captured message
    textBox.Text  = ""           -- clear the box
    textBox:ReleaseFocus()       -- release focus
end)
