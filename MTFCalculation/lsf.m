function lsf(im)
    im=rgb2gray(im);
    im=im2double(im);
    figure('Name', 'Origin edge')
    imshow(im);
    
    diffim=diff(im,1,2);
    absdiff=abs(diffim);
    %Find the position of the edge
    [~,x]=max(absdiff,[],2);
    hold on;
    plot(x,1:size(x));
    %Fitting the edge then find the new edge position
    coeffs = polyfit(1:size(x),x', 1);
    fittedY = 1:size(x);
    fittedX=polyval(coeffs,fittedY);
    shift_x = repmat(-6:0.1:6,size(x),1)+ fittedX';
    shift_y = repmat(fittedY',1,size(shift_x,2));
    
    % Show the new edge and two boundary lines
    plot(fittedX,fittedY,'r');
    plot(shift_x(:,1)',fittedY,'r');
    plot(shift_x(:,end)',fittedY,'r');
    newim=interpolation(shift_x,shift_y,im);
    figure('Name', 'Re-order edge image')
    imshow(newim);
    %Find the ESF
    esf=sum(newim,1);
    figure('Name', 'ESF and LSF')
    plot(esf);
    %Find the LSF
    lsf=diff(esf);
    hold on
    plot(-lsf*20)
    legend('ESF','LSF')
% %     apply fft to filt out the big frequency signal
%     fft_lsf=fft(lsf);
%     rect1=ones(1,size(fft_lsf,1));
%     rect1(10:end-10)=0;
%     ifft_lsf=fft_lsf.*rect1;
%     figure('Name', 'LSF apply fft')
%     plot(ifft(ifft_lsf));
end
