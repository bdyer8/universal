%function reducTron(SECTIONS)
SECTIONS=SECTIONS;
% %
% SECTION = 
% 
%     thickness
%     width
%     color
%     sHeight
%     d13c
%     devC
%     d18o
%     devO
%     para
%     age
%     
%how many sections are we going to plot?
noSections=size(SECTIONS,2);


%how many sections have stratigraphic data?
%noSectionsStrat=

noSectionsStrat=2;
%override axes
overMinAge=-303;
overMaxAge=-310;
%generate figure window based on size of plot needed
%each section has padding and width for 1000 tall
stratWidth=50;
padding=25;
isotopeWidth=300;
sumStratWidth=noSectionsStrat*(2*padding+stratWidth);
fullWidth=sumStratWidth+isotopeWidth;
figure('Units','pixels','Position',[0 0 ...
    fullWidth  800]);

SECTIONnames={'Honaker','Raplee'};

%% calculate the reference (age) axis so that everything can be hung from it
%start with max range from any section, throw that up on the left
%maxAge=(-1)*max(max(SECTIONS(1).age));
%minAge=(-1)*min(min(SECTIONS.age));
maxAge=0;
minAge=5*10^9;
for(z=1:1:noSectionsStrat)
    if(max(SECTIONS(z).age(:,2))>maxAge)
        maxAge=max(SECTIONS(z).age(:,2));
    end
    if(min(SECTIONS(z).age(:,2))<minAge)
        minAge=min(SECTIONS(z).age(:,2));
    end
end
maxAge=(-1)*maxAge;
minAge=(-1)*minAge;

%convert thicknesses to ages
% SECTIONS(1).tAge=[];
% for(k=1:1:noSectionsStrat)
%     i=1; j = 1;
%     while(j+1<=length(SECTIONS(k).age(:,1)))    
%         tH=SECTIONS(k).age(j+1,1)-SECTIONS(k).age(j,1);
%         dA=SECTIONS(k).age(j+1,2)-SECTIONS(k).age(j,2);
%         m=(-1)*dA/tH;
%         while ((sum(SECTIONS(k).thickness(1:i))<SECTIONS(k).age(j+1,1))...
%                 & (i<length(SECTIONS(k).thickness)))
%         SECTIONS(k).tAge(i)=SECTIONS(k).thickness(i)*m;
%         i=i+1;
%         end
%         j=j+1;
%     end
% end

%%
T=[];
for k=1:1:noSectionsStrat
    maxAgeSection=(-1)*(max(SECTIONS(k).age(:,2)));
    for i=1:1:length(SECTIONS(k).thickness)
        T(k).x1(i)=SECTIONS(k).age(max(find(SECTIONS(k).age(:,1)<=sum(SECTIONS(k).thickness(1:i-1)))));
        if (sum(SECTIONS(k).thickness(1:i))>=sum(SECTIONS(k).thickness(1:end)))
            T(k).x2(i)=SECTIONS(k).age(end,1);
        elseif (isempty(find(SECTIONS(k).age(:,1)>=sum(SECTIONS(k).thickness(1:i-1)))))
            T(k).x2(i)=SECTIONS(k).age(end,1);
        else
            T(k).x2(i)=SECTIONS(k).age(min(find(SECTIONS(k).age(:,1)>sum(SECTIONS(k).thickness(1:i-1)))));
        end
        
        tH=T(k).x2(i)-T(k).x1(i);
        T(k).a1(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x1(i)),2);
        T(k).a2(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x2(i)),2);
        dA=T(k).a2(i)-T(k).a1(i);
        if (tH==0)
            m=0.001;
        else
            m=(-1)*dA/tH;
        end
        SECTIONS(k).tAge(i)=SECTIONS(k).thickness(i)*m;
    end
end
%



%module to create age model for samples

for k=1:1:noSectionsStrat
    maxAgeSection=(-1)*(max(SECTIONS(k).age(:,2)));
    for i=1:1:length(SECTIONS(k).sHeight)
        T(k).x1(i)=SECTIONS(k).age(max(find(SECTIONS(k).age(:,1)<=SECTIONS(k).sHeight(i))));
        T(k).x2(i)=SECTIONS(k).age(min(find(SECTIONS(k).age(:,1)>=SECTIONS(k).sHeight(i))));
        tH=T(k).x2(i)-T(k).x1(i);
        T(k).a1(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x1(i)),2);
        T(k).a2(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x2(i)),2);
        dA=T(k).a2(i)-T(k).a1(i);
        m=(-1)*dA/tH;
        SECTIONS(k).sAge(i)=(SECTIONS(k).sHeight(i)-T(k).x1(i))*m-T(k).a1(i);
    end
end

%module to create age model for gammaray
% 
% for k=3:5
%     maxAgeSection=(-1)*(max(SECTIONS(k).age(:,2)));
%     for i=1:1:length(SECTIONS(k).gr)
%         if(isempty(min(find(SECTIONS(k).age(:,1)>SECTIONS(k).grH(i)))))
%         T(k).x1(i)=SECTIONS(k).age(end-1,1);
%         T(k).x2(i)=SECTIONS(k).age(end,1);
%         tH=T(k).x2(i)-T(k).x1(i); 
%         else
%         if (isempty(find(SECTIONS(k).age(:,1)<=SECTIONS(k).grH(i))))
%            T(k).x1(i)=SECTIONS(k).age(1,1);
%            T(k).x2(i)=SECTIONS(k).age(2,1);
%            tH=T(k).x2(i)-T(k).x1(i);   
%         else
%             T(k).x1(i)=SECTIONS(k).age(max(find(SECTIONS(k).age(:,1)<=SECTIONS(k).grH(i))));
%             T(k).x2(i)=SECTIONS(k).age(min(find(SECTIONS(k).age(:,1)>SECTIONS(k).grH(i))));
%             tH=T(k).x2(i)-T(k).x1(i);
%         end
%         end
%         T(k).a1(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x1(i)),2);
%         T(k).a2(i)=SECTIONS(k).age(find(SECTIONS(k).age(:,1)==T(k).x2(i)),2);
%         dA=T(k).a2(i)-T(k).a1(i);
%         m=(-1)*dA/tH;
%         SECTIONS(k).grAge(i)=(SECTIONS(k).grH(i)-T(k).x1(i))*m-T(k).a1(i);
%     end
% end

%plot




%%
padding=.05;
axes('Position',[0+padding .0+padding 1-2*padding 1-2*padding]); 
axis off;
rectangle('Position',[-1000 -1000 2000 2000],'FaceColor',[1 1 1])
k=1;
%scale width (aesthetic)
%SECTIONS(k).width=SECTIONS(k).width*.3;
%strat
hold on

for(k=1:1:noSectionsStrat)

    pB=find(~(cellfun(@isempty,SECTIONS(k).para)));
    hold on
    ageBase=(-1)*(max(SECTIONS(k).age(:,2)));
    
axes('Position',[(k-1)*.15+.0+padding .0+padding 1-.6-2*padding 1-2*padding]); 
StratWidth=(k-1)*.15+.0+padding+1-.6-2*padding;
[xp,yp] = shapeStrat(SECTIONS(k).width(1),SECTIONS(k).tAge(1),ageBase);
r=fill(xp,yp,SECTIONS(k).color{1},'edgeco',[.2 .2 .2]);
length(SECTIONS(k).tAge);
for i=2:1:length(SECTIONS(k).tAge)
    sumH = sum(SECTIONS(k).tAge(1:i));
    [xp,yp] = shapeStrat(SECTIONS(k).width(i),SECTIONS(k).tAge(i),ageBase+sum(SECTIONS(k).tAge(1:(i-1))));
    r=fill(xp,yp,SECTIONS(k).color{i},'edgeco',[.2 .2 .2]);  
        axis([0 2.5 maxAge minAge])  
        axis([0 2.5 overMaxAge overMinAge])
        %axis autoxy
        formatPlot(gca,'','','');    
        hold on;
end
     for i=1:1:length(pB)
         line([-100 100],[ageBase+sum(SECTIONS(k).tAge(1:pB(i))) ageBase+sum(SECTIONS(k).tAge(1:pB(i)))],'color',[1 0 0]);
     end

    set(gca,'xtick',[0.5],'XTickLabel',SECTIONnames(k));
    set(gca,'box','on','ytick',[0]);
    axis on;
end

%% isotopes c
colorList = [244/256 179/256 49/256;232/256 30/256 38/256 ; 0 102/256 166/256; 38/256 10/256 14/256;177/256 158/256 64/256];
axes('Position',[(noSectionsStrat)*.15+.0+padding .0+padding 1-(noSectionsStrat)*.15-2*padding 1-2*padding]);   

for j=1:1:noSectionsStrat
    hold on;
    nonZero=~(SECTIONS(j).d13c==0);
    if (j==2)
        z=plot(SECTIONS(j).d13c(nonZero),SECTIONS(j).sAge(nonZero),'go');
    else
        z=plot(SECTIONS(j).d13c(nonZero),SECTIONS(j).sAge(nonZero),'gs');
    end
    %set(gca,'YColor',[1 1 1]);
    set(z,'Color',[colorList(j,1) colorList(j,2) colorList(j,3)],'MarkerFaceColor',[colorList(j,1) colorList(j,2) colorList(j,3)],'MarkerSize',7,'MarkerEdgeColor',[.2 .2 .2]);
end
axis([-10 10 maxAge minAge])
axis([-10 10 overMaxAge overMinAge])
set(gca,'YAxisLocation','right','XGrid','on','XAxisLocation','bottom','YGrid','on');
         set(gca,'box','off','xtick',[-10:2:10]);
         xlabel('\delta^{13}C');
         %set(gca,'box','off','ytick',[-27.64:1:-17.64]);
         set(gca,'box','off','ytick',[-308.5 -307.66 -307.26]);
%        legend(SECTIONnames)  
 
axis on


% 
% % GR on 3
% 
% for k=[3:5]
%     axes('Position',[(k-1)*.15+.0+padding-.05 .0+padding 1-.85-2*padding 1-2*padding]); 
%     hold on;
%     z=plot((-1)*SECTIONS(k).gr,SECTIONS(k).grAge);
%     axis([-150 0 maxAge minAge])
%     axis([-150 0 overMaxAge overMinAge])
% 
%     set(gca,'xtick',[0.5],'XTickLabel',SECTIONnames(k));
%     set(gca,'box','on','ytick',[0]);
%     axis off
% 
% 
% end

%% isotopes o
% colorList = [244/256 179/256 49/256;232/256 30/256 38/256 ; 0 102/256 166/256; 38/256 10/256 14/256;177/256 158/256 64/256];
% axes('Position',[(noSectionsStrat)*.15+.0+padding .0+padding 1-(noSectionsStrat)*.15-2*padding 1-2*padding]);   
% for j=1:1:noSectionsStrat
%     hold on
%     nonZero=~(SECTIONS(j).d18o==0);
%     if (j==2)
%         z=plot(SECTIONS(j).d18o(nonZero),SECTIONS(j).sAge(nonZero),'go');
%     else
%         z=plot(SECTIONS(j).d18o(nonZero),SECTIONS(j).sAge(nonZero),'gs');
%     end
%     %set(gca,'YColor',[1 1 1]);
%     set(z,'Color',[colorList(j,1) colorList(j,2) colorList(j,3)],'MarkerFaceColor',[colorList(j,1) colorList(j,2) colorList(j,3)],'MarkerSize',7,'MarkerEdgeColor',[.2 .2 .2]);
% end
% axis([-10 10 maxAge minAge])
% axis([-10 10 overMaxAge overMinAge])
% set(gca,'YAxisLocation','right','XGrid','on','XAxisLocation','bottom','YGrid','on');
%          set(gca,'box','off','xtick',[-10:2:10]);
%          xlabel('\delta^{18}O');
%          %set(gca,'box','off','ytick',[-27.64:1:-17.64]);
%          set(gca,'box','off','ytick',[-308.5 -307.66 -307.26]);
%        legend(SECTIONnames)  
%  
% axis on


%% plot for sed rate stretch
figure

% dy=SECTIONS(1).age(1,1)-SECTIONS(1).age(2,1)
% dt=SECTIONS(1).age(1,2)-SECTIONS(1).age(2,2)
% m=abs(dy/dt);
% t=linspace(SECTIONS(1).age(1,2),SECTIONS(1).age(2,2),100);
% t=abs(t-SECTIONS(1).age(1,2));
% y=m*t;
% plot(t-SECTIONS(1).age(1,2),m*t)
% b=y(end);
% hold on
% dy=SECTIONS(1).age(2,1)-SECTIONS(1).age(3,1)
% dt=SECTIONS(1).age(2,2)-SECTIONS(1).age(3,2)
% m=abs(dy/dt);
% t=linspace(SECTIONS(1).age(2,2),SECTIONS(1).age(3,2),100);
% t=abs(t-SECTIONS(1).age(2,2));
% y=m*t+b;
% plot(t-SECTIONS(2).age(1,2),y)
% b=y(end);
b=0;
slope = [];
for i=1:1:6
    hold on
dy=SECTIONS(1).age(i,1)-SECTIONS(1).age(i+1,1)
dt=SECTIONS(1).age(i,2)-SECTIONS(1).age(i+1,2)
m=abs(dy/dt);
slope(1).m(i)=m;
t=linspace(SECTIONS(1).age(i,2),SECTIONS(1).age(i+1,2),100);
t=abs(t-SECTIONS(1).age(i,2));
y=m*t+b;
plot(t-SECTIONS(1).age(i,2),y)
b=y(end);
end

hold on
b=0;
for i=1:1:3
    hold on
dy=SECTIONS(2).age(i,1)-SECTIONS(2).age(i+1,1)
dt=SECTIONS(2).age(i,2)-SECTIONS(2).age(i+1,2)
m=abs(dy/dt);
slope(2).m(i)=m;
t=linspace(SECTIONS(2).age(i,2),SECTIONS(2).age(i+1,2),100);
t=abs(t-SECTIONS(2).age(i,2));
y=m*t+b;
plot(t-SECTIONS(2).age(i,2),y,'r')
b=y(end);
end

plot((-1)*SECTIONS(1).age(:,2),SECTIONS(1).age(:,1),'.')
plot((-1)*SECTIONS(2).age(:,2),SECTIONS(2).age(:,1),'r.')

figure
plot(slope(1).m,slope(2).m)
