local TextChatService = game:GetService("TextChatService")
local generalChannel = TextChatService.TextChannels.RBXGeneral

-- This sends the message as the player
generalChannel:SendAsync("Message Goes Here")
