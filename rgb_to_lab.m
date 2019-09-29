function lab = rgb_to_lab(rgb)

cform = makecform('srgb2lab');  %rgb转lab公式
lab = applycform(rgb,cform);    %lab格式

end