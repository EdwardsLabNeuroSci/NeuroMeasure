function COM = centerofmass(Data)

COM(1) = sum(Data(:,1).*Data(:,4))/sum(Data(:,4));
COM(2) = sum(Data(:,2).*Data(:,4))/sum(Data(:,4));
COM(3) = sum(Data(:,3).*Data(:,4))/sum(Data(:,4));