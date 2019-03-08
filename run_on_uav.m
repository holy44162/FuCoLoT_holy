function run_on_uav()

% set paths on your machine
% tracker_path = 'E:\workspace\tracking\CSRDCF2\FuCoLoT-github';
% dataset_path = 'E:\datasets\UAV123';
% results_path = 'E:\workspace\tracking\CSRDCF2\FuCoLoT-github\results';

tracker_path = 'm:\files\computerVision\videoTracking\FuCoLoT_holy';
dataset_path = 'M:\files\computerVision\videoTracking\dataResultsOftracker_benchmark_v1.1\UAV123_10fps';
results_path = 'm:\files\computerVision\videoTracking\FuCoLoT_holy\results';

% add paths
addpath(tracker_path);
addpath(fullfile(tracker_path, 'scale'));
st_path = fullfile(tracker_path, 'CSRDCF');
addpath(st_path);
addpath(fullfile(st_path, 'mex'));
addpath(fullfile(st_path, 'utils'));
addpath(fullfile(st_path, 'features'));

dataset_type = '123';  % LT - long term (UAV20L); 123 - full UAV123

visualize = true;
save_results = true;

% if ~exist(results_path) % hided by Holy 1903071021
if exist(results_path, 'dir') ~= 7 % added by Holy 1903071021
    mkdir(results_path);
end

% seq_config = configSeqs(dataset_type, fullfile(dataset_path, 'data_seq\UAV123')); % hided by Holy 1903071019
seq_config = configSeqsNew(fullfile(dataset_path, 'data_seq\UAV123_10fps')); % added by Holy 1903071019

% parfor i=1:numel(seq_config) % hided by Holy 1903071100
for i=1:numel(seq_config) % added by Holy 1903071100
    
    s = seq_config{i};
    fprintf('Processing sequence: %s\n', s.name);
    
    bboxes_path = fullfile(results_path, sprintf('%s_bboxes.txt', s.name));
    % check for completeness
    if save_results && my_exist(bboxes_path)
        fprintf('Sequence already processed, skipping...\n');
        continue;
    end
    
    % read ground-truth
    if strcmp(dataset_type, 'LT')
        dataset = 'UAV20L';
    elseif strcmp(dataset_type, '123')
%         dataset = 'UAV123'; % hided by Holy 1903071050
        dataset = 'UAV123_10fps'; % added by Holy 1903071050
    else
        error('Unknown dataset type. Only LT and 123 supported.');
    end
    gt = dlmread(fullfile(dataset_path, 'anno', dataset, ...
        sprintf('%s.txt', s.name)));
    
    % read first image and initialize tracker
    img = imread(fullfile(s.path, sprintf('%06d.%s', s.startFrame, s.ext)));
    % added by Holy 1903081715
    theta = -0.4;
    tform = affine2d([cosd(theta) sind(theta) 0;...
        -sind(theta) cosd(theta) 0; 0 0 1]);
    img = imwarp(img,tform);
    % end of addition 1903081715
    gt = gt(2, :);
    tracker = create_fclt_tracker(img, gt);
    
    % allocate memory for results and store first frame
    bboxes = zeros(s.endFrame-s.startFrame+1, size(gt,2));
    bboxes(1,:) = gt;
    idx = 2;
    
    if visualize
        figure(1); clf;
        imshow(img);
        hold on;
        rectangle('Position',gt, 'LineWidth',2, 'EdgeColor','y');
        hold off;
        drawnow;
    end
    
    % iterate over frames: from second to the end
    for j=s.startFrame+1:s.endFrame
        tStartFrame = tic; % added by Holy 1903081125
        
        % read image and track frame
        img = imread(fullfile(s.path, sprintf('%06d.%s', j, s.ext)));
        % added by Holy 1903081715
        tform = affine2d([cosd(theta) sind(theta) 0;...
            -sind(theta) cosd(theta) 0; 0 0 1]);
        img = imwarp(img,tform);
        % end of addition 1903081715
        [tracker, bb] = track_fclt_tracker(tracker, img);
        % store result
        bboxes(idx,:) = bb;
        idx = idx + 1;
        
        % added by Holy 1903081126
        frameElapsedTime = toc(tStartFrame);
        fps = 1/frameElapsedTime;
        % end of addition 1903081126
        
        if visualize
            imshow(img);
            hold on;
            rectangle('Position',bb, 'LineWidth',2, 'EdgeColor','y');
            text(10, 10, num2str(fps), 'color', [0 1 1]); % added by Holy 1903081127
            hold off;
            drawnow;
        end
        
    end
    
    % save results
    if save_results
        my_save(bboxes_path, bboxes);
    end
    
end

end  % endfunction


function ex_ = my_exist(exist_path)
    ex_ = exist(exist_path);
end  % endfunction


function my_save(save_results_path, results)
    dlmwrite(save_results_path, results);
end  % endfunction