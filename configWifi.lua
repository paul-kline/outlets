wifi.setmode(wifi.SOFTAP)
      local str=wifi.ap.getmac();
      local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
    
                 local cfg={}
                 cfg.ssid="ESP8266_"..ssidTemp;
                 cfg.pwd="12345678"
                 cfg.ip="192.168.0.202";
                 cfg.netmask="255.255.255.0";
                 cfg.gateway="192.168.0.1";
                 wifi.ap.setip(cfg); 
                 wifi.setmode(wifi.SOFTAP) 
                 srv=net.createServer(net.TCP)
                 print("here 2")
                 srv:listen(80,function(conn)
                 conn:on("receive", function(client,request)
                 print("in conn on receive")
                  local buf = "";
                  local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
                  if(method == nil)then
                      _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
                  end
                  local _GET = {}
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
                  print("web page request")
                  if((_GET ~= nil) and (_GET.ssid ~=nil) and ( _GET.pwd ~=nil) and ( _GET.ip ~=nil))then
                       file.open("wifi.lua","w")
                         file.writeline(_GET.ssid)
                         file.writeline(_GET.pwd)
                         file.writeline(_GET.ip)
                         file.flush()
                       file.close()
                       file.open("shouldconfig.lua","w")
                         file.writeline("nope")
                         file.flush()
                       file.close()
                       print("received ssid: ".._GET.ssid)
                       local buff = [[<!DOCTYPE html> <html> <body> <h1> Wifi Setup</h1>
                         <br><h1>Success!</h1><br>If you didn't screw it up, unplug the Arduino and plug it back in for your changes to take effect.
                         <br><br><a href="/"><button>Re-Config</button></a></body></html>]]
                       client:send(buff);
                       collectgarbage();
                  else 
                      file.open("wifi.lua","r")
                        local ssi = file.readline()
                        local ps  = file.readline()
                        local myIP = file.readline()
                      file.close()
                      if(ssi == nil) then ssi = "EMPTY" end
                      if(ps == nil) then ps = "EMPTY" end
                      if(myIP == nil) then myIP = "EMPTY" end
                      print("making web page!!")
                      local buf = [[<!DOCTYPE html> <html> <head><title>Outlet Config</title></head>  <body><h1> Wifi Setup</h1><div><form action="/" method="get">SSID of wifi: <input type="text" name="ssid"]]
                      buf = buf.."value=\""..ssi.."\">(Case sensitive!)<br>"
                      buf = buf..[[<br>password: <input type="text" name="pwd"]].."value=\""..ps.."\"><br><br>"
                      buf = buf..[[IP: <input type="text" name="ip"]].."value=\""..myIP.."\">"                  
                     buf = buf.."MAC: "..wifi.ap.getmac()..[[<br><input type="submit" value="Submit">
                                </form>See http://pauliankline.com/outlet/OutletTroubleshooting.html for help on setting these!</body></html>]]
                      local _on,_off = "",""
                      
                      client:send(buf);
                      cfg = nil ; ssi =nil; ps=nil;myIP=nil;
                       collectgarbage();
                  end 
    end)
    conn:on("sent",function(conn) conn:close() end)
    end)



