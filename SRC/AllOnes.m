function [I,J,K]=AllOnes(mask)

I=[]; J=[]; K=[];
for n=1:size(mask,3)
    [i,j]=find(mask(:,:,n) == 1);
    k=ones(size(i,1),1);
    k=k*n;
    I=cat(1,I,i); J=cat(1,J,j); K=cat(1,K,k);
end