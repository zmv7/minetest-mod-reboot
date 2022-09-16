-- Reboot mod for Minetest
-- Waits for the last player to leave then shuts the server down
--
-- Copyright © 2018 by luk3yx
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local reboot = false

local function checkReboot()
    if not reboot then return end
    if not next(minetest.get_connected_players()) then
        if minetest.global_exists('irc') then
            irc.say("The server is empty! Rebooting...")
        end
        minetest.chat_send_all('Rebooting by schedule')
        minetest.request_shutdown("Rebooting", true, 1)
    end
end

minetest.register_on_leaveplayer(function()
    minetest.after(1,function() --important thing
        checkReboot()
    end)
end)

minetest.register_chatcommand("reboot", {
    privs = {server = true},
    params = "[-f]/[-c]", --params instead of cancelreboot command
    description = "Reboots the server next time it is empty. `-c` -cancel, `-f` - force",
    func = function(name,param)
        if param == '-f' then
            minetest.request_shutdown("Rebooting...", true, 5)
            return true, 'Force Rebooting!' end
        if param == '-c' then
            reboot = false
            return true, 'Scheduled Reboot canceled' end
        if reboot then
            return false, "There is already a reboot pending!"
        end
        reboot = true
        checkReboot()
        return true, "Reboot scheduled"
    end
})
