function [img,hdr]=ReadAnalyzeHeader(name)
%  Reads one or more images in img file
%
%    img=readanalyzeimg2(name,dim,pre,lim,no[,scale,offset[,fileformat]])
%    [img,hdr]=readanalyzeimg2(name[,format])
%    [img,hdr]=readanalyzeimg2(name,no[,format])
%
%  img       - Pixel values (pix_val)
%  name      - name of image file
%  dim       - x,y,z,[t] no of pixels in each direction
%  pre       - precision for pictures (8/16 bit)
%  lim       - max and min limits for pixel values
%  no        - layer in image file to read, (':') all of them
%              ('n:') slices 'n', all time frames,
%              (':n') all slices, time frame 'n'
%              ('n1,n2') slice 'n1', time frame 'n2'
%              ('n1:n2,n3:n4') slices 'n1:n2' and frames 'n3:n4'
%  format    - "raw" - original data format (very fast), 'everything else" double
%  hdr       - contains a structure with header information
%               (as for readanalyzehdr2)
%  fileformat - Format for numbers 'ieee-be' og 'ieee-be'
%  Data has to be scaled afterwards by the following equation:
%  abs_pix_val = (pix_val - offset) * scale
%
%  CS, 010294
%
%  Revised
%  CS, 181194  Possibility of offset and scale in header file
%  CS, 280100  Reading changed so routines works on both HP and Linux
%              systems
%  CS, 060700  Automatic scaling of image removed, and posibility for
%              having the header returned in the call
%  CS, 080201  Extended with possibility to read one slice from one frema
%  CS, 070801  Changed to be able to handle 'ieee-le' files (non standard
%               analyze format)
%
if (nargin ~= 5) && (nargin ~= 7) && (nargin ~= 8) && (nargin ~= 1) && (nargin ~= 2)&& (nargin ~= 3)
    error('readanalyzeimg, Incorrect number of input arguments');
end;
pos=findstr(name,'.img');
if (~isempty(pos))
    name=name(1:(pos(1)-1));
end;
pos=findstr(name,'.hdr');
if (~isempty(pos))
    name=name(1:(pos(1)-1));
end;
OutputDataFormat=1;    %doubles
no=':';
pos=findstr(name,'.img');
if (~isempty(pos))
    name=name(1:(pos(1)-1));
end;
pos=findstr(name,'.hdr');
if (~isempty(pos))
    name=name(1:(pos(1)-1));
end;
FileName=sprintf('%s.hdr',name);
pid=fopen(FileName,'r','ieee-be');
header_size=fread(pid,2,'int16');
fileformat='ieee-be';
if (header_size(1) ~= 348) && (header_size(2) ~= 348)
    fclose(pid);
    pid=fopen(FileName,'r','ieee-le');
    header_size=fread(pid,2,'int16');
    fileformat='ieee-le';
    if (header_size(1) ~= 348) && (header_size(2) ~= 348)
        fclose(pid);
        pid=fopen(FileName,'r','ieee-be');
        header_size=fread(pid,2,'int16');
        fileformat='ieee-be';
        fprintf('Not able to detect analyze file format, guessing at ieee-be\n');
    end
end
fread(pid,36,'uchar');           % dummy read header information
dims=fread(pid,1,'ushort');      % dimension (3 or 4)
dim=fread(pid,4,'ushort');       % dimension, number of pixels
if (dims == 3) || (dim(4) == 1)
    dim=dim(1:3);
end;
fread(pid,4,'ushort');
fread(pid,7,'ushort');
pre=fread(pid,1,'ushort'); % datatype
fread(pid,1,'ushort');
fread(pid,2,'ushort');
siz=fread(pid,3,'float32');        % size of pixels
fread(pid,1,'float32');
gradorg = fread(pid,3,'float32');
offset=fread(pid,1,'float32');     % offset for pixels (funused8), SPM extension
scale=fread(pid,1,'float32');      % scaling for pixels (funused9), SPM extension
fread(pid,24,'char');
lim=fread(pid,2,'int');            % Limits for number in given analyze format
descr_input=fread(pid,80,'*char');  % Description field in header file
descr=descr_input';
descr=deblank(descr);
fread(pid,24,'char');
orient=fread(pid,1,'char');        % Orientation, not used
origin=fread(pid,3,'int16');       % Origin, SPM extension to analyze format
fread(pid,89,'char');              % Not used
fclose(pid);

pos=findstr(name,'/');
if (~isempty(pos))
    hdr.name=name((pos(length(pos))+1):length(name));
    hdr.path=name(1:(pos(length(pos))));
end;
hdr.pre=pre;
hdr.dim=dim;
hdr.siz=siz;
hdr.lim=lim;
hdr.scale=scale;
hdr.offset=offset;
hdr.origin=origin;
hdr.descr=descr;
hdr.fileformat=fileformat;
hdr.gradorg = gradorg;
hdr.name=name;
pre=hdr.pre;
vers=version;
vers_inf=sscanf(vers,'%i.');
if (OutputDataFormat == 0) && (vers_inf(1)<6)
    error('Raw data output format not supported in matlab versions lower than 6.0');
end
if (length(dim) == 3)
    dim(4)=1;
end;
if (ischar(no) ~= 1)
    All='no';
    if (length(no) == 1)
        MinSlice=no;
        MaxSlice=MinSlice;
        MinFrame=1;
        MaxFrame=MinFrame;
    else
        MinSlice=no(1);
        MaxSlice=MinSlice;
        MinFrame=no(2);
        MaxFrame=MinFrame;
    end
    NoOfImages=1;
else
    if ((strcmp(no,':') == 1) || (strcmp(no,'::') == 1))
        All='yes';
        NoOfImages=dim(3)*dim(4);
    else
        All='no';
        pos_comma=findstr(no,',');
        if (isempty(pos_comma))
            if (no(1) == ':')
                MinSlice=1;
                MaxSlice=dim(3);
                MinFrame=str2double(no(2:length(no)));
                MaxFrame=MinFrame;
                NoOfImages=dim(3);
            else
                pos=findstr(no,':');
                MinSlice=str2double(no(1:pos(1)-1));
                MaxSlice=MinSlice;
                MinFrame=1;
                MaxFrame=dim(4);
                NoOfImages=dim(4);
            end
        else
            Slices=findMinMax(no(1:pos_comma(1)-1));
            MinSlice=Slices(1);
            MaxSlice=Slices(2);
            Frames=findMinMax(no(pos_comma(1)+1:length(no)));
            MinFrame=Frames(1);
            MaxFrame=Frames(2);
            NoOfImages=(Frames(2)-Frames(1)+1)*(Slices(2)-Slices(1)+1);
        end;
    end
end;
%
FileName=sprintf('%s.img',name);
if exist('fileformat')
    pid=fopen(FileName,'r',fileformat);
else
    pid=fopen(FileName,'r','ieee-be');
end
if (pid ~= -1),
    if (strcmp(All,'yes')),
        if (pre == 8),
            if (OutputDataFormat == 1)
                img=fread(pid,'uint8');
            else
                img=fread(pid,'uint8=>uint8');
            end
        elseif (pre == 16)
            if (lim(1) > 32767)
                if (OutputDataFormat == 1)
                    img=(fread(pid,'uint16'));
                else
                    img=(fread(pid,'uint16=>uint16'));
                end
            else
                if (OutputDataFormat == 1)
                    img=(fread(pid,'int16'));
                else
                    img=(fread(pid,'int16=>int16'));
                end
            end;
        elseif (pre == 32)
            if (OutputDataFormat == 1)
                img=fread(pid,'float32');
            else
                img=fread(pid,'float32=>float32');
            end
        elseif (pre == 64)
            if (OutputDataFormat == 1)
                img=fread(pid,'float64');
            else
                img=fread(pid,'float64=>float64');
            end
        else
            error('readanalyzeimg, Precision argument not legal')
        end;
    else
        if (MaxSlice > dim(3)) || (MaxFrame > dim(4))
            fprintf('Specified slice or frame out of range\n');
        end;
        img=zeros(dim(1)*dim(2)*NoOfImages,1);
        if (OutputDataFormat ~= 1)  % Not double
            if (pre == 8),
                img=uint8(img);
            elseif (pre == 16)
                if (lim(1) > 32767)
                    img=uint16(img);
                else
                    img=int16(img);
                end
            elseif (pre == 32)
                img=float32(img);
            elseif (pre == 64)
                img=float64(img);
            else
                error('Unknow precision argument');
            end
        end
        hdr.dim(3)=MaxSlice-MinSlice+1;
        hdr.dim(4)=MaxFrame-MinFrame+1;
        k=0;
        
        for i=MinFrame:MaxFrame,
            progbar(p,round(i/(MaxFrame-MinFrame)*100));
            for j=MinSlice:MaxSlice,
                if (pre == 8),
                    status=fseek(pid,(j-1)*dim(1)*dim(2)+(i-1)*dim(1)*dim(2)*dim(3),'bof');
                    if (status ~= 0)
                        fprintf('readanalyzeimg, fseek error\n');
                        img=[];
                    else
                        if (OutputDataFormat == 1)
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'uint8');
                        else
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'uint8=>uint8');
                        end
                    end;
                elseif (pre == 16)
                    status=fseek(pid,(j-1)*dim(1)*dim(2)*2+(i-1)*dim(1)*dim(2)*dim(3)*2,'bof');
                    if (status ~= 0)
                        fprintf('readanalyzeimg, fseek error\n');
                        img=[];
                    else
                        if (lim(1) > 32767)
                            if (OutputDataFormat == 1)
                                img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                    fread(pid,dim(1)*dim(2),'uint16');
                            else
                                img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                    fread(pid,dim(1)*dim(2),'uint16=>uint16');
                            end
                        else
                            if (OutputDataFormat == 1)
                                img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                    fread(pid,dim(1)*dim(2),'int16');
                            else
                                img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                    fread(pid,dim(1)*dim(2),'int16=>int16');
                            end
                        end;
                    end;
                elseif (pre == 32)
                    status=fseek(pid,(j-1)*dim(1)*dim(2)*4+(i-1)*dim(1)*dim(2)*dim(3)*4,'bof');
                    if (status ~= 0)
                        fprintf('readanalyzeimg, fseek error\n');
                        img=[];
                    else
                        if (OutputDataFormat == 1)
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'float32');
                        else
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'float32=>float32');
                        end
                    end;
                elseif (pre == 64)
                    status=fseek(pid,(j-1)*dim(1)*dim(2)*8+(i-1)*dim(1)*dim(2)*dim(3)*8,'bof');
                    if (status ~= 0)
                        fprintf('readanalyzeimg, fseek error\n');
                        img=[];
                    else
                        if (OutputDataFormat == 1)
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'float64');
                        else
                            img(k*dim(1)*dim(2)+1:(k+1)*dim(1)*dim(2),:)=...
                                fread(pid,dim(1)*dim(2),'float64=>float64');
                        end
                    end;
                else
                    error('Unknown precision');
                end;
                k=k+1;
            end;
        end;
    end;
    if ((~isempty(img)) && (NoOfImages == 1))
        img=reshape(img,dim(1),dim(2));
    end;
    img=reshape(img,[ hdr.dim(1), hdr.dim(2), hdr.dim(3)]);
    fclose(pid);
else
    img=[];
end;

function Number=findMinMax(String)
%
% Finds min and max from string
%
pos=findstr(String,':');
if (isempty(pos))
    Number(1)=str2double(String);
    Number(2)=Number(1);
else
    Number(1)=str2double(String(1:pos(1)-1));
    Number(2)=str2double(String(pos(1)+1:length(String)));
end



