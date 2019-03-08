% compile hog and segmetation mex files
% before compiling set the following variables to the correct paths:
% opencv_include and opencv_libpath

% added by Holy 1903081409
ispc = true;
isunix = false;
% end of addition 1903081409

current_folder = pwd;
% mkdir('mex'); % hided by Holy 1903081411
% added by Holy 1903081410
if exist('mex', 'dir') ~= 7
    mkdir('mex');
end
% end of addition 1903081410

cd(['mex_src' filesep 'hog']);
mex gradientMex.cpp
movefile('*.mex*', [current_folder filesep 'mex'])
cd(current_folder);

if ispc     % Windows machine, add opencv dll path to system path, such as: d:\backupTools\opencv-4.0.1\opencv\build\x64\vc15\bin\
    % set opencv include path
    opencv_include = 'd:\backupTools\opencv-4.0.1\opencv\build\include\';
    % set opencv lib path
    opencv_libpath = 'd:\backupTools\opencv-4.0.1\opencv\build\x64\vc15\lib\';

    files = dir([opencv_libpath '*opencv*.lib']);
    lib = [];
    for i = 1:length(files)
        lib = [lib ' -l' files(i).name(1:end-4)];
    end

    cd(['mex_src' filesep 'segmentation']);
    eval(['mex mex_extractforeground.cpp src\segment.cpp -Isrc\ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    eval(['mex mex_extractbackground.cpp src\segment.cpp -Isrc\ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    eval(['mex mex_segment.cpp src\segment.cpp -Isrc\ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    movefile('*.mex*', [current_folder filesep 'mex'])
    cd(current_folder);

elseif isunix   % Unix machine
    % set opencv include path
    opencv_include = '/usr/local/include/';
    % set opencv lib path
    opencv_libpath = '/usr/lib/x86_64-linux-gnu/';

    lib = [];
    files = dir([opencv_libpath '*opencv*.so']);
    for i = 1:length(files)
        lib = [lib ' -l' files(i).name(4:end-3)];
    end

    cd(['mex_src' filesep 'segmentation']);
    eval(['mex mex_extractforeground.cpp src/segment.cpp -Isrc/ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    eval(['mex mex_extractbackground.cpp src/segment.cpp -Isrc/ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    eval(['mex mex_segment.cpp src/segment.cpp -Isrc/ -I' opencv_include ' -L' opencv_libpath ' ' lib]);
    movefile('*.mex*', [current_folder filesep 'mex'])
    cd(current_folder);

end
