clc; clear;close all;


image = imread('SheppLogan_Phantom.svg.png');
image = imresize(image(:, :, 1), [512, 512]);
% image = padarray(image_real, [0 0], 0, 'both');
[height, width] = size(image);


y_theta = 0:0.5:179.5;

radon_image = radon(image, y_theta);
radon_image = imrotate(radon_image, 90);

G = fftshift(fft(radon_image, size(radon_image,2), 2), 2);

omega = linspace(-size(G,2), size(G,2),size(G,2));
D0 = 110;
ideal_lowpass = zeros(size(G));
ideal_lowpass(:, floor(364.5-D0/2):floor(364.5+D0/2)) = 1;

Hamming= zeros(size(G));
Hamming(:, floor(364.5-D0):floor(364.5+D0)) = repmat(0.54 + (0.54-1).*cos(2.*pi.*abs(0:D0*2)./(D0.*2))...
    , 360, 1);
Hann = zeros(size(G));
Hann(:, floor(364.5-D0):floor(364.5+D0)) = repmat(0.5 + (0.5-1).*cos(2.*pi.*abs(0:D0*2)./(D0.*2))...
    , 360, 1);

recovered_image = zeros(size(radon_image, 2), size(radon_image, 2));

% figure('Position',[0 200 600 600])
% imshow(image, [])
figure
for i=360:-1:1
    first_integrand = G.*abs(omega) ;
    second_integrand = real(ifft(ifftshift(first_integrand,2), size(radon_image,2), 2));
    slice = second_integrand(360-i+1, :);
    ro_s = repmat(slice, size(radon_image,2), 1);
    recovered_image = recovered_image+ imrotate(ro_s, y_theta(i), "bilinear", 'crop');
    imshow(recovered_image, [])
    drawnow    
    exportgraphics(gca,"inverse_radon.gif","Append",true, 'Resolution', 60, 'Colorspace', 'gray')
    % pause(0.00005)
end




