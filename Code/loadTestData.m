function [data]=loadTestData(filename)
    fid=fopen(filename,'r');
    inputText = textscan(fid,'%s',1,'delimiter','\n');
    header = inputText{1}{1};
    disp(header);                        % Display header line
    numFields=length(strsplit(header,',')); 
    data=textscan(fid,repmat('%f',1,numFields),...
          'Delimiter',',','TreatAsEmpty',{'NA','na'},'CollectOutput',true);
    fclose(fid);
    data=data{1};
    data(:,1)=[];
    
    %fill in missing data for test set
    missing=isnan(data);
    countMissing=sum(missing); %find the cols with missing data
    missingCols=find(countMissing>0);
    for i=1:length(missingCols)
      missingRowIndex=find(isnan(data(:,missingCols(i))));
      replacedMean=nanmean(data(:,missingCols(i)));
      data(missingRowIndex,missingCols(i))=replacedMean;
    end
end