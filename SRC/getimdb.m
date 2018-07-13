function [imdb,pixelspacing,position,orientation] = getimdb(FolderPath, handles, hObject)
    %Obtains 3D array of image volume by stacking the transverse slices of the
    %MRI on top of one another.
    
    % *INPUTS*
    %FolderPath - Directory to the folder containing the MRI scan.
    
    % *OUTPUTS%
    %imdb - 3D array of the image volume derived from scan data.
    if FolderPath==0
        imdb = NaN;
        pixelspacing = NaN;
        position = NaN;
        orientation = NaN;
        return
    end
    
    % Create a list of the all the dicom meta data from all the dicoms in the folder
    filedir=dir(FolderPath);
    scanprops=cell(size(filedir,1),1);
    for i = 1:size(filedir,1)
        if filedir(i).isdir == 0
            if isdicom(char(strcat(FolderPath, '/', filedir(i).name))) == true
                scanprops{i,1} = dicominfo(char(strcat(FolderPath, '/', filedir(i).name)));
            else
                scanprops{i,1} = NaN;
            end
        else
            scanprops=cell(size(filedir,1),1);
        end
        handles.BusyString.String = sprintf('Uploading Dicoms: %0.3f %',(i/size(filedir,1))*100);
        drawnow
    end
    
    %Filter out dicoms without orientation and position which indicates they are not images
    for i = 1:size(scanprops,1)
        if ~isempty(scanprops{i,1})
            if ~(isfield(scanprops{i,1},'ImagePositionPatient') && ...
                    isfield(scanprops{i,1},'ImageOrientationPatient') && ...
                    isfield(scanprops{i,1},'PixelSpacing') && ...
                    isfield(scanprops{i,1},'Width') && isfield(scanprops{i,1},'Height') && ...
                    isfield(scanprops{i,1},'SliceThickness') && ...
                    isfield(scanprops{i,1},'InstanceNumber'))
                scanprops{i,1} = [];
            end
        end
    end
    
    %Sort remaining slices into lists based on certain criteria: common
    %orientation, pixelspacing, image dimensions, slice thickness
    scantypes = [];
    for i = 1:size(scanprops,1)
        if ~isempty(scanprops{i,1})
            if ~(isstruct(scantypes))
                clearvars 'scantypes'
                scantypes.Scan1.props = {scanprops{i,1}.ImageOrientationPatient,...
                    [scanprops{i,1}.PixelSpacing;scanprops{i,1}.SliceThickness],...
                    [scanprops{i,1}.Width;scanprops{i,1}.Height]};
                scantypes.Scan1.List(1,1) = i;
            else
                found = false;
                for j = 1:size(fields(scantypes),1)
                    if isequal(scantypes.(strcat('Scan',num2str(j))).props,...
                            {scanprops{i,1}.ImageOrientationPatient,...
                            [scanprops{i,1}.PixelSpacing;scanprops{i,1}.SliceThickness],...
                            [scanprops{i,1}.Width;scanprops{i,1}.Height]})
                        scantypes.(strcat('Scan',num2str(j))).List(end+1,1) = i;
                        found = true;
                    end
                end
                if found == false
                    scantypes.(strcat('Scan',num2str(size(fields(scantypes),1)+1))).props = ...
                       {scanprops{i,1}.ImageOrientationPatient,...
                       [scanprops{i,1}.PixelSpacing;scanprops{i,1}.SliceThickness],...
                       [scanprops{i,1}.Width;scanprops{i,1}.Height]};
                    scantypes.(strcat('Scan',num2str(size(fields(scantypes),1)))).List(1,1) = i;
                end
            end
        end
        handles.BusyString.String = sprintf('Sorting Dicoms: %0.3f %',(i/size(scanprops,1))*100);
        drawnow
    end
    
    %Check if the slicing order make sense. If there are any discontinuities, flag it.
    for i = 1:size(fields(scantypes),1)
        IntNumber = zeros(1,size(scantypes.(strcat('Scan',num2str(i))).List,1));
        for j = 1:size(scantypes.(strcat('Scan',num2str(i))).List,1)
            IntNumber(j) = scanprops{scantypes.(strcat('Scan',num2str(i))).List(j,1),1}.InstanceNumber;
        end
        %If there are greater than 10 discontinuities in InstanceNumber iteration, flag the scan for removal
        if size(IntNumber,2) < size(min(IntNumber):1:max(IntNumber),2) - 10
            scantypes.(strcat('Scan',num2str(i))).Problem = true;
        else
            scantypes.(strcat('Scan',num2str(i))).Problem = false;
        end
    end
    
    %Attempt to further seperate scans that were flagged earlier based on a 
    %dicom info similarity scoring system that compares slices with like InstanceNumber
    % for i = 1:size(fields(scantypes),1)
    %     if scantypes.(strcat('Scan',num2str(i))).Problem == true
    %         for j = 1:size(scantypes.(strcat('Scan',num2str(i))).List,1)
    %             IntNumber(j) = scanprops{scantypes.(strcat('Scan',num2str(i))).List(j,1),1}.InstanceNumber;
    %         end
    %         iter = min(IntNumber):max(IntNumber);
    %         scantypes.(strcat('Scan',num2str(i))).Sorting = cell(0,0);
    %         for j = 1:size(iter,2)
    %             ind = find(IntNumber == iter(1,j));
    %             if isempty(scantypes.(strcat('Scan',num2str(i))).Sorting)
    %                 for k = 1:size(ind,2)
    %                     scantypes.(strcat('Scan',num2str(i))).Sorting{j,end+1} = scantypes.(strcat('Scan',num2str(i))).List(ind(1,k),1);
    %                 end
    %             else
    %                 if ~isempty(ind)
    %                     score = [];
    %                     decision = [];
    %                     for k = 1:size(scantypes.(strcat('Scan',num2str(i))).Sorting,2)
    %                         for q = 1:size(ind,2)
    %                             if ~isempty(scantypes.(strcat('Scan',num2str(i))).Sorting{j-1,k})
    %                                 score(q,k) = dicomcompare(scanprops{scantypes.(strcat('Scan',num2str(i))).Sorting{j-1,k},1},scanprops{scantypes.(strcat('Scan',num2str(i))).List(ind(1,q)),1});
    %                             else
    %                                 score(q,k) = NaN;
    %                             end
    %                         end
    %                     end
    %                     for q = 1:size(score,1)
    %                         for k = 1:size(score,2)
    %                             decision(q,k) = score(q,k) == max(score(q,:));
    %                         end
    %                     end
    %                     if sum(sum(decision,2) <= 1) ~= size(decision,1)
    %                         errordlg('The MRI parsing algorithm encountered an error when sorting the slices automatically. Reorganize the scan folder to contain only one scan type and try again');
    %                         break
    %                     else
    %                         for q = 1:size(decision,1)
    %                             if sum(decision(q,:) == 1)
    %                                 scantypes.(strcat('Scan',num2str(i))).Sorting{j,find(decision(q,:) == 1)} = scantypes.(strcat('Scan',num2str(i))).List(ind(1,q),1);
    %                             else
    %                                 scantypes.(strcat('Scan',num2str(i))).Sorting{j,end+1} = scantypes.(strcat('Scan',num2str(i))).List(ind(1,q),1);
    %                             end
    %                         end
    %                     end
    %                 else
    %                     for k = 1:size(scantypes.(strcat('Scan',num2str(i))).Sorting,2)
    %                         scantypes.(strcat('Scan',num2str(i))).Sorting{j,k} = [];
    %                     end
    %                 end
    %             end
    %         end
    %     end
    % end
    
    %Remove any scans with sequencing errors or anomolies with too few scans
    for i = 1:size(fields(scantypes),1)
        if size(scantypes.(strcat('Scan',num2str(i))).List,1) < 10 || scantypes.(strcat('Scan',num2str(i))).Problem == 1
            scantypes = rmfield(scantypes,strcat('Scan',num2str(i)));
        end
    end
    
    if size(fields(scantypes),1) > 1
        Choice = ScanSelectUI(scantypes,scanprops);
        if isempty(Choice)
            imdb = NaN;
            pixelspacing = NaN;
            position = NaN;
            orientation = NaN;
            return
        end
        List = scantypes.(Choice).List;
        Props = scantypes.(Choice).props;
    else
        Choice = fields(scantypes);
        Choice = Choice{1,1};
        List = scantypes.(Choice).List;
        Props = scantypes.(Choice).props;
    end
    
    imdb = single(zeros(Props{1,3}(2,1),Props{1,3}(1,1),size(List,1)));
    int = zeros(1,size(List,1));
    for i = 1:size(List,1)
        imdb(:,:,scanprops{List(i,1),1}.InstanceNumber) = dicomread(strcat(FolderPath,'/',filedir(List(i,1)).name));
        int(i) = scanprops{List(i,1),1}.InstanceNumber;
        handles.BusyString.String = sprintf('Reading Dicoms: %0.3f %',(i/size(scanprops,1))*100);
    end
    info = dicominfo(strcat(FolderPath,'/',filedir(List(find(int == min(int)),1)).name));
    position = info.ImagePositionPatient;
    orientation = Props{1,1};
    pixelspacing = Props{1,2};