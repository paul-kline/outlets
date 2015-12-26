function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                print(str)
                t[i] = str
                i = i + 1
        end
        return t
end     
function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

function urldecode(url)
  local s = ""
  s, _ = url:gsub("%%(%x%x)", hex_to_char)
  return s
end     
    
     
     
     
     print("Ready to start soft ap AND station");
     local str=wifi.ap.getmac();
     local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
     wifi.setmode(wifi.STATIONAP)
     
     local cfg={}
     cfg.ssid="ESP8266_"..ssidTemp;
     cfg.pwd="12345678"
     wifi.ap.config(cfg)
     cfg={}
     cfg.ip="192.168.0.202";
     cfg.netmask="255.255.255.0";
     cfg.gateway="192.168.0.1";
     wifi.ap.setip(cfg);
     file.open("wifi.lua", "r")
     ssi = file.readline()
     ps  = file.readline()
     file.close()
     print(string.gsub(ssi, "\n","")..string.gsub(ps,"\n",""))
     --wifi.sta.setip({ip="192.168.0.201", netmask="255.255.255.0",gateway="192.168.0.1"})
     wifi.sta.config(string.gsub(ssi, "\n",""),string.gsub(ps,"\n",""))
     wifi.sta.connect()
     
     local cnt = 0
     gpio.mode(0,gpio.OUTPUT);
     tmr.alarm(0, 1000, 1, function() 
         if (wifi.sta.getip() == nil) and (cnt < 20) then 
             print("Trying Connect to Router, Waiting...")
             cnt = cnt + 1 
                  if cnt%2==1 then gpio.write(0,gpio.LOW);
                  else gpio.write(0,gpio.HIGH); end
         else 
             tmr.stop(0);
             print("Soft AP started")
             print("Heep:(bytes)"..node.heap());
             print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());
             if (cnt < 20) then 
               print("Conected to Router\r\nMAC:"..wifi.sta.getmac().."\r\nIP:"..wifi.sta.getip())

               srv=net.createServer(net.TCP)
               srv:listen(80,function(conn)
               conn:on("receive", function(client,request)
                   print("in conn")
                  local buf = "";
                  local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
                  if(method == nil)then
                      _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
                  end
                  
                  print("down here")
                       local buf = "<h1>Success Success Success!!</h1>";
                     
                       client:send(buf);
                       print("just send the buf")
                       client:close();
                       print("closed conn")
                       collectgarbage();
                   


                      end)
                      end)

               else 
                 print("Conected to Router Timeout")
                   
                 srv=net.createServer(net.TCP)
                 srv:listen(80,function(conn)
                 conn:on("receive", function(client,request)
                  local buf = "";
                  local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
                  if(method == nil)then
                      _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
                  end
                  local _GET = {}
                  --print("eifjeifjeifjeifjeifjeifjeifjeifj")
                  --print(vars)
                  if (vars ~= nil)then
                    print("vars are: ".. vars)
                      local t={}
                      t = mysplit(vars, "&")
                      for k,v in pairs(t) do 
                         print(v)
                         k2,v2 = string.match(v, "(%w+)=(.+)&*")
                         print("urldecoded: ".. urldecode(v2))
                         _GET[k2]=urldecode(v2)
                      end
                      
                  end
                  if((_GET ~= nil) and (_GET.ssid ~=nil) and ( _GET.pwd ~=nil) )then
                       file.open("wifi.lua","w")
                       file.writeline(_GET.ssid)
                       file.writeline(_GET.pwd)
                       file.close()
                       print("received ssid: ".._GET.ssid)
                       local buff = "<h1> Wifi Setup</h1>";
                       buff = buff.."<br><h1>Success!</h1><br>If you didn't screw it up, unplug and re-plug in your outlet for your changes to take effect."
                       client:send(buff);
                       client:close();
                       collectgarbage();
                  else 
                       local buf = "<h1> Wifi Setup</h1>";
                       buf = buf..[[<form action="/" method="get">
                           SSID of wifi: <input type="text" name="ssid"><br>
                           password: <input type="password" name="pwd"><br>
                           <input type="submit" value="Submit">
                         </form>]]
                       local _on,_off = "",""
                      
                       client:send(buf);
                       client:close();
                       collectgarbage();
                  end 
    end)
end)
                 
             end
     gpio.write(0,gpio.LOW);
             cnt = nil;cfg=nil;str=nil;ssidTemp=nil;
             collectgarbage()

             
         end 
     end)