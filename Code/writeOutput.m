function writeOutput(filename,prob)
    id=1:length(prob);
    fid=fopen(filename,'w');
    fprintf(fid,'Id,Probability\n');
    fprintf(fid,'%d,%f\n',[id; prob']);
    fclose(fid);
end