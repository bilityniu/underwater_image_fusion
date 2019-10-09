%¡¶Enhancing Underwater Images and Videos by Fusion¡· code
clc;
clear all;
close all;

path = "./images/6.jpg";

image = imread(path);
figure,imshow(image),title("origin image");

tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deal with input image for fusion
% input1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img1 = simple_color_balance(image);
lab1 = rgb_to_lab(img1);    %rgb change to lab

figure,subplot(1,2,1),imshow(img1),title("imupt1 image");


% input2
lab2 = lab1;

% bilateralFilter deal with luminance channel
lab2(:, :, 1) = uint8(bilateralFilter(double(lab2(:, :, 1))));
%lab2(:, :, 1) = uint8(guidedfilter(double(rgb2gray(image)),double(lab2(:, :, 1)), 15*4, 10^-6) );

% adaptive histogram equalization
lab2(:, :, 1) = adapthisteq(lab2(:, :, 1));
img2 = lab_to_rgb(lab2);

subplot(1,2,2),imshow(img2),title("imupt2 image");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate weight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R1 = double(lab1(:, :, 1)/255);
R2 = double(lab2(:, :, 1)/255);

%1. Laplacian contrast weight (Laplacian filiter on input luminance channel)
WL1 = abs(imfilter(R1, fspecial('Laplacian'), 'replicate', 'conv')); 
WL2 = abs(imfilter(R2, fspecial('Laplacian'), 'replicate', 'conv')); 

% 2. Local contrast weight
h = 1/16 * [1, 4, 6, 4, 1];

whc = pi / 2.75;  % high frequency cut-off value

WLC1 = imfilter(R1, h' * h, 'replicate', 'conv');
WLC1(find(WLC1 > whc)) = whc;   
WLC1 = (R1 - WLC1).^2;

WLC2 = imfilter(R2, h' * h, 'replicate', 'conv');
WLC2(find(WLC2 > whc)) = whc;
WLC2 = (R2 - WLC2).^2;

% 3. Saliency weight
WS1 = saliency_detection(img1);
WS2 = saliency_detection(img2);

% 4. Exposedness weight
average = 0.5;
sigma = 0.25;

WE1 = exp(-(R1 - average).^2 / (2 * sigma^2));
WE2 = exp(-(R2 - average).^2 / (2 * sigma^2));

% normalized weight
W1 = (WL1 + WLC1 + WS1 + WE1) ./ (WL1 + WLC1 + WS1 + WE1 + WL2 + WLC2 + WS2 + WE2);
W2 = (WL2 + WLC2 + WS2 + WE2) ./ (WL1 + WLC1 + WS1 + WE1 + WL2 + WLC2 + WS2 + WE2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% image fusion
% R(x,y) = sum G{W} * L{I}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
level = 5;

% weight gaussian pyramid
Weight1 = gaussian_pyramid(W1, level);
Weight2 = gaussian_pyramid(W2, level);

% image laplacian pyramid
% input1
r1 = laplacian_pyramid(double(double(img1(:, :, 1))), level);
g1 = laplacian_pyramid(double(double(img1(:, :, 2))), level);
b1 = laplacian_pyramid(double(double(img1(:, :, 3))), level);
% input2
r2 = laplacian_pyramid(double(double(img2(:, :, 1))), level);
g2 = laplacian_pyramid(double(double(img2(:, :, 2))), level);
b2 = laplacian_pyramid(double(double(img2(:, :, 3))), level);

% fusion
for i = 1 : level
    R_r{i} = Weight1{i} .* r1{i} + Weight2{i} .* r2{i};
    G_g{i} = Weight1{i} .* g1{i} + Weight2{i} .* g2{i};
    B_b{i} = Weight1{i} .* b1{i} + Weight2{i} .* b2{i};
end

% pyramin reconstruct
R = pyramid_reconstruct(R_r);
G = pyramid_reconstruct(G_g);
B = pyramid_reconstruct(B_b);

fusion = cat(3, uint8(R), uint8(G),uint8(B));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

toc;
figure,imshow(fusion),title("fusion image");


