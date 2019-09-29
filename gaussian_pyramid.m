% 高斯金字塔实现步骤：
% 1. 对j级图像进行一个滤波处理（高斯金字塔则采用高斯低通滤波）;
% 2. 对j级图像进行步长2的下采样操作，得到 j-1 级图像;
% 3. 对上1,2步进行迭代操作，直到输出第0级图像结束。

function output = gaussian_pyramid(image, level)

h =1/16 * [1, 4, 6, 4, 1];
filt = h' * h;

% filt = 1/256 * [ 1  4  6  4 1;      % 高斯内核
%                 4 16 24 16 4;
%                 6 24 36 24 6;
%                 4 16 24 16 4;
%                 1  4  6  4 1 ];
             
output{1} = imfilter(image, filt, 'replicate', 'conv');
temp_img = image;

for i = 2 : level
    temp_img = temp_img(1: 2: end, 1: 2: end);  %向下采样，缩小图像，步长为2
    output{i} = imfilter(temp_img, filt, 'replicate', 'conv'); 
end

end
