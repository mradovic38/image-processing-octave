pkg load image;

function filtered_img = f_linFilt(img, kernel)
    img = im2double(img);

    % Flip the kernel
    kernel = kernel(end:-1:1, end:-1:1);

    % Image and kernel size
    [rows, cols] = size(img);
    [kernel_rows, kernel_cols] = size(kernel);

    filtered_img = zeros(rows, cols);

    % Paddding
    pad_rows = floor(kernel_rows / 2);
    pad_cols = floor(kernel_cols / 2);

    % Copy the image to the center
    padded_img = zeros(rows + 2 * pad_rows, cols + 2 * pad_cols);
    padded_img(pad_rows+1:end-pad_rows, pad_cols+1:end-pad_cols) = img;

    % Padding for up and down rows
    padded_img(1:pad_rows, pad_cols+1:end-pad_cols) = repmat(img(1, :), pad_rows, 1);
    padded_img(end-pad_rows+1:end, pad_cols+1:end-pad_cols) = repmat(img(end, :), pad_rows, 1);

    % Padding for left and right columns
    padded_img(pad_rows+1:end-pad_rows, 1:pad_cols) = repmat(img(:, 1), 1, pad_cols);
    padded_img(pad_rows+1:end-pad_rows, end-pad_cols+1:end) = repmat(img(:, end), 1, pad_cols);

    % Padding for corners
    padded_img(1:pad_rows, 1:pad_cols) = img(1, 1);
    padded_img(1:pad_rows, end-pad_cols+1:end) = img(1, end);
    padded_img(end-pad_rows+1:end, 1:pad_cols) = img(end, 1);
    padded_img(end-pad_rows+1:end, end-pad_cols+1:end) = img(end, end);

    % Convolution
    for r = 1:rows
        for c = 1:cols
            region = padded_img(r:r+kernel_rows-1, c:c+kernel_cols-1);
            filtered_img(r, c) = sum(sum(region .* kernel));
        end
    end
end

img = imread('images/testpattern1024.tif');

sigma_vals = [1, 3, 7];

% Original image
figure;
subplot(2, 2, 1);
imshow(img);
title('Original');

for i = 1:length(sigma_vals)
    sigma = sigma_vals(i);

    % Kernel siz
    kernel_size = 2 * ceil(3 * sigma) + 1;

    % Gaussian filtering
    [X, Y] = meshgrid(-(kernel_size-1)/2:(kernel_size-1)/2, -(kernel_size-1)/2:(kernel_size-1)/2);
    gauss_kernel = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    gauss_kernel = gauss_kernel / sum(gauss_kernel(:));


    filtered_img = f_linFilt(img, gauss_kernel);

    filtered_img_2 = imfilter(img, gauss_kernel, 'replicate');

    raz = filtered_img - filtered_img_2;

    % Print the differences between built-in function and this manual implementation
    max(raz(:))

    % Show gaussian filtered image
    subplot(2, 2, i+1);
    imshow(filtered_img);
    title(['Gaussian Filter (sigma = ', num2str(sigma), ')']);
end


