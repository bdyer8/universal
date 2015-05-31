function sectionCrossPlot( SECTION, COLUMNS)
% sectionCrossPlot
% SECTION is the out_struct from the MATSTRAT import function.
% 
% COLUMNS is a list of cells that contain strings corresponding to columns
% within your excel sheet that contain words that you wish to evaluate.
% 
% For example, if you want to look at cross plots of FACIES, your call will
% be: sectionCrossPlot( SECTION, {'FACIES'}).  You can evaluate multiple
% columns at once, for example: 
% sectionCrossPlot( SECTION, {'FACIES','FEATURES'}) should provide
% crossplots for every identifying word you use in the FEATURES column as well as FACIES.
%
% Scales are hard coded in at the top.  Code assumes that you carbon
% isotopic data is in a column titled d13c and your oxygen isotopic data is
% in a column titled d18o.  Additionally, the code is based on your layer
% designations for each sample, so double check that you have assigned
% layers correctly.


tempString=[];
for i=1:1:length(SECTION{1})
    for k=1:1:length(SECTION{1}(i).samples)
        tempString=[tempString fieldnames(SECTION{1}(i).samples(1))];
    end
end
tempList=unique(tempString);

[Selection,ok] = listdlg('ListString',tempList,'ListSize',[200 200],...
    'Name','Select x-axis',...
    'SelectionMode','single',...
    'ffs',0,...
    'fus',0);

xAxis=tempList(Selection);
xAxis=xAxis{1};

[Selection,ok] = listdlg('ListString',tempList,'ListSize',[200 200],...
    'Name','Select y-axis',...
    'SelectionMode','single',...
    'ffs',0,...
    'fus',0);

yAxis=tempList(Selection);
yAxis=yAxis{1};


cN=length(COLUMNS);
box=1;

figure('Position',[0 0 800 800],'Name',strcat('xAxis:',xAxis,' - yAxis:',yAxis));


temp=[];
for i=1:1:size(SECTION{1},2)

    temp = [temp arrayfun(@(x) SECTION{1}(i).(COLUMNS{x}),1:cN)];
end
    temp=temp';
for i=1:1:length(temp)
    if ~strcmp(temp{i},{''})
        temp(i)=strcat(temp(i),{' '});
    end
end

Paragraph=cell2mat(temp');

AlphabetFlag=Paragraph>=97 & Paragraph<=122;  % finding alphabets

DelimFlag=find(AlphabetFlag==0); % considering non-alphabets delimiters
WordLength=[DelimFlag(1), diff(DelimFlag)];
Paragraph(DelimFlag)=[]; % setting delimiters to white space
Words=mat2cell(Paragraph, 1, WordLength(:)-1); % cut the paragraph into words

[SortWords, Ia, Ic]=unique(Words);

Bincounts = histc(Ic,1:size(Ia, 1));%finding their occurence
[SortBincounts, IndBincounts]=sort(Bincounts, 'descend');% finding their frequency

FreqWords=SortWords(IndBincounts); % sorting words according to their frequency
FreqWords(1)=[];SortBincounts(1)=[]; % dealing with remaining white space

Freq=SortBincounts/sum(SortBincounts)*100; % frequency percentage

% %% plot
% NMostCommon=16;
% disp(Freq(1:NMostCommon))
% pie([Freq(1:NMostCommon); 100-sum(Freq(1:NMostCommon))], [FreqWords(1:NMostCommon), {'other words'}]);


clear wordMatrix

count=0;
for i=1:length(SECTION{1})
%     d13c=arrayfun(@(x) x.d13c,SECTION{1}(i).samples);
%     height=arrayfun(@(x) x.height,SECTION{1}(i).samples);
    if ~isempty(SECTION{1}(i).samples)
        temp = [arrayfun(@(x) SECTION{1}(i).(COLUMNS{x}),1:cN)];
        for h=1:1:length(temp)
            if ~strcmp(temp{h},{''})
                temp(h)=strcat(temp(h),{' '});
            end
        end
        
        temp=cell2mat(temp);
        
        
        for k=1:length(SECTION{1}(i).samples)
            count=count+1;
            sampleStringArray(count)={temp};
            for j=1:1:length(SortWords)
                wordMatrix(count,j)=double(~isempty(strfind(temp,SortWords{j}))); %ignoring empty set j=1
            end
            wordMatrix(count,length(SortWords)+1)=SECTION{1}(i).samples(k).(yAxis);
            wordMatrix(count,length(SortWords)+2)=SECTION{1}(i).samples(k).(xAxis);
            
            
        end
    end
end
tempMatrix=wordMatrix; 
n=length(SortWords);


while(true)
   if (box^2>=n)
       break
   else
       box=box+1;
   end
end

count=[];
row=1;
buffer=.03;
xMin=min(wordMatrix(:,end));
xMax=max(wordMatrix(:,end));
yMin=min(wordMatrix(:,end-1));
yMax=max(wordMatrix(:,end-1));
xBuffer=(xMax-xMin)*.1;
yBuffer=(yMax-yMin)*.1;
xMin=xMin-xBuffer;
xMax=xMax+xBuffer;
yMin=yMin-yBuffer;
yMax=yMax+yBuffer;

for(i=1:1:n)
    column=mod(i,box)-1;
    mod(i,box);
    if (mod(i,box)==0)
            column=box-1;
        end
    h(i)=subplot('Position',[0+column*(1/box)+buffer/2 1+(buffer)-(buffer/4)-row*(1/box) (1/box)-buffer (1/box)-buffer]);
id=i;
plot(tempMatrix((tempMatrix(:,id)>0),end),tempMatrix((tempMatrix(:,id)>0),end-1),'.',...
    'Color',rand(3,1),'MarkerSize',10);
    hold on
    text((xMin+xMax)/2,yMin,SortWords(i),'HorizontalAlign','center','VerticalAlign','bottom',...
        'FontWeight','bold','FontSize',13);
formatPlot(gca,'','','');
grid on


axis([xMin xMax yMin yMax]);
    if (mod(i,box)==0)
            row=row+1;
        end
end

end

