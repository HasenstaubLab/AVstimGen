function [vars vals_all] = queryLoopsBox(handles)

vals = cell(1,6); 
vars = cell(1,6); 
for i = 1:6 
    eval(['vals{' num2str(i) '} = str2num(get(handles.val' num2str(i) '_edit, ''String''));']); 
    eval(['vars{' num2str(i) '} = get(handles.var' num2str(i) '_edit, ''String'');']); 
end

empty_vars = cellfun(@isempty, vars); 
vals(empty_vars) = [];
vars(empty_vars) = []; 

switch size(vars, 2); 
    case 0 
        vals_all = []; 
    case 1
         vals_all = vals{:}'; 
    case 2 
        [v1,v2]=ndgrid(vals{:,1}, vals{:,2});
        vals_all = [v1(:) v2(:)];
    case 3
        [v1,v2,v3]=ndgrid(vals{:,1}, vals{:,2}, vals{:,3});
        vals_all = [v1(:) v2(:) v3(:)]; 
    case 4
        [v1,v2,v3,v4]=ndgrid(vals{:,1}, vals{:,2}, vals{:,3}, vals{:,4});
        vals_all = [v1(:) v2(:) v3(:) v4(:)]; 
    case 5
        [v1,v2,v3,v4,v5]=ndgrid(vals{:,1}, vals{:,2}, vals{:,3}, vals{:,4}, vals{:,5}); 
        vals_all = [v1(:) v2(:) v3(:) v4(:) v5(:)]; 
    case 6 
        [v1,v2,v3,v4,v5,v6]=ndgrid(vals{:,1}, vals{:,2}, vals{:,3}, vals{:,4}, vals{:,5}, vals{:,6}); 
        vals_all = [v1(:) v2(:) v3(:) v4(:) v5(:) v6(:)]; 
end 
% 
% if handles.random_loop && ~isempty(vals_all)
%    rand_ind = randperm(length(vals_all)); 
%    vals_all = vals_all(rand_ind,:); 
% end

