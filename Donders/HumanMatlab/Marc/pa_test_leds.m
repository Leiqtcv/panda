close all;
clear all
HumanInit
figure;
OK=true;
uicontrol('style','pushbutton','position',[10 10 100 100],'string','Stop Testing','Callback','OK=false;OK')
set(gcf,'position',[360 500 120 120])
set(gcf,'menubar','none','numberTitle','off')

while OK == true
str = sprintf('%d;%d;%d;%d;%d',stimSky,3,5,255,1);
micro_cmd(com,cmdStim,str);
str = sprintf('%d;%d;%d;%d;%d',stimSky,9,5,255,1);
micro_cmd(com,cmdStim,str);
end
str = sprintf('%d;%d;%d;%d;%d',stimSky,3,5,255,0);
micro_cmd(com,cmdStim,str);
str = sprintf('%d;%d;%d;%d;%d',stimSky,9,5,255,0);
micro_cmd(com,cmdStim,str);
% pause(100);
% str = sprintf('%d;%d;%d;%d;%d',stimSky,3,4,255,0);
% micro_cmd(com,cmdStim,str);
% 
close(com)
close all
return
%% test leds
%%%%%%%%%%%%%%%%%%%%%%%%
while OK == true
    for I = 7
        switch I
            case 0
                % no testing
            case 1
                for spoke = 1:12
                    for onoff = [1 0]
                        for ring = 1:7
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
            case 2
                for ring = 1:7
                    for onoff = [1 0]
                        for spoke = 1:12
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
            case 3
                for onoff = [1 0]
                    for spoke = 1:12
                        for ring = 1:7
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
            case 4
                for onoff = [1 0]
                    for ring = 1:7
                        for spoke = 1:12
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
            case 5
                for onoff = [1 0]
                    for ring = 7:-1:1
                        for spoke = 1:12
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,onoff);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
            case 6
                for ring = 1:7
                    for spoke = 1:12
                        str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,1);
                        micro_cmd(com,cmdStim,str);
                    end
                end
                for i_int = 1:24;
                    for spoke = 1:12
                        for ring = 1
                            cint = 20*(spoke-i_int);
                            if cint > 255;
                                cint =cint -255;
                            end
                            str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,cint,1);
                            micro_cmd(com,cmdStim,str);
                        end
                    end
                end
                for ring = 1:7
                    for spoke = 1:12
                        str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
                        micro_cmd(com,cmdStim,str);
                    end
                end
            case 7
                spoke = rand_num([1 12]);
                ring =  rand_num([1 7]);
                str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,255,1);
                micro_cmd(com,cmdStim,str);
                str = sprintf('%d;%d;%d;%d;%d',stimSky,spoke,ring,0,0);
                micro_cmd(com,cmdStim,str);
        end
    end
end
%%
close(com)
close all
