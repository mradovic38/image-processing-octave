pkg load image;

% Inspired by:
% https://www.researchgate.net/publication/281392911_AReview_of_Classic_Edge_Detectors

function edges = marr_hildreth_edge_detection(img, sigma, threshold)
    img = im2double(img);
    [rows, cols] = size(img);

    % Create Gaussian filter
    kernel_size = 2 * ceil(3 * sigma) + 1;
    [X, Y] = meshgrid(-(kernel_size-1)/2:(kernel_size-1)/2, -(kernel_size-1)/2:(kernel_size-1)/2);
    gauss_kernel = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    gauss_kernel = gauss_kernel / sum(gauss_kernel(:));

    % Padding
    pad_size = floor(kernel_size / 2);
    padded_img = padarray(img, [pad_size, pad_size], 'replicate');

    % Apply Gaussian Filter
    smoothed_img = zeros(rows, cols);

    for r = 1:rows
        for c = 1:cols
            region = padded_img(r:r+kernel_size-1, c:c+kernel_size-1);
            smoothed_img(r, c) = sum(sum(region .* gauss_kernel));
        end
    end


    % Create Laplacian filter
    laplacian_kernel = zeros(3, 3);
    laplacian_kernel = [1 1 1; 1 -8 1; 1 1 1];

    laplacian_img = zeros(rows, cols);
    padded_smoothed_img = padarray(smoothed_img, [1, 1], 'replicate');

    % Apply Laplacian filter
    for r = 1:rows
        for c = 1:cols
            region = padded_smoothed_img(r:r+2, c:c+2);
            laplacian_img(r, c) = sum(sum(region .* laplacian_kernel));
        end
    end

    % Zero-crossing
    max_LoG = max(abs(laplacian_img(:)));
    threshold = threshold * max_LoG;

    edges = zeros(rows, cols);

    for r = 2:rows-1
        for c = 2:cols-1
            p1 = laplacian_img(r-1, c);  % uo
            p2 = laplacian_img(r+1, c);  % down
            p3 = laplacian_img(r, c-1);  % left
            p4 = laplacian_img(r, c+1);  % right
            p5 = laplacian_img(r-1, c-1);  % up-left
            p6 = laplacian_img(r-1, c+1);  % up-right
            p7 = laplacian_img(r+1, c-1);  % down-left
            p8 = laplacian_img(r+1, c+1);  % down-right

            % Zero-crossing for the opposite surrounding pixels
            if (sign(p1) ~= sign(p2)) && (abs(p1 - p2) > threshold)  % Vertical check
                edges(r, c) = 1;
            elseif (sign(p3) ~= sign(p4)) && (abs(p3 - p4) > threshold)  % Horizontal check
                edges(r, c) = 1;
            elseif (sign(p5) ~= sign(p8)) && (abs(p5 - p8) > threshold)  % Diagonal check 1
                edges(r, c) = 1;
            elseif (sign(p6) ~= sign(p7)) && (abs(p6 - p7) > threshold)  % Diagonal check 2
                edges(r, c) = 1;
            else
                edges(r, c) = 0;
            end
        end
    end
end


img = imread('images/headCT.tif');

edges = marr_hildreth_edge_detection(img, 3, .1);

figure;
subplot(1, 2, 1);
imshow(img);
title('Original');

subplot(1, 2, 2);
imshow(edges);
title('Marr-Hildreth (sigma = 3, zero-crossing threshold = 10%)');



