function [MTF_mean, MTF, LSF, ESF] = measureMTF(im, num_used_region)

%% rgb2gray if colorful
if size(im,3)==3
    im = rgb2gray(im);
end
%% check checkerboard size
%[imagePoints,boardSize] = detectCheckerboardPoints(im);
%checkerSize = 0.5 * (imagePoints(end,1) - imagePoints(1,1)) / (boardSize(2) - 2) + 0.5*(imagePoints(end,2) - imagePoints(1,2)) / (boardSize(1) - 2);

%% GUI select wanted region
coords = [];
if isfile('coords.mat')
    load('coords.mat')
else
    for i=1:num_used_region
        [~, coord] = getroi(im);
        coords = [coords; coord];
        imshow(im);hold on;rectangle('Position', [coord(1),coord(2),coord(3)-coord(1),coord(4)-coord(2)], 'EdgeColor','r');
    end
    close all;
    save('coords.mat', 'coords');
end

%%
select_regions = {};
for i=1:num_used_region
    select_regions{end+1} = im(coords(i,2):coords(i,4), coords(i,1):coords(i,3));
end

%%
%{
imshow(im);
for i=1:num_used_region
    rectangle('Position', [coords(i,1),coords(i,2),coords(i,3)-coords(i,1),coords(i,4)-coords(i,2)], 'EdgeColor','r');
end
%}
%%
patch_angle = [];
for i=1:num_used_region
    [BW,~,~,~] = edge(select_regions{i},'sobel');
    [~,I] = max(BW(1,:)); top_coord = [1, I];
    [~,I] = max(BW(end,:)); bottom_coord = [size(BW, 1), I];
    [~,I] = max(BW(:,1)); left_coord = [I, 1];
    [~,I] = max(BW(:,end)); right_coord = [I, size(BW, 2)];
    angle_v = vec2deg(bottom_coord - top_coord);
    angle_h = vec2deg(right_coord - left_coord) + 90;
    patch_angle = [patch_angle, (angle_v + angle_h) / 2];
end
patch_angle = mean(patch_angle);

%% check minimum image patch width
min_len = 1e9;
for i=1:num_used_region
    min_len = min([min_len, size(select_regions{i})]);
end

%% im rotation 
for i=1:num_used_region
    image_size = size(select_regions{i});
    select_regions{i} = imrotate(select_regions{i}, patch_angle - 90, 'bicubic', 'crop');
    win = centerCropWindow2d(size(select_regions{i}), floor(0.8*[min_len, min_len]));
    select_regions{i} = imcrop(select_regions{i}, win);
    %figure;imshow(select_regions{i});
end

%% collect array as ESF(edge spread function) and compute LSF(line spread function)
ESF = [];
for i=1:num_used_region
    ESF = [ESF; sortDirection(select_regions{i}(1,:)); sortDirection(select_regions{i}(end,:))];
end
for i=1:num_used_region
    ESF = [ESF; sortDirection(select_regions{i}(:,1)'); sortDirection(select_regions{i}(:,end)')];
end
LSF = diff(ESF,1,2);
%% plot LSF ESF
%{
for i=1:size(LSF, 1)
    plot(LSF(i,:));hold on
end
%}
%% 
MTF = fft(LSF')';
MTF = abs(MTF(:, 1:ceil(size(MTF, 2) / 2)));
MTF_max = max(MTF, [], 2);
MTF_max = repmat(MTF_max, 1, size(MTF, 2));
MTF = MTF./max(MTF_max,1e-10);
MTF_mean = mean(MTF, 1);
MTF_mean = smoothdata(MTF_mean);