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
  s = string.gsub(s,"+", " ")
  return s
end     
    

     file.open("shouldconfig.lua", "r")
       local contents = file.readline()  
     file.close()
     file.open("shouldconfig.lua","w")
       file.writeline("y")
       file.flush()
     file.close()
     if(contents == nil or string.len(contents) < 3) then
          print("bout to do configWifi.lua")
          dofile("configWifi.lua")
    
     else
          file.open("wifi.lua", "r")
            local ssipre = file.readline()
            local pspre = file.readline()
            myIPpre = file.readline()
          file.close()
          if (ssipre == nil or pspre == nil or myIPpre == nil or string.len(pspre) < 9) then
               print("nil stuff or password not long enough. configing")
               collectgarbage()
               dofile("configWifi.lua")
          else 
               local ssi = string.gsub(ssipre,"\n","")
               local ps  = string.gsub(pspre,"\n","")
               myIP = string.gsub(myIPpre,"\n","")
               print("myIP after gsub: "..myIP)
               tmr.alarm(1,2200,0,function()
                 file.open("shouldconfig.lua","w")
                 file.writeline("nope")
                 file.flush()
                 file.close()
                 print("config false now!!")
               end)
               print("Ready to start soft ap AND station");
               wifi.setmode(wifi.STATION)
               print(string.gsub(ssi, "\n","")..string.gsub(ps,"\n",""))
               --wifi.sta.setip({ip=string.gsub(myIP, "\n",""), netmask=string.gsub(mynetmask, "\n",""),gateway=string.gsub(mygateway, "\n","")})
               wifi.sta.config(ssi,ps)
               wifi.sta.connect()
               
               local cnt = 0;
               print("count orig: " ..cnt)
               gpio.mode(0,gpio.OUTPUT);
               tmr.alarm(0, 1000, 1, function() 
                   if (cnt == nil) then cnt = 1 end
                   if (wifi.sta.getip() == nil) and (cnt < 20) then 
                       print("Trying Connect to Router, Waiting...")
                       cnt = cnt + 1 
                            if cnt%2==1 then gpio.write(0,gpio.LOW);
                            else gpio.write(0,gpio.HIGH); end
                   else 
                       tmr.stop(0);
                       if(myIP == nil) then 
                         file.open("wifi.lua")
                          file.readline()
                          file.readline()
                          myIP = string.gsub(file.readline(),"\n","")
                         file.close()
                       end
                         print("myIP was null, read file again and set to: "..myIP)
                       print("setting my ip to: "..myIP)
                       wifi.sta.setip({ip=myIP})
                      print("cnt: "..cnt)
                       if (cnt < 20) then 
                         print("Conected to Router\r\nMAC:"..wifi.sta.getmac().."\r\nIP:"..wifi.sta.getip())
                         dofile("OutletController.lua")
                       else 
                           collectgarbage();
                           print("Conected to Router Timeout");
                           dofile("configWifi.lua");
                       end                       
                   end
                   end)            
              gpio.write(0,gpio.LOW);
             cnt = nil;cfg=nil;str=nil;ssidTemp=nil;
             ssi = nil; ssipre = nil
               pspre = nil; ps = nil
               myIPpre = nil; myIP = nil
             collectgarbage()
           end
          end
        
