function mice_tags = find_all_mice_tags(work_dir)
% Find all of the tags that were given to a mouse inside a directory

cd(work_dir)
cur_dir = dir('*.nii');
cur_dir_file_names = string({cur_dir.name}');

mice_tags = cell(100, 1);
idx = 1;
tag = regexp(cur_dir_file_names(1), '.+?_', 'match');
tag = tag(1);
mice_tags{idx} = tag;

for file = cur_dir_file_names'
    new_tag = regexp(file, '.+?_', 'match');
    new_tag = new_tag(1);
    if ~strcmp(tag, new_tag)
        tag = new_tag;
        idx = idx + 1;
        mice_tags{idx} = tag;
        
    end
end

mice_tags = mice_tags(~cellfun('isempty', mice_tags));
mice_tags = string(mice_tags);