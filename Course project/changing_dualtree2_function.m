clc; clear; close all;

image_original = imread('WDC_ADS40_Color_6Inch_2-web.jpg');
image_original = rgb2gray(image_original);
image_original = imresize(image_original, [512 512]);
image_lower_res = single(imresize(image_original, 1./2, "bicubic"));
alpha = 2; beta = 1;

[a, d] = dualtree2(image_lower_res, 'Level',1, 'LevelOneFilter','legall');
[n, m] = dualtree2(image_original, 'Level',1, 'LevelOneFilter','legall');


imrec = my_idualtree2(a, d, imresize(image_lower_res, size(image_original),"bicubic"));


figure
imshow(image_lower_res, [0 255])
title('Low resolution image')

figure
imshow(image_original, [0 255])
title('Original Image')

tiledlayout(1,2)

% First plot
ax1 = nexttile;
imshow(imresize(image_lower_res, alpha, "bicubic"), [0 255])
title('Bicubic interpolation')

% Second plot
ax2 = nexttile;
imshow(imrec, [0 255])
title('CWT-super resolution')

linkaxes([ax1 ax2],'xy')


disp(psnr(imresize(image_lower_res, size(image_original), "bicubic"), single(image_original),255))
disp(psnr(uint8(round(imrec)), image_original, 255))

function X = complex2Quad(Z,gain)

if nargin < 2
    gain = 1;
end

[Nr,Nc,Nchan,~,NIm] = size(Z);
X = coder.nullcopy(zeros([2*Nr 2*Nc Nchan NIm],'like',real(Z)));
%X = coder.nullcopy(zeros([2*Nr 2*Nc Nchan 1 NIm],'like',real(Z)));

% gain here is a column vector
scalfac = 1/sqrt(2)*gain;
P = Z(:,:,:,1,:)*scalfac(1)+Z(:,:,:,2,:)*scalfac(2);
Q = Z(:,:,:,1,:)*scalfac(1)-Z(:,:,:,2,:)*scalfac(2);
X(1:2:2*Nr,1:2:2*Nc,:,:)  = real(P);
X(1:2:2*Nr,2:2:2*Nc,:,:)  = imag(P);
X(2:2:2*Nr,1:2:2*Nc,:,:)  = imag(Q);
X(2:2:2*Nr,2:2:2*Nc,:,:)  = -real(Q);
end
