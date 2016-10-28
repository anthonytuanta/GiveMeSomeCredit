function [data]=loadTrainingData(filename)
    fid=fopen(filename,'r');
    inputText = textscan(fid,'%s',1,'delimiter','\n');
    headers=strsplit(inputText{1}{1},',');
    numFields=length(headers);     %figure out number of columns here
    data=textscan(fid,repmat('%f',1,numFields),...
          'Delimiter',',','TreatAsEmpty',{'NA','na'},'CollectOutput',true);
    fclose(fid);

    data=data{1};
    data(:,1)=[];
    numFields=numFields-1;
    headers(1)=[];       
    
    missing=isnan(data);
    countMissing=sum(missing); %find the cols with missing data
    missingCols=find(countMissing>0);
    
    %cleaning data
    toRemove=[];
    col=2;
        id=find(data(:,col)>10);
        toRemove=[toRemove ;id];
    col=3;
        toRemove=[toRemove ; find(data(:,col)==0)];
    col=4;
        id=find(data(:,col)>90);
        toRemove=[toRemove ;id];
    for col=5:11;
        tmpdata=sort(data(:,col));
        missing=find(isnan(tmpdata));
        if (isempty(missing))
            thresholdid=floor(0.997*length(tmpdata));
        else
            thresholdid=floor((0.997*length(tmpdata))-size(missing,1));
        end
        id=find(data(:,col)>=tmpdata(thresholdid));
        toRemove=[toRemove ;id];
    end
    toRemove=unique(toRemove);
    data(toRemove,:)=[];
    
    %find rows with missing data and replace by mean value of that field
    for i=1:length(missingCols)
      missingRowIndex=find(isnan(data(:,missingCols(i))));
      replacedMean=nanmean(data(:,missingCols(i)));
      data(missingRowIndex,missingCols(i))=replacedMean;
    end
end