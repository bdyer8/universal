function sectionHistograms( SECTION, COLUMNS)
% sectionHistograms
% SECTION is the out_struct from the MATSTRAT import function.
% 
% COLUMNS is a list of cells that contain strings corresponding to columns
% within your excel sheet that contain words that you wish to evaluate.
% 
% For example, if you want to look at histograms of FACIES, your call will
% be: sectionHistograms( SECTION, {'FACIES'}).  You can evaluate multiple
% columns at once, for example: 
% sectionCrossPlot( SECTION, {'FACIES','FEATURES'}) should provide
% histograms for every identifying word you use in the FEATURES column as well as FACIES.
%
% The code is based on your layer designations for each sample, so double 
% check that you have assigned layers correctly.
%
% Bin size is hard coded in at 50 bins by the 'scale' parameter at the top
% of the code.

tempString=[];
for i=1:1:length(SECTION{1})
    for k=1:1:length(SECTION{1}(i).samples)
        tempString=[tempString fieldnames(SECTION{1}(i).samples(1))];
    end
end
tempList=unique(tempString);

[Selection,ok] = listdlg('ListString',tempList,'ListSize',[200 200],...
    'Name','Select parameter 1',...
    'SelectionMode','single',...
    'ffs',0,...
    'fus',0);

plotOne=tempList(Selection);
plotOne=plotOne{1};

[Selection,ok] = listdlg('ListString',tempList,'ListSize',[200 200],...
    'Name','Select parameter 2',...
    'SelectionMode','single',...
    'ffs',0,...
    'fus',0);

plotTwo=tempList(Selection);
plotTwo=plotTwo{1};


figure('Position',[0 0 800 1000]);
cN=length(COLUMNS);
scale=50; % scale = number of bins over range of data.

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


clear wordMatrix

count=0;
for i=1:length(SECTION{1})
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
            wordMatrix(count,length(SortWords)+1)=SECTION{1}(i).samples(k).(plotOne);
            wordMatrix(count,length(SortWords)+2)=SECTION{1}(i).samples(k).(plotTwo);
            
            
        end
    end
end
tempMatrix=wordMatrix; 


xMin(1)=min(wordMatrix(:,end-1));
xMax(1)=max(wordMatrix(:,end-1));
xBuffer(1)=(xMax(1)-xMin(1))*.1;
xMin(1)=xMin(1)-xBuffer(1);
xMax(1)=xMax(1)+xBuffer(1);

xMin(2)=min(wordMatrix(:,end));
xMax(2)=max(wordMatrix(:,end));
xBuffer(2)=(xMax(2)-xMin(2))*.1;
xMin(2)=xMin(2)-xBuffer(2);
xMax(2)=xMax(2)+xBuffer(2);

subplot(1,2,1)
spacing=1.5;
for j=1:1:size(tempMatrix,2)-2
xint=abs(xMax(1)-xMin(1))/scale;
edges=(xMin(1):xint:xMax(1));
sAll=[];
sAll=tempMatrix((tempMatrix(:,j)>0),end-1);
[n,bin]=histc(sAll,edges);
base=j+(j/spacing);
col=[rand(1,3)];
    if ~(isnan(sAll))
        text((xMin(1)+xMax(1))/2,base-.25,strcat(SortWords(j),', n:',num2str(sum(n)),', '...
            ,'\mu:',num2str(mean(sAll),2),',\sigma^2:',num2str(length(sAll(~isnan(sAll))))),...
        'HorizontalAlign','center')
        if length(sAll)>1
                rectangle('Position',[mean(sAll)-(std(sAll)/2),base-.1,std(sAll),1.2],...
                'FaceColor',[.9 .9 .9],'EdgeColor','none');
        end
        rectangle('Position',[mean(sAll)-(xint/5),base-.1,xint/2.5,1.2],...
                'FaceColor',[.1 .1 .1],'EdgeColor','none');
    else
           text((xMin(1)+xMax(1))/2,base-.25,strcat(SortWords(j),', n:',num2str(length(sAll(~isnan(sAll))))),...
                    'HorizontalAlign','center')
    end
    
    for i=1:1:length(edges)-1    
        if (n(i)>0)
            rectangle('Position',[edges(i),base,edges(i+1)-edges(i),n(i)./max(n)],...
                'FaceColor',col,'EdgeColor',[.3 .3 .3]);
        end
    end
    hold on
    


end

sAll=tempMatrix(:,end-1);
[n,bin]=histc(sAll,edges);
base=j+1+((j+1)/spacing);
col=[rand(1,3)];

        rectangle('Position',[mean(sAll)-(std(sAll)/2),base-.1,std(sAll),1.2],...
                'FaceColor',[.9 .9 .9],'EdgeColor','none');
        rectangle('Position',[mean(sAll)-(xint/5),base-.1,xint/2.5,1.2],...
                'FaceColor',[.1 .1 .1],'EdgeColor','none');
for i=1:1:length(edges)-1    
        if (n(i)>0)
            rectangle('Position',[edges(i),base,edges(i+1)-edges(i),n(i)./max(n)],...
                'FaceColor',col,'EdgeColor',[.3 .3 .3]);
        end
   
end

    hold on
text((xMin(1)+xMax(1))/2,base-.25,strcat('alldata, n:',num2str(sum(n)),', '...
            ,'\mu:',num2str(mean(sAll),2),',\sigma^2:',num2str(std(sAll),2)),...
        'HorizontalAlign','center')
    
  axis([xMin(1) xMax(1) 1.0 1+(j)+((j+1)/spacing)+1.5])
    formatPlot(gca,plotOne,'words','hists');
%
subplot(1,2,2)
for j=1:1:size(tempMatrix,2)-2
xint=abs(xMax(2)-xMin(2))/scale;
edges=(xMin(2):xint:xMax(2));
sAll=tempMatrix((tempMatrix(:,j)>0),end);
[n,bin]=histc(sAll,edges);
base=j+(j/spacing);
col=[rand(1,3)];
    if ~isnan(mean(sAll))
                if length(sAll)>1
                    rectangle('Position',[mean(sAll)-(std(sAll)/2),base-.1,std(sAll),1.2],...
                            'FaceColor',[.9 .9 .9],'EdgeColor','none');
                end
        rectangle('Position',[mean(sAll)-(xint/5),base-.1,(xint/2.5),1.2],...
                'FaceColor',[.1 .1 .1],'EdgeColor','none');
    end

    for i=1:1:length(edges)-1    
        if (n(i)>0)
            rectangle('Position',[edges(i),base,edges(i+1)-edges(i),n(i)./max(n)],...
                'FaceColor',col,'EdgeColor',[.3 .3 .3]);
        end
    end
    hold on

    if ~isnan(mean(sAll))
        text((xMin(2)+xMax(2))/2,base-.25,strcat(SortWords(j),', n:',num2str(sum(n)),', '...
            ,'\mu:',num2str(mean(sAll),2),',\sigma^2:',num2str(std(sAll),2)),...
                    'HorizontalAlign','center')
    else
           text((xMin(2)+xMax(2))/2,base-.25,strcat(SortWords(j),', n:',num2str(sum(n))),...
                    'HorizontalAlign','center')
    end
end

sAll=tempMatrix(:,end);
[n,bin]=histc(sAll,edges);
base=j+1+((j+1)/spacing);
col=[rand(1,3)];
        rectangle('Position',[mean(sAll)-(std(sAll)/2),base-.1,std(sAll),1.2],...
                'FaceColor',[.9 .9 .9],'EdgeColor','none');
        rectangle('Position',[mean(sAll)-(xint/5),base-.1,(xint/2.5),1.2],...
                'FaceColor',[.1 .1 .1],'EdgeColor','none');
for i=1:1:length(edges)-1    
        if (n(i)>0)
            rectangle('Position',[edges(i),base,edges(i+1)-edges(i),n(i)./max(n)],...
                'FaceColor',col,'EdgeColor',[.3 .3 .3]);
        end
end

    hold on
text((xMin(2)+xMax(2))/2,base-.25,strcat('alldata, n:',num2str(sum(n)),', '...
            ,'\mu:',num2str(mean(sAll),2),',\sigma^2:',num2str(std(sAll),2)),...
                    'HorizontalAlign','center')
    
    axis([xMin(2) xMax(2) 1.0 1+(j)+((j+1)/spacing)+1.5])
    formatPlot(gca,plotTwo,'words','hists');
    
   

end

