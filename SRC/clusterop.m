function MEP = clusterop(MEP,method,motorthresh)
% Average x,y,z coordinates of cell array clusters and perform operation on
% MEP values specified by method

%Inputs
%MEP - cell array containing clusters of x,y,z data in first three columns
% respecitvely and MEP values in the fourth.
%method - method specifying how MEP values will be processed:
%   average - data treated as continuous; set averaged
%   maximum - data treated as continuous; maximum value of set
%   minimum - data treated as continuous; minimum value of set
%   binary average - data treated as categorical; binarized with motor
% threshold where 0 = <40uV and 1 = >40uV and averaged binary to yield
% probability score of above threshold activation (where 0 = never and 1
% = always)
%   binary threshold -  data treated as categorical; binarized with motor
% threshold where 0 = <40uV and 1 = >40uV. Then, if more then half of
% entries in the set are 1, the cluster is assigned 1 and otherwise it is
% assigned 0. Approach from Thickbroom et al. 2008


tempMEP = zeros(size(MEP,2),4);
for i = 1:size(MEP,2)
    tempMEP(i,1:3) = [mean(MEP{i}(:,1)),mean(MEP{i}(:,2)),mean(MEP{i}(:,3))];
    switch method
        case 'average'

            tempMEP(i,4) = mean(MEP{i}(:,4));

        case 'maximum'

            tempMEP(i,4) = max(MEP{i}(:,4));

        case 'minimum'

            tempMEP(i,4) = min(MEP{i}(:,4));

        case 'probability'

            tempMEP(i,4) = (sum(MEP{i}(:,4) > motorthresh)/size(MEP{i}(:,4),1))*100;

        case 'binary threshold'

            tempMEP(i,4) = (sum(MEP{i}(:,4) > motorthresh)/size(MEP{i}(:,4),1) > 0.5)*100;
            
        case 'variance'

            tempMEP(i,4) = var(MEP{i}(:,4));
    end
end
MEP = tempMEP;
end