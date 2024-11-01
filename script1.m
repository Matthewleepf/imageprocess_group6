clc;
clear;
close all;

% get one slice of the dicom file
dicom_file = 'SubjectB_T1_DICOM\IMG0069.dcm'; % choose one slice of the dicom file
image_data = dicomread(dicom_file);
image_data = double(image_data);% change to double format to process 

% show the original image
figure;
imshow(image_data,[]);
title('Original Image');

% 1. high frequency pass filter
% here we creat the high frequency pass filter is laplace filter
hp_filter = fspecial('laplacian', 0.5); % laplace high pass filter, 0.5 is the operator, the higher, the edge of the target in image is sharper
high_pass_img = imfilter(image_data, hp_filter, 'replicate'); % apply the dilter to the image. replicate is to copy the value of boundary pixels while convolution

% show the high pass filter iamge
figure;
subplot(2,2,1);
imshow(high_pass_img, []);
title('High Pass Filtered Image');

% 2. low frequency pass filter
% here we creat the low frequency pass filter is gaussian filter
lp_filter = fspecial('gaussian', [15 15], 5); % size of the filter is [15, 15], 5 is standard deviation, the bigger the size and deviation, the smoother,
low_pass_img = imfilter(image_data, lp_filter, 'replicate');

% show low pass filter result
subplot(2,2,2);
imshow(low_pass_img, []);
title('Low Pass Filtered Image');

% 3. add gaussian noise
noisy_img = imnoise(uint8(image_data), 'gaussian', 0, 0.01); % the mean of the noise is 0 to make sure the brightness of the image unchanged, variance is 0.01

% show the noise image
subplot(2,2,3);
imshow(noisy_img, []);
title('Image with Gaussian Noise');

% 4. denoising in frequency domain with low pass filter
% transform to frequency domain
noisy_img_fft = fftshift(fft2(noisy_img));% move the low frequency to the center, and high frequency will be in the boundary

% magnitude_spectrum = abs(noisy_img_fft);
% magnitude_spectrum = log(1 + magnitude_spectrum);  % enhance the result
% figure;
% imshow(magnitude_spectrum, []);  % show the magnitude_spectrum
% title('Magnitude Spectrum');



% design a low pass filter to denoise
[rows, cols] = size(noisy_img);
[u, v] = meshgrid(-floor(cols/2):floor((cols-1)/2), -floor(rows/2):floor((rows-1)/2));% creat the 2d matrix to store the location of all points in graph
D = sqrt(u.^2 + v.^2); % get the distance of all points
D0 = 36; % cut off frequency, lower than this frequency will keep, higher will be decline
low_pass_filter = exp(-(D.^2) / (2 * (D0^2)));

% apply the low pass filter
smoothed_fft = noisy_img_fft .* low_pass_filter; % by multiply the frequency domain element with the filter to revalue the element

% transform to space domain
smoothed_img = real(ifft2(ifftshift(smoothed_fft)));

% show the graph after denoising
subplot(2,2,4);
imshow(smoothed_img, []);
title('Filtered Image after Noise Reduction');

% show the gaussian filter
figure;
imshow(low_pass_filter, []);
title('Gaussian Low Pass Filter');
xlabel('Frequency (u)');
ylabel('Frequency (v)');
colorbar; 