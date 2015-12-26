
function getPinStateName(i)
  if(i == 0)then 
    return "pin0State"
  elseif(i==1)then
    return "pin1State"
  elseif(i==2)then
    return "pin2State"
  else 
    return -1
  end 
end    
     
function mkButton(i)
  local strpinstatename = getPinStateName(i)
  local b = _G[strpinstatename]
  local pini = "pin"..i 
  local color = offcolor
  if(b)then
     color = oncolor
  end 
  local notb="ON"
  local bstr = "Turn ON"
  if(b)then
    bstr = "Turn OFF"
    notb = "OFF"
  end 
  local btn = "<a href=\"?"..pini.."="..notb.."\"><button style=\"width:100%; height:100%; background:"..color..";\">"..bstr.."</button></a>"
  return btn
end

wifi.setmode(wifi.STATION)
wifi.sta.config("ItCan'tJustBeOneWord","wifeeye3.14159265")
print(wifi.sta.getip())
led1 = 3
led2 = 4

pin0 = 0
pin1 = 1
pin2 = 2
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.mode(pin0, gpio.OUTPUT)
gpio.mode(pin1, gpio.OUTPUT)
gpio.mode(pin2, gpio.OUTPUT)

srv=net.createServer(net.TCP)
pin0State = true
pin1State = true
pin2State = true
offcolor = "#FF4500"
oncolor =   "#9ACD32"
 if(pin0State)then
        -- this relay is opposite type. 
             gpio.write(pin0, gpio.HIGH);
        else 
             gpio.write(pin0, gpio.LOW);
        end

        if(pin1State)then
             gpio.write(pin1, gpio.HIGH);
        else 
             gpio.write(pin1, gpio.LOW);
        end 

        if(pin2State)then
             gpio.write(pin2, gpio.HIGH);
        else 
             gpio.write(pin2, gpio.LOW);
        end 
srv:listen(80,function(conn)
    
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        if(_GET ~= nil)then
           if(_GET.pin0 ~=nil)then
             if(_GET.pin0 == "ON")then 
               pin0State = true;
             elseif(_GET.pin0 == "OFF")then
               pin0State = false;
             end
           end
           if(_GET.pin1 ~=nil)then
             if(_GET.pin1 == "ON")then 
               pin1State = true;
             elseif(_GET.pin1 == "OFF")then
               pin1State = false;
             end
           end
           if(_GET.pin2 ~=nil)then
             if(_GET.pin2 == "ON")then 
               pin2State = true;
             elseif(_GET.pin2 == "OFF")then
               pin2State = false;
             end
           end
        end 
           
        buf = buf.."<h1> Outlet Controller</h1>";
        --buf = buf.."<p>Options: <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf..[[<table style="width:100%; height:400px">
          <tr>
             ]]; --<button style="width:100%; height:100%; background: #FF4500;" >OFF</button></td><td>Smith</td>
        buf = buf.."<td>"..mkButton(0).."</td><td>"..mkButton(1).."</td>";  
        buf = buf.."</tr><tr><td>always on</td><td>";
        buf = buf..mkButton(2).."</td> </tr></table>";
        buf = buf.."<a href=\"/\"><button>home</button></a>"
        local _on,_off = "",""
        if(pin0State)then
        -- this relay is opposite type. 
             gpio.write(pin0, gpio.HIGH);
        else 
             gpio.write(pin0, gpio.LOW);
        end

        if(pin1State)then
             gpio.write(pin1, gpio.HIGH);
        else 
             gpio.write(pin1, gpio.LOW);
        end 

        if(pin2State)then
             gpio.write(pin2, gpio.HIGH);
        else 
             gpio.write(pin2, gpio.LOW);
        end 
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
