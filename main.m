clear;close all
addpath('MTFCalculation');
cam = webcam(1);
%%
num_used_region = 5;
criterion = [0.1, 0.3]; % MTF = 0.1 at 0.3 cycle/pixel
im = snapshot(cam);
MTF_mean = measureMTF(im, num_used_region);
subplot(1,2,1);
h = imshow(imresize(im, 0.3, 'nearest'));
ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop', ...
                         'Callback', 'delete(gcbf)');
while 1
    im = snapshot(cam);
    MTF_mean = measureMTF(im, num_used_region);
    set(h,'CData',imresize(im, 0.3, 'nearest'));
    x = linspace(0, 1, length(MTF_mean));
    worse_than_criterion = MTF_mean(floor((length(MTF_mean)*criterion(2)))) < criterion(1);
    subplot(1,2,2);plot(x, MTF_mean);axis([0 1 0 1]);grid on
    title(['Lower than criterion: ', num2str(worse_than_criterion)]);
    drawnow
    if ~ishandle(ButtonHandle)
        break;
    end
end
