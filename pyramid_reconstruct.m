function output = pyramid_reconstruct(pyramid)

level = length(pyramid);

for i = level : -1 :2
    [m, n] = size(pyramid{i - 1});
    pyramid{i - 1} = pyramid{i -1} + imresize(pyramid{i}, [m, n]);
end

output = pyramid{1};
end
