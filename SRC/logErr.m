function logErr(except) 
a=fopen('log.txt','a');
fprintf(a,'\n------------------------\n');
curtime=clock;
fprintf(a,[num2str(curtime(2)) '/' num2str(curtime(3)) '/' num2str(curtime(1)) ' ' num2str(curtime(4)) ':' num2str(curtime(5)) ':' num2str(curtime(6)) '\n']);
fprintf(a,[except.identifier '\n' except.message '\n']);
if ~isempty(except.cause)
    fprintf(a,[except.cause '\n']);
end
fprintf(a, 'stack:\n');
if ~isempty(except.stack) 
    linen=except.stack.line;
    file=except.stack.file;
    name=except.stack.name;
    fprintf(a,num2str(linen));
    fprintf(a,' ');
    fprintf(a,file);
    fprintf(a,' \n');
    fprintf(a,name);
    fprintf(a,' \n');
end