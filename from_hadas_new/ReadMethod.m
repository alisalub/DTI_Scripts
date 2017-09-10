function [Method]=ReadMethod(path_of_2dseq)

find_pdata=strfind(path_of_2dseq,'pdata');
path_acquisition=[path_of_2dseq(1:find_pdata-2)];
% readmethod = importdata(path_method, ' ', NumLines);
path_method1=fuf([path_acquisition '\method.'],'detail');
path_method2=fuf([path_acquisition '\method.*'],'detail');
path_method3=fuf([path_acquisition '\method*.*'],'detail');
path_method4=fuf([path_acquisition '\*method.*'],'detail');
path_method5=fuf([path_acquisition '\*method.'],'detail');
path_method=[path_method1,path_method2,path_method3,path_method4,path_method5];
readmethod = importdata(path_method{1},'\t',20000);
count=0;
for line = 1:length(readmethod)
    if ~isempty(strfind(readmethod{line,1},'##')) || ~isempty(strfind(readmethod{line,1},'$$'))
        count=count+1;
        file_lines(count,1)=line;
    end
end
for line = 1:length(readmethod)
    if any(strfind(readmethod{line},'##$PVM_DwGradSep='))
        BigDelta=str2double(readmethod{line+1});
    elseif any(strfind(readmethod{line},'##$PVM_DwGradDur='))
        SmallDelta=str2double(readmethod{line+1});
    elseif any(strfind(readmethod{line},'/method'))
        slashes=strfind(readmethod{line},'/');
        Acquisition=str2num(readmethod{line}(slashes(end-1)+1:slashes(end)-1));
    elseif any(strfind(readmethod{line},'##$PVM_ScanTimeStr='))
        Duration=(readmethod{line+1});
    elseif any(strfind(readmethod{line},'##$PVM_SelIrInvTime='))
        TI_start=strfind(readmethod{line},'=');
        TI=str2num(readmethod{line}(TI_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_DwEffBval='))
        EffBval_Start=line+1;
        lines_index=find(file_lines==line);
        EffBval_End=file_lines(lines_index+1)-1;
    elseif any(strfind(readmethod{line},'##$PVM_DwBMat='))
        DW_Bmat_Start=line+1;
        lines_index=find(file_lines==line);
        DW_Bmat_End=file_lines(lines_index+1)-1;
        %     elseif any(strfind(readmethod{line},'##$PVM_DwGradVec'))
        %         EffBval_End=line-1;
    elseif any(strfind(readmethod{line},'##$PVM_DwBvalEach='))
        BvalOrg_Start=line+1;
        lines_index=find(file_lines==line);
        BvalOrg_End=file_lines(lines_index+1)-1;
        %     elseif any(strfind(readmethod{line},'##$PVM_DwGradAmp'))
        %         BvalOrg_End=line-1;
    elseif any(strfind(readmethod{line},'##$PVM_RepetitionTime='))
        TR_start=strfind(readmethod{line},'=');
        TR=str2num(readmethod{line}(TR_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_EchoTime1='))
        TE_start=strfind(readmethod{line},'=');
        TE=str2num(readmethod{line}(TE_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_NRepetitions='))
        NRepetitions_start=strfind(readmethod{line},'=');
        NRepetitions=str2num(readmethod{line}(NRepetitions_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_NAverages='))
        NEX_start=strfind(readmethod{line},'=');
        NEX=str2num(readmethod{line}(NEX_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_DwAoImages='))
        A0_start=strfind(readmethod{line},'=');
        A0=str2num(readmethod{line}(A0_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_DwDir='))
        Directions_Start=line+1;
        lines_index=find(file_lines==line);
        Directions_End=file_lines(lines_index+1)-1;
        %     elseif any(strfind(readmethod{line},'##$PVM_DwDgSwitch'))
        %         Directions_End=line-1;
    elseif any(strfind(readmethod{line},'##$PVM_Matrix='))
        Matrix_size=readmethod{line+1};
    elseif any(strfind(readmethod{line},'##$PVM_SpatResol='))
        Spatial_resolution=readmethod{line+1};
    elseif any(strfind(readmethod{line},'##$PVM_ObjOrderList='))
        Num_of_slices_start=strfind(readmethod{line},'=');
        Num_of_slices=str2num(readmethod{line}(Num_of_slices_start+2:end-1));
    elseif any(strfind(readmethod{line},'##$PVM_SliceThick='))
        Slice_thickness_start=strfind(readmethod{line},'=');
        Slice_thickness=str2num(readmethod{line}(Slice_thickness_start+1:end));
    elseif any(strfind(readmethod{line},'##$PVM_SPackArrSliceOrient='))
        Matrix_orientation=readmethod{line+1};
    elseif any(strfind(readmethod{line},'##$PVM_SPackArrReadOrient='))
        Read_direction=readmethod{line+1};
    end
end

if exist('Directions_Start','var') && exist('Directions_End','var')
    Directions_str='';
    for line=Directions_Start:Directions_End
        Directions_str=[Directions_str readmethod{line}];
    end
    Directions(:,1)=str2num(Directions_str);
    Directions=reshape(Directions,[3 length(Directions)/3])';
    Method.Directions=Directions;
end
if exist('EffBval_Start','var') && exist('EffBval_End','var')
    EffBval_str='';
    for line=EffBval_Start:EffBval_End
        EffBval_str=[EffBval_str readmethod{line}];
    end
    EffBval(:,1)=str2num(EffBval_str);
    Method.EffBval=EffBval;
end
if exist('DW_Bmat_Start','var') && exist('DW_Bmat_End','var')
    DW_Bmat_str='';
    for line=DW_Bmat_Start:DW_Bmat_End
        DW_Bmat_str=[DW_Bmat_str readmethod{line}];
    end
    DW_Bmat(:,1)=str2num(DW_Bmat_str);
    DW_Bmat=reshape(DW_Bmat,[3 length(DW_Bmat)/3])';
    Method.DW_Bmat=DW_Bmat;
end
if exist('BvalOrg_Start','var') && exist('BvalOrg_End','var')
    BvalOrg_str=' ';
    if exist('A0','var')
        A0=zeros(A0,1);
    end
    for line2=BvalOrg_Start:BvalOrg_End
        BvalOrg_str=[BvalOrg_str readmethod{line2}];
    end
    BvalOrg(:,1)=str2num(BvalOrg_str);
    Method.BvalOrg=[BvalOrg];
    Method.A0=length(A0);
    Method.Bval=length(BvalOrg);
end
Method.TR=TR;
Method.TE=TE;
Method.NRepetitions=NRepetitions;
if exist('SmallDelta','var')
    Method.SmallDelta=SmallDelta;
end
if exist('BigDelta','var')
    Method.BigDelta=BigDelta;
end
if exist('TI','var')
    Method.TI=TI;
end
Method.Spatial_resolution=[str2num(Spatial_resolution) Slice_thickness];
Method.Matrix_size=[str2num(Matrix_size) Num_of_slices];
Method.Duration=Duration;
Method.Averages=NEX;
Method.Acquisition=Acquisition;
Method.Matrix_orientation=Matrix_orientation;
Method.Read_direction=Read_direction;







