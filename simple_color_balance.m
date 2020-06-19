% 对图像进行灰度世界白平衡处理
% 再进行直方图自动对比度调整
function  output = simple_color_balance(image)

num = 255;

r = image(:, :, 1);
g = image(:, :, 2);
b = image(:, :, 3);

Ravg = mean(mean(r));
Gavg = mean(mean(g));
Bavg = mean(mean(b));


Max = max([Ravg, Gavg, Bavg]);
ratio = [Max / Ravg, Max / Gavg, Max / Bavg];

satLevel =  0.005 * ratio;

[m,n,p] = size(image);
imgRGB_orig = zeros(p, m*n);

for i = 1 : p
   imgRGB_orig(i, : ) = reshape(double(image(:, :, i)), [1, m * n]);
end

imRGB = zeros(size(imgRGB_orig));

%直方图对比度调整
for ch = 1 : p
    q = [satLevel(ch), 1 - satLevel(ch)];
    tiles = quantile(imgRGB_orig(ch, :), q);
    temp = imgRGB_orig(ch, :);
    temp(find(temp < tiles(1))) = tiles(1);
    temp(find(temp > tiles(2))) = tiles(2);
    imRGB(ch, :) = temp;
    pmin = min(imRGB(ch, :));
    pmax = max(imRGB(ch, :));
    
% fac(A) = Amin + (A - Alow) * (Amax -Amin)/(Ahigh - Alow)
% 对于8bit图像，Amin = 0，Amax = 255
    imRGB(ch, :)  = (imRGB(ch, :) - pmin) * num /(pmax - pmin);
end

output = zeros(size(image));

for i = 1 : p
        output(:, :, i) = reshape(imRGB(i, :), [m, n]); 
end

output = uint8(output);

end
