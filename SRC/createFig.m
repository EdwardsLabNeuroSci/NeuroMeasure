function fig = createFig(Cmin,Cmax,Colormap,varargin)
% Generate a figure from one or more of several data inputs

% *Scatter
% Plot a scatter plot by entering any 3 column set of data with format
% u,v,MEP. If you are plotting it over an image, make sure the scatter plot
% is in image index coordinates

% *Marker
% Plot a '+' shaped white marker at locations specified by a 1x2 data array
% of the form (u,v)

% *Grayscale
% Plot a grayscale image by entering any MxNx1 image array

% *Truecolor
% Plot a heatmap image by entering any MxNx2 image array where I(:,:,1) is
% the heatmap array and I(:,:,2) is an array of alpha values (range 0-1)
% that dictates the opacity of the heatmap.

for i = 1:length(varargin)
    if size(varargin{i},2) == 3
        inputTypes{i} = 'Scatter';
    elseif size(varargin{i},2) == 2
        inputTypes{i} = 'Marker';
    else
        if size(varargin{i},3) == 1
            inputTypes{i} = 'Grayscale';
        else
            inputTypes{i} = 'Truecolor';
        end
    end
end

for i = 1:length(varargin)
    if sum(contains(inputTypes,'Grayscale')) >= 1
        n = find(strcmp(inputTypes,'Grayscale') == 1);
        inputTypes{n} = 'Null';
        protocol = 'Grayscale';
    else
        if sum(contains(inputTypes,'Truecolor')) >= 1
            n = find(strcmp(inputTypes,'Truecolor') == 1);
            inputTypes{n} = 'Null';
            protocol = 'Truecolor';
        else
            if sum(contains(inputTypes,'Scatter')) >= 1
                n = find(strcmp(inputTypes,'Scatter') == 1);
                inputTypes{n} = 'Null';
                protocol = 'Scatter';
            else
                if sum(contains(inputTypes,'Marker')) >= 1
                    n = find(strcmp(inputTypes,'Marker') == 1);
                    inputTypes{n} = 'Null';
                    protocol = 'Marker';
                end
            end
        end
    end
    
    switch protocol
        case 'Grayscale'
            fig = imshow(varargin{n},[0,max(max(varargin{n}))]);
            hold on
            
        case 'Truecolor'
            MEPmap = varargin{n};
            if ~(isnan(Cmin) || isnan(Cmax))
                fig = imshow(truecolor(MEPmap(:,:,1),Cmin,Cmax,Colormap));
            else
                fig = imshow(truecolor(MEPmap(:,:,1)));
            end
            set(fig, 'AlphaData', MEPmap(:,:,2));
            hold on
            
        case 'Scatter'
            Data = varargin{n};
            if ~(isnan(Cmin) || isnan(Cmax))
                fig = scatter(Data(:,1),Data(:,2),20,squeeze(truecolor(Data(:,3),Cmin,Cmax,Colormap)),'filled');
            else
                fig = scatter(Data(:,1),Data(:,2),20,squeeze(truecolor(Data(:,3))),'filled');
            end
            hold on
            
        case 'Marker'
            Marker = varargin{n};
            fig = scatter(Marker(:,1),Marker(:,2),60,'+','MarkerEdgeColor',[.95,.95,.95],'LineWidth',1.5);
            hold on
    end
end
hold off