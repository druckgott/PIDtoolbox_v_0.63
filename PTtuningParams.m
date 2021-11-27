%% PTtuningParams - scripts for plotting tune-related parameters

% ----------------------------------------------------------------------------------
% "THE BEER-WARE LICENSE" (Revision 42):
% <brian.white@queensu.ca> wrote this file. As long as you retain this notice you
% can do whatever you want with this stuff. If we meet some day, and you think
% this stuff is worth it, you can buy me a beer in return. -Brian White
% ----------------------------------------------------------------------------------
    
PTtunefig=figure(4);

prop_max_screen=(max([PTtunefig.Position(3) PTtunefig.Position(4)]));
fontsz=(screensz_multiplier*prop_max_screen);

f = fields(guiHandlesTune);
for i = 1 : size(f,1)
    eval(['guiHandlesTune.' f{i} '.FontSize=fontsz;']);
end


%% step resp computed directly from set point and gyro
ylab={'R';'P';'Y'};
ylab2={'roll';'pitch';'yaw'};

axesOptions = {[1 2 3]; [1 2]; 1; 2; 3};

%%%%%%%%%%%%% step resp %%%%%%%%%%%%%
figure(PTtunefig)

ymax = str2num(guiHandlesTune.maxYStepInput.String);
hwarn=[];
if ~guiHandlesTune.clearPlots.Value
    cnt = 0;
    set(PTtunefig, 'pointer', 'watch')
    pause(.05);
    
    for f = guiHandlesTune.fileListWindowStep.Value   
        fcntSR = fcntSR + 1;   
        if fcntSR <= 10
            for p = axesOptions{guiHandlesTune.chooseaxis.Value}   
                cnt = cnt + 1;
                try 
                    if ~updateStep   
                        clear H G L
                        eval(['H = T{f}.setpoint_' int2str(p-1) '_(tIND{f});'])
                        eval(['G = T{f}.gyroADC_' int2str(p-1) '_(tIND{f});'])
                        [stepresp_A{p} tA] = PTstepcalc(H, G, A_lograte(f), guiHandlesTune.Ycorrection.Value, guiHandlesTune.smoothFactor_select.Value);
                     %   xcorrLag(p) = finddelay(H, G) * A_lograte(f);
                    end
                catch
                    stepresp_A{p}=[];
                end

                h1=subplot('position',posInfo.TparamsPos(p,:)); 
                hold on

                 if size(stepresp_A{p},1)>1
                    m=nanmean(stepresp_A{p});

%                     hold on
%                     h1=plot(tA,stepresp_A{p}); set(h1,'color',[.7 .7 .7])
                    
                    h1=plot(tA,m);         
                    set(h1, 'color',[multiLineCols(fcntSR,:)],'linewidth', guiHandles.linewidth.Value+1);
                    latencyHalfHeight(p, fcntSR) = (find(m>.5,1) / A_lograte(f)) - 1;
                  %  latencyHalfHeight = xcorrLag(p);
                    peakresp(p, fcntSR)=max(m);
                    peaktime(p, fcntSR)=find(m == max(m)) / A_lograte(f);
                    
                    eval(['PID=' ylab2{p} 'PIDF{f};'])  
                    if cnt <= 3, h=text(995, ymax, ['    P, I, D, Dm, F']);set(h,'fontsize',fontsz,'fontweight','bold'); end
                     h=text(995, ymax-(fcntSR*(ymax*.09)), [int2str(fcntSR) ') ' PID '  (n=' int2str(size(stepresp_A{p},1)) ')']);set(h,'fontsize',fontsz);  %  |  Peak = ' num2str(peakresp(fcntSR)) ', Peak Time = ' num2str(peaktime) 'ms, Latency = ' num2str(latencyHalfHeight(fcntSR)) 'ms']);set(h,'fontsize',fontsz);  
                     set(h, 'Color',[multiLineCols(fcntSR,:)],'fontweight','bold')
                     set(h,'fontsize',fontsz)
                 else
                     peakresp(p, fcntSR) = nan;
                     peaktime(p, fcntSR) = nan;
                    latencyHalfHeight(p, fcntSR) = nan;
                    if cnt <= 3, h=text(995, ymax, ['    P, I, D, Dm, F']);set(h,'fontsize',fontsz,'fontweight','bold'); end
                     h=text(995, ymax-(fcntSR*(ymax*.09)), [int2str(fcntSR) ') insufficient data']); 
                     set(h,'Color',[multiLineCols(fcntSR,:)],'fontsize',fontsz, 'fontweight','bold')
                end

                set(gca,'fontsize',fontsz,'xminortick','on','yminortick','on','xtick',[0 100 200 300 400 500],'xticklabel',{'0' '100' '200' '300' '400' '500'},'ytick',[0 .25 .5 .75 1 1.25 1.5 1.75 2],'tickdir','out'); 

                box off
                if cnt <= 3, h=ylabel(['Response '], 'fontweight','bold'); end
                
                xlabel('Time (ms)', 'fontweight','bold');
                if p==1, title('Step Response Functions');end
                if cnt <= 3,
                    h=text(5,ymax-0.1,ylab2{p}); 
                    set(h,'fontsize',fontsz,'fontweight','bold')
                end
                h=plot([0 500],[1 1],'k--');
                set(h,'linewidth',.5)
                axis([0 500 0 ymax])
                grid on
                
                h2=subplot('position',posInfo.TparamsPos(p+3,:)); 
                h=plot(fcntSR, peakresp(p, fcntSR),'sk'); 
                set(h,'Markersize',14, 'MarkerFaceColor', [multiLineCols(fcntSR,:)])
                set(gca,'fontsize',fontsz, 'ylim',[0.8 ymax],'ytick',[0.8:.1:ymax],'xlim',[0.5 fcntSR+0.5],'xtick',[1:fcntSR])
                ylabel(['Peak'], 'fontweight','bold');
                xlabel('Test', 'fontweight','bold'); 
                hold on
                grid on
                plot([0 10],[1 1],'--k')
                
                h2=subplot('position',posInfo.TparamsPos(p+6,:)); 
                h=plot(fcntSR, latencyHalfHeight(p, fcntSR),'sk'); 
                set(h,'Markersize',14, 'MarkerFaceColor', [multiLineCols(fcntSR,:)])
                set(gca,'fontsize',fontsz,'xtick',[1:fcntSR],'xlim',[0.5 fcntSR+0.5])
                ylabel(['Latency (ms)'], 'fontweight','bold');
                xlabel('Test', 'fontweight','bold'); 
                hold on
                grid on
                
                h2=subplot('position',posInfo.TparamsPos(p+9,:)); 
                h=plot(fcntSR, peaktime(p, fcntSR),'sk'); 
                set(h,'Markersize',14, 'MarkerFaceColor', [multiLineCols(fcntSR,:)])
                set(gca,'fontsize',fontsz,'xtick',[1:fcntSR],'xlim',[0.5 fcntSR+0.5])
                ylabel(['Peak time (ms)'], 'fontweight','bold');
                xlabel('Test', 'fontweight','bold'); 
                hold on
                grid on

            end    
        elseif fcntSR == 11
            warndlg('10 files maximum. Click reset.');
        end 
    end
   set(PTtunefig, 'pointer', 'arrow')

    updateStep=0;
else
    for p = 1 : 3
        delete(subplot('position',posInfo.TparamsPos(p,:)))
        delete(subplot('position',posInfo.TparamsPos(p+3,:)))
        delete(subplot('position',posInfo.TparamsPos(p+6,:)))
        delete(subplot('position',posInfo.TparamsPos(p+9,:)))
        peaktime = [];
        peakresp = [];
        latencyHalfHeight = [];
    end
end
    




