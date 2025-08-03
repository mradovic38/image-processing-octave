pkg load image;


function [pyr, pind] = buildWaveletLift(img, levels)
    % Pyramid inicialization and indexing
    pyr = cell(levels, 1);
    pind = [];

    current_img = img;

    for level = 1:levels
        % Split rows to even and odd indices
        s0_odd = current_img(1:2:end, :);
        s0_even = current_img(2:2:end, :);

        % Details and smoothing
        d1 = s0_odd - s0_even;
        s1 = s0_even + floor(0.5 * d1);

        % Split s1 by columns to even and odd indices
        s11_odd = s1(:, 1:2:end);
        s11_even = s1(:, 2:2:end);

        % Details and smoothing
        d21 = s11_odd - s11_even;
        s21 = s11_even + floor(0.5 * d21);

        % Split d1 by columns to even and odd indices
        s12_odd = d1(:, 1:2:end);
        s12_even = d1(:, 2:2:end);

        % Details and smoothing
        d22 = s12_odd - s12_even;
        s22 = s12_even + floor(0.5 * d22);

        % Put coefficients to cell and sizes to pind
        pyr{3*level-2} = d21;  % Detalji
        pyr{3*level-1} = d22;  % Detalji
        pyr{3*level} = s22;    % Detalji
        pyr{3*level+1} = s21;  % Aproksimacija

        pind = [pind; size(d21); size(d22); size(s22); size(s21)];

        % For the next level
        current_img = s21;
    end

end




function img_reconstructed = reconstructWaveletLift(pyr, pind, levels)
    % Last from pyr
    current_img = reshape(pyr{end}, pind(end,:));

    % Iterate from the back
    for level = levels:-1:1
        % Get sizes using pind
        idx = (level-1)*4 + 1;
        d21_size = pind(idx, :);
        d22_size = pind(idx+1, :);
        s22_size = pind(idx+2, :);
        s21_size = pind(idx+3, :);

        % Take the values needed for calculating the reconstruction
        d21 = reshape(pyr{3*level-2}, d21_size);
        d22 = reshape(pyr{3*level-1}, d22_size);
        s22 = reshape(pyr{3*level}, s22_size);

        % Reconstruct columns from d1
        s12_even = s22 - floor(0.5 * d22);
        s12_odd = d22 + s12_even;
        d1 = zeros(size(s12_even, 1), 2*size(s12_even, 2));
        d1(:, 1:2:end) = s12_odd;
        d1(:, 2:2:end) = s12_even;

        % Reconstruct columns from s1
        s11_even = current_img - floor(0.5 * d21);
        s11_odd = d21 + s11_even;
        s1 = zeros(size(s11_even, 1), 2*size(s11_even, 2));
        s1(:, 1:2:end) = s11_odd;
        s1(:, 2:2:end) = s11_even;

        % Reconstruct rows
        s0_even = s1 - floor(0.5 * d1);
        s0_odd = d1 + s0_even;

        % Combine odd and even
        current_img = zeros(2*size(s0_even, 1), size(s0_even, 2));
        current_img(1:2:end, :) = s0_odd;
        current_img(2:2:end, :) = s0_even;
    end


    img_reconstructed = current_img;
end

image = double(imread('images/testpattern512.tif'));

levels = 1;

[pyr, pind] = buildWaveletLift(image, levels);

img_reconstructed = reconstructWaveletLift(pyr, pind, levels);

disp("Difference from original:");
min(min(image - img_reconstructed))
max(max(image - img_reconstructed))

figure;
imshow(img_reconstructed, []);
title("Reconstructed image");


pyr{end} = zeros(size(pyr{end}));
img_reconstructed = reconstructWaveletLift(pyr, pind, levels);

figure;
imshow(img_reconstructed, []);
title("Isolated edges");
