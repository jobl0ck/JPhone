----Settings----
local BackgroundColor = colors.lightBlue
local AppColorDefault = colors.cyan
local AppColorPressed = colors.blue

----Creating Fields----
local ScreenWidth, ScreenHeight = term.getSize()
local pocketScreenWidth = 26
local pocketScreenHeight = 20
local roomNumber = 0
local roomNumberOld = -1
local isPowerOptionsShown = false
local isPowerOptionsShownOld = false
local updateScreen = false
local doNoDelayPwRead = false
local modem = peripheral.find("modem")
local ConCenPw = ""
local ConCenDoorState = false
--RoomList: 0 = MainMenu, 1 = Settings, 2 = Control Center Login
local buttonData = {
    {
        function ()     --Action
            roomNumber = 1
        end,            --
        "Settings",     --Text
        2,--X
        3,--Y
        0,--Room
        colors.black, --Text Color
        colors.lightGray --Bg Color
    },
    {
        function ()
            roomNumber = 2
        end,
        "CC",
        13,
        3,
        0,--Room
        colors.black, --Text Color
        colors.lightGray --Bg Color
    },
    {
        function ()
            ConCenToggleDoor()
        end,
        "Door",
        2,
        5,
        3,
        colors.black,
        colors.red
    }
}

----Defining Functions----
function IsButtonClicked(tX,tY,bX,bY,mX,mY,targetFunction,bRoom)
    if (tX <= mX and tY <= mY) and (bX >= mX and bY >= mY) and bRoom == roomNumber then
        targetFunction()
    end
end

function DrawButton(x, y, text, tColor, color)
    paintutils.drawFilledBox(x, y, x+1+string.len(text), y+2, color)
    term.setTextColor(tColor)
    term.setCursorPos(x+1,y+1)
    print(text)
end
function DrawNotificationBar()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,1)
    print(textutils.formatTime(os.time(), false))
    if roomNumber == 0 then
        term.setCursorPos(pocketScreenWidth-2,1)
        print("vvv")
    end
end
function DrawMainMenu()
    if roomNumber ~= roomNumberOld or updateScreen then
        print("Updateing")
        updateScreen = false
        roomNumberOld = roomNumber
        if     roomNumber == 0 then
            paintutils.drawFilledBox(1,2,pocketScreenWidth,pocketScreenHeight,BackgroundColor)
        elseif roomNumber == 1 then
            paintutils.drawFilledBox(1,2,pocketScreenWidth,pocketScreenHeight,BackgroundColor)
            term.setCursorPos(pocketScreenWidth/2-5, 3)
            print("Settings")
            term.setCursorPos(pocketScreenWidth, 2)
            print("x")
        elseif roomNumber == 2 then
            paintutils.drawFilledBox(1,2,pocketScreenWidth,pocketScreenHeight,BackgroundColor)
            term.setCursorPos(pocketScreenWidth, 2)
            print("x")
            term.setCursorPos(2,3)
            term.setTextColor(colors.black)
            print("ControllCenter")
            term.setCursorPos(2,5)
            print("Password:")
            paintutils.drawLine(2,6,pocketScreenWidth-2, 6, colors.white)
            term.setCursorPos(2,6)
            term.setCursorBlink(true)
            local pw = read("*")
            if pw ~= "" then
                term.setCursorBlink(false)
                --modem Interface
                modem.open(43)
                modem.transmit(42, 43, "login:"..pw)
                local event, side, channel, replyChannel, message, distance
                repeat
                    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
                until channel == 43
                term.setCursorPos(2,8)
                if message == "1" then
                    print("success")
                    ConCenPw = pw
                    roomNumber = 3
                elseif message == "0" then
                    print("failed")
                    roomNumber = 0
                end
            else
                roomNumber = 0
            end
        elseif roomNumber == 3 then
            paintutils.drawFilledBox(1,2,pocketScreenWidth,pocketScreenHeight,BackgroundColor)
            term.setCursorPos(pocketScreenWidth, 2)
            print("x")
            term.setCursorPos(2,3)
            term.setTextColor(colors.black)
            print("ControllCenter")
        end
        for i, button in pairs(buttonData) do
            if button[5] == roomNumber then
                DrawButton(button[3], button[4], button[2], button[6], button[7])
            end
        end
    end
    if isPowerOptionsShown ~= isPowerOptionsShownOld then
        isPowerOptionsShownOld = isPowerOptionsShown
        if isPowerOptionsShown then
            paintutils.drawFilledBox(1,2,pocketScreenWidth, 4, colors.cyan)
            term.setTextColor(colors.black)
            term.setCursorPos(2, 3)
            print("poweroff")
            term.setCursorPos(14, 3)
            print("reboot")
        end
    end
end

----Controll Center Interaction----
function ConCenToggleDoor()
    modem.open(43)
    modem.transmit(42, 43, "toggleDoor:"..ConCenPw)
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == 43
    term.setCursorPos(2,8)
    if message == "1" then
        ConCenDoorState = true
        buttonData[3][7] = colors.green
    elseif message == "0" then
        ConCenDoorState = false
        buttonData[3][7] = colors.red
    end
    updateScreen = true
end

----Setup----

--Welcome Screen--
paintutils.drawFilledBox(1,1,ScreenWidth,ScreenHeight, colors.black)
paintutils.drawFilledBox(1,1,pocketScreenWidth,pocketScreenHeight, colors.black)

term.setCursorPos(pocketScreenWidth/2-4, pocketScreenHeight/2-1)

write("W")
sleep(0.1)
write("e")
sleep(0.1)
write("l")
sleep(0.1)
write("c")
sleep(0.1)
write("o")
sleep(0.1)
write("m")
sleep(0.1)
write("e")
sleep(0.1)

term.setCursorPos(pocketScreenWidth/2-5, pocketScreenHeight/2)

write("t")
sleep(0.1)
write("o")
sleep(0.1)
write(" ")
sleep(0.1)
write("J")
sleep(0.1)
write("P")
sleep(0.1)
write("h")
sleep(0.1)
write("o")
sleep(0.1)
write("n")
sleep(0.1)
write("e")
sleep(0.1)

sleep(0.5)

paintutils.drawLine(pocketScreenWidth+1,1,pocketScreenWidth+1,pocketScreenHeight, colors.white)
local event, button, x, y

----Main Loop----
function main()
    while true do
        sleep(0.1)
        DrawMainMenu()
        DrawNotificationBar()
    end
end

----Events----
function mouse_click()
    repeat
        event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            if not isPowerOptionsShown then
                for i, button in pairs(buttonData) do
                    IsButtonClicked(button[3],button[4],button[3]+1+string.len(button[2]), button[4]+2, x,y, button[1], button[5])
                end
                if roomNumber ~= 0 and x==pocketScreenWidth and y==2 then
                    roomNumber = 0
                end
            end
            if isPowerOptionsShown then
                IsButtonClicked(2, 3, 9, 3, x,y, function ()
                    os.shutdown()
                end, roomNumber)
                IsButtonClicked(14, 3, pocketScreenWidth-1, 3, x,y, function ()
                    os.reboot()
                end, roomNumber)
            end
            IsButtonClicked(pocketScreenWidth-2, 1, pocketScreenWidth, 1, x,y, function ()
                isPowerOptionsShown = not isPowerOptionsShown
                if isPowerOptionsShown == false then updateScreen = true end
            end, roomNumber)
        end
    until 1~=1
end

parallel.waitForAny(main, mouse_click)