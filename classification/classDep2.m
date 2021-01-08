function fis = classDep2(training_data, radius)
    %%Clustering Per Class
    [c1,sig1]=subclust(training_data(training_data(:,end)==1,:),radius);
    [c2,sig2]=subclust(training_data(training_data(:,end)==2,:),radius);
    [c3,sig3]=subclust(training_data(training_data(:,end)==3,:),radius);
    [c4,sig4]=subclust(training_data(training_data(:,end)==4,:),radius);
    [c5,sig5]=subclust(training_data(training_data(:,end)==5,:),radius);    
    num_rules=size(c1,1)+size(c2,1);

    %Build FIS From Scratch
    fis=newfis('FIS','sugeno');

    %Add Input-Output Variables
    names_in={'in1','in2','in3','in4','in5','in6','in7','in8','in9','in10','in11','in12','in13','in14','in15','in16','in17','in18','in19','in20','in21','in22','in23','in24'};
    for i=1:size(training_data,2)-1
        min_bound = min(training_data(:,i));
        max_bound = max(training_data(:,i));
        fis=addvar(fis,'input',names_in{i},[min_bound max_bound]);
    end
    fis=addvar(fis,'output','out1',[1 2]);

    %Add Input Membership Functions
    name='sth';
    for i=1:size(training_data,2)-1
        for j=1:size(c1,1)
            fis=addmf(fis,'input',i,name,'gaussmf',[sig1(i) c1(j,i)]);
        end
        for j=1:size(c2,1)
            fis=addmf(fis,'input',i,name,'gaussmf',[sig2(i) c2(j,i)]);
        end
        for j=1:size(c3,1)
            fis=addmf(fis,'input',i,name,'gaussmf',[sig3(i) c3(j,i)]);
        end
        for j=1:size(c4,1)
            fis=addmf(fis,'input',i,name,'gaussmf',[sig4(i) c4(j,i)]);
        end
        for j=1:size(c5,1)
            fis=addmf(fis,'input',i,name,'gaussmf',[sig5(i) c5(j,i)]);
        end
    end

    %Add Output Membership Functions
    params=[zeros(1,size(c1,1)) ones(1,size(c2,1)) 2*ones(1,size(c3,1)) 3*ones(1,size(c4,1)) 4*ones(1,size(c5,1))];
    for i=1:num_rules
        fis=addmf(fis,'output',1,name,'constant',params(i));
    end

    %Add FIS Rule Base
    ruleList=zeros(num_rules,size(training_data,2));
    for i=1:size(ruleList,1)
        ruleList(i,:)=i;
    end
    ruleList=[ruleList ones(num_rules,2)];
    fis=addrule(fis,ruleList);
end