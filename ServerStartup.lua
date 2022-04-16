function split(inputstr, sep) sep=sep or '%s' local t={}  for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do table.insert(t,field)  if s=="" then return t end end end

modem = peripheral.find("modem")
modem.open(42)

local passwd = "369"
local doorState = false

local event, side, channel, replyChannel, message, distance
while true do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    command = split(message, ":")[1]
    pw = split(message, ":")[2 ]
    print(command)
    print(pw)
    if command == "login" then
        if pw == passwd then
            modem.transmit(replyChannel, 42, "1")
        else
            modem.transmit(replyChannel, 42, "0") 
        end
    elseif command == "toggleDoor" then
        if pw == passwd then
            doorState = not doorState
            rs.setOutput("right", doorState)
            local reply = "0"
            if doorState then
                reply = 1
            end
            modem.transmit(replyChannel, 42, reply) 
        end
    end
end