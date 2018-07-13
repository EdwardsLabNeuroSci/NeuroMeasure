%DataTab class definition
classdef UITab
   properties
      dataset
      name
      clusters
      cache
      imdata
      markers
      com
      peakpos
      surfmap
      status
      hsimgs
      system
   end
   methods
      function obj = UITab(datainf,tabname,COM,PeakMEPPos) %class creator fcn
        obj.clusters=[];
        obj.imdata=[];
        obj.markers=[NaN,NaN,NaN,0;NaN,NaN,NaN,0;NaN,NaN,NaN,0];
        obj.surfmap=[];
        obj.hsimgs=[];
        obj.status='uploaded';
        if isnumeric(datainf)
            obj.dataset = datainf;
            obj.cache = [];
        else
            ME = MException('NewTab:dataset:InvalidDataType', ...
                sprintf('Data is not numeric. Input: %s of size %s',class(datainf), ['[' num2str(size(datainf)) ']']));
            throw(ME);
        end
        if isnumeric(COM) && length(COM)==3
            obj.com = COM;
        else
            ME = MException('NewTab:com:InvalidDataType', ...
                sprintf('Data is not numeric, or is of incorrect size (1x3). Input: %s of size %s',class(COM), ['[' num2str(size(COM)) ']']));
            throw(ME);
        end
        if isnumeric(PeakMEPPos) && (length(PeakMEPPos)==3)
            obj.peakpos = PeakMEPPos;
        else
            ME = MException('NewTab:peakpos:InvalidDataType', ...
                sprintf('Data is not numeric, or is of incorrect size (1x4). Input: %s of size %s',class(PeakMEPPos), ['[' num2str(size(PeakMEPPos)) ']']));
            throw(ME);
        end
        if ischar(tabname)
            obj.name = tabname;
        else
            ME = MException('NewTab:tabname:InvalidDataType', ...
                sprintf('Tabname is not char array. Input: %s of size %s',class(tabname), ['[' num2str(size(tabname)) ']']));
            throw(ME);
        end
      end          
    end
end