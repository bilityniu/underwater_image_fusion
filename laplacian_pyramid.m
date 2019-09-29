% 拉普拉斯金字塔（作用：重建高斯金字塔）
function output = laplacian_pyramid(image, level)

h = 1/16 * [1, 4, 6, 4, 1];
filt = h'* h;

output{1} = image;
temp_img = image;

for i = 2 : level   % 滤波，下采样
    temp_img = temp_img(1: 2: end, 1: 2: end);
    output{i} = imfilter(temp_img, filt, 'replicate', 'conv'); 
end

% 计算预测残差，重建后的图像减去原始的第j级输入图像
% 即第i层为高斯金字塔i层与 i+1 层经过内插放大后图像的差
for i = 1 : level - 1
   [m, n] = size(output{i});
   output{i} = output{i} - imresize(output{i + 1}, [m, n]); 
end

end
