SECTION=out_struct;
bot=0;
top=100;
xAxisMinC=-5;
xAxisMaxC=6;
xAxisMinO=-10;
xAxisMaxO=-0;
floor=bot;
ciel=top;

isotope1='d13c';
isotope2='d18o';

%apply PARAMETERS to SECTION
for i=1:length(SECTION{1})
    fIdx=find(strcmp([PARS.FACIES.id(:)], SECTION{1}(i).FACIES));
    lIdx=find(strcmp([PARS.LITH.id(:)], SECTION{1}(i).LITHOLOGY));
    rIdx=find(strcmp([PARS.COLOR.id(:)], SECTION{1}(i).COLOR));
    SECTION{1}(i).rockColor=PARS.COLOR.color(rIdx);
    SECTION{1}(i).lithColor=PARS.LITH.color(lIdx);
    SECTION{1}(i).faciesColor=PARS.FACIES.color(fIdx);
    SECTION{1}(i).width=PARS.FACIES.width(fIdx);
end

figure('Units','pixels','Position',[0 0 400 1000],'Name','Isotopes');
padding=.05;
axes('Position',[padding .0+padding 1-2*padding 1-2*padding]);       
rectangle('Position',[-1000 -1000 2000 2000],'FaceColor',[1 1 1]);
axis off

% % this part for plotting parasequence lines
% for i=1:1:length(SECTION{1})
%     if (strcmp(SECTION{1}(i).TOP,'p') | strcmp(SECTION{1}(i).TOP,'p?'))
%         line([-10 10],[SECTION{1}(i).position SECTION{1}(i).position])
%     end
% end
%     
    
% ISOTOPES (PLOT 2)
axes('Position',[.3+padding 0+padding .65-.2-2*padding 1-2*padding],'YColor',[1 1 1]);

dataPlot=[];
for i=1:length(SECTION{1})
                hold on
    d13c=arrayfun(@(x) x.(isotope1),SECTION{1}(i).samples);
    dataPlot=[dataPlot d13c];
    height=arrayfun(@(x) x.height,SECTION{1}(i).samples);
    if ~isempty(SECTION{1}(i).samples)
        for k=1:length(SECTION{1}(i).samples)
            z=plot(d13c(k),height(k),'gs');
                switch SECTION{1}(i).samples(k).DIAGENESIS{1}
                    case 'm'
                        set(z,'Color',[.2 .4 .2],'MarkerFaceColor',[.8 .3 .3],'MarkerSize',6);
                    case 'b'
                        set(z,'Color',[.2 .4 .2],'MarkerFaceColor',[.2 .2 .2],'MarkerSize',6);
                    otherwise
                        set(z,'Color',[.2 .4 .2],'MarkerFaceColor',[.6 1 .6],'MarkerSize',6);
                end
        end
    end
end

xAxisMinC=min(dataPlot)-(max(dataPlot)-min(dataPlot))*.1;
xAxisMaxC=max(dataPlot)+(max(dataPlot)-min(dataPlot))*.1;
axis([xAxisMinC xAxisMaxC floor ciel]);
set(gca,'Color','none');
set(gca,'YAxisLocation','right','XGrid','on','XAxisLocation','bottom','YGrid','off');
set(gca,'box','off','ytick',[0:50:400],'xtick',[round(xAxisMinC):round((xAxisMaxC-xAxisMinC)/10):round(xAxisMaxC)]);
xlabel('\delta^{13}C');
ylabel('Height (m)');

%OXYGEN ISOTOPES (PLOT 3)
axes('Position',[.70+padding .0+padding 1-.7-2*padding 1-2*padding]);       

dataPlot=[];
for i=1:length(SECTION{1})
    hold on;
    d18o=arrayfun(@(x) x.(isotope2),SECTION{1}(i).samples);
    dataPlot=[dataPlot d18o];
    height=arrayfun(@(x) x.height,SECTION{1}(i).samples);
if ~isempty(SECTION{1}(i).samples)
        for k=1:length(SECTION{1}(i).samples)
            z=plot(d18o(k),height(k),'gs');
                switch SECTION{1}(i).samples(k).DIAGENESIS{1}
                    case 'm'
                        set(z,'Color',[.2 .2 .4],'MarkerFaceColor',[.8 .3 .3],'MarkerSize',6);
                    case 'b'
                        set(z,'Color',[.2 .2 .4],'MarkerFaceColor',[.2 .2 .2],'MarkerSize',6);
                    otherwise
                        set(z,'Color',[.2 .2 .4],'MarkerFaceColor',[.6 .6 1],'MarkerSize',6);
                end
        end
    end
end

xAxisMinO=min(dataPlot)-(max(dataPlot)-min(dataPlot))*.1;
xAxisMaxO=max(dataPlot)+(max(dataPlot)-min(dataPlot))*.1;
axis([xAxisMinO xAxisMaxO floor ciel]);
set(gca,'Color','none');
set(gca,'YAxisLocation','left','XGrid','on','XAxisLocation','bottom','YGrid','off');
set(gca,'box','off','ytick',[0:5:400],'xtick',[round(xAxisMinO):round((xAxisMaxO-xAxisMinO)/5):round(xAxisMaxO)]);
xlabel('\delta^{18}O');
ylabel('Height (m)');

%SECTION (PLOT 1)


axes('Position',[0+padding .0+padding 1-2*padding 1-2*padding]); 
axis off;



for i=1:length(SECTION{1})
    thickness=SECTION{1}(i).thickness;
    width=SECTION{1}(i).width;
    rockColor=SECTION{1}(i).rockColor;
    faciesColor=SECTION{1}(i).faciesColor;
    lithColor=SECTION{1}(i).lithColor;
    grade=SECTION{1}(i).GRADE{1};
    position=SECTION{1}(i).position;
    hold on
    
    rLith=fill([-.10 0 0 -.10],[position-thickness position-thickness position position],[str2num(rockColor{1}{1}) str2num(rockColor{1}{2}) str2num(rockColor{1}{3})]/255,'edgeco','none');
    rColor=fill([-.2 -.1 -.1 -.2],[position-thickness position-thickness position position],[str2num(lithColor{1}{1}) str2num(lithColor{1}{2}) str2num(lithColor{1}{3})]/255,'edgeco','none');
    [xp,yp] = shapeStrat3(width,thickness,position-thickness,grade);
    r=fill(xp,yp,[str2num(faciesColor{1}{1}) str2num(faciesColor{1}{2}) str2num(faciesColor{1}{3})]/255,'edgeco',[.1 .1 .1]);
end

axis([-.2 5 floor ciel]);

