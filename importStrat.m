
%% IMPORT
[filename, pathname, filterindex] = uigetfile('*.csv','Import Section Data');

fid = fopen(strcat(pathname,filename),'r');
if fid == -1
    error('File not found')
end
headerLines=0;
file_delim=',';
while true
    header_str = fgetl(fid)
    header_cell = textscan(header_str,'%q','delimiter',file_delim);
    header_cell = header_cell{1};
    headerLines = headerLines +1;
if regexp(header_str,'THICKNESS')
    break; 
end

end


isSamp = false;
snum = 0;

for k = 1:length(header_cell)
    cur_hdr = header_cell{k};
    cur_hdr = strrep(cur_hdr,'"','');
    cur_hdr = strrep(cur_hdr,',','_');
    cur_hdr = strrep(cur_hdr,'#','_no');
    cur_hdr = genvarname(cur_hdr);
    
    if strcmpi(cur_hdr, 'sample')
        snum = k;
        isSamp = true;
    end
end

if (snum==0) snum = length(header_cell); end

%data = textscan(fid,'%s',length(header_cell),'delimiter',file_delim);
data=cell(1,length(header_cell));
datatemp=fgetl(fid);
datatemp=regexp(datatemp,',','split');
data(1:length(datatemp))=datatemp;
%data = data{1};


format_str = [];


for i = 1:length(data)   
%    if (~isnan(str2double(data{i})) && i>snum && snum>0 ) || i == 1
    if (~isnan(str2double(data{i})))
        col_format = '%f ';
    else
        col_format = '%q ';
    end
    format_str = [format_str col_format];
end

frewind(fid);
data = textscan(fid,format_str,'delimiter',file_delim, 'HeaderLines', headerLines);
fclose(fid);


% Loop through each column of data and create a field in a structure for
% each column of data.  The fieldnames are based on the headers in the file
p = 0;


for i = 1:snum-1
    cur_hdr = header_cell{i};
    cur_hdr = strrep(cur_hdr,'"','');
    cur_hdr = strrep(cur_hdr,',','_');
    cur_hdr = strrep(cur_hdr,'#','_no');
    cur_hdr = genvarname(cur_hdr);
    
    if regexpi(cur_hdr, 'thickness')
        thickness = data{i};
    else
        lay.data{i-p} = data{i};
        lay.props{i-p} = cur_hdr;
        p = p-1;

    end
p = p + 1;

end

p = snum - 1;

name = [];
isotope.props = {};
l = [];
if isSamp
for i = snum:length(data)
    cur_hdr = header_cell{i};
    cur_hdr = strrep(cur_hdr,'"','');
    cur_hdr = strrep(cur_hdr,',','_');
    cur_hdr = strrep(cur_hdr,'#','_no');
    cur_hdr = genvarname(cur_hdr);
    
    if strcmpi(cur_hdr, 'sample')
        name = data{i};
    elseif strcmpi(cur_hdr, 'layer')
        l =  data{i};
    elseif strcmpi(cur_hdr, 'samp_height')
        sh = data{i};
    else
        isotope.data{i-p} = data{i};
        isotope.props{i-p} = cur_hdr;
        p = p-1;
    end
        
p = p + 1;

end

end
        
 strat = layerD.empty();
 
 k = isnan(thickness);
 thickness = thickness(~k);
 for i = 1:length(lay.data)
%       if length(lay.data{i}) < length(k)
%          lay.data{i}(length(lay.data{i}):length(k)-1) = [];
%       end
%       if length(lay.data{i}) < length(thickness)
%           
%length(lay.data{i})     
lay.data{i} = lay.data{i}(~k);
 end
 

%dir = SectionPrefsGUI;
dir='Section';
if strcmpi(dir, 'Core')
    r = length(thickness);
else
    r = 0; 
end

if isSamp
k = isnan(l);
l = l(~k);
end

h = waitbar(0, 'Compiling Layers...');

for i = 1:length(thickness)
    if strcmpi(dir, 'Core')
        r = length(thickness) - i + 1;
    else
        r = i;
    end
    
      strat(i) = layerD(thickness(r));
      for j = 1:length(lay.data)
          strat(i).addprop(lay.props{j});
          strat(i).(lay.props{j}) = lay.data{j}(r);
      end
      if i~=1
              strat(i).insertAfter(strat(i-1));
      else
          strat(i).position = strat(i).thickness;
      end
      if mod(i,10)==0,waitbar(i/length(thickness));end
end
close(h);

h = waitbar(0, 'Adding Samples...');
   for i = 1:length(l)
       samp = sample(name(i), sh(i), l(i));
       for j = 1:length(isotope.props)
           samp.addprop(isotope.props{j});
           samp.(isotope.props{j}) = isotope.data{j}(i);
       end
       addSample(strat(l(i)), samp);
       if mod(i,10)==0,waitbar(i/length(l));end
   end
close(h);

disp(['# of Layers found: ' num2str(length(thickness))])
disp(' ')
disp(['Layer properties available: '])
for i=1:length(lay.props)
    disp(lay.props{i})
end
disp(' ')
disp(['Additional datasets available: '])
for i=1:length(isotope.props)
    disp(isotope.props{i})
end

out_struct = {strat, isotope.props, lay.props};

save(strcat('SECTIONS/',filename(1:end-4),'.mat'),'out_struct')
