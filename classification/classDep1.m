% output1_tr_idx = (training_data(:,4)==1);
% output2_tr_idx = (training_data(:,4)==2);
% 
% output1_tr = training_data(output1_tr_idx,:);
% output2_tr = training_data(output2_tr_idx,:);
% 
% [clusters1,sigma1]=subclust(output1_tr,0.5);
% [clusters2,sigma2]=subclust(output2_tr,0.5);
% size_c1 = size(clusters1,1);
% size_c2 = size(clusters2,1);
% 
% initial_fis = newfis('initial_fis', 'sugeno');
% 
% initial_fis = addvar(initial_fis, 'output', 'output1', [1, 2]);
% for i = 1:3
%     min_bound = min(training_data(:,i));
%     max_bound = max(training_data(:,i));
%     initial_fis = addvar(initial_fis, 'input', ['input', num2str(i)], [min_bound, max_bound]);
%     for j=1:size_c1
%         initial_fis=addmf(initial_fis,'input',i,'mf','gaussmf',[sigma1(i) clusters1(j,i)]);
%     end
%     for k=1:size_c2
%         initial_fis=addmf(initial_fis,'input',i,'mf','gaussmf',[sigma2(i) clusters2(k,i)]);
%     end
% end
function fis = classDep1(training_data, radius)
    %%Clustering Per Class
    [c1,sig1]=subclust(training_data(training_data(:,end)==1,:),radius);
    [c2,sig2]=subclust(training_data(training_data(:,end)==2,:),radius);
    num_rules=size(c1,1)+size(c2,1);

    %Build FIS From Scratch
    fis=newfis('FIS','sugeno');

    %Add Input-Output Variables
    names_in={'in1','in2','in3'};
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
    end

    %Add Output Membership Functions
    params=[zeros(1,size(c1,1)) ones(1,size(c2,1))];
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