pkg load image;

function [filt_decimac_1d, filt_interp_1d] = generate_pyramid_filters(dim)
    % 1% of image dimensions
    sigma = 0.01 * dim;

    % Decimation filter
    filter_size = ceil(6 * sigma);
    filt_decimac_1d = fspecial('gaussian', [1, filter_size], sigma);

    % Interpolation filter
    filt_interp_1d = 2 * filt_decimac_1d;
end


function filtered = apply_separable_filter(image, filter_1d)
    % Apply the filter vertically and horizontally
    if ndims(image) == 3
        filtered = zeros(size(image));
        for ch = 1:size(image, 3)
            im_f_1D = imfilter(image(:,:,ch), filter_1d', 'replicate');
            filtered(:,:,ch) = imfilter(im_f_1D, filter_1d, 'replicate');
        end
    else
        im_f_1D = imfilter(image, filter_1d', 'replicate');
        filtered = imfilter(im_f_1D, filter_1d, 'replicate');
    end
end

function down = downsample_image(image, filt_decimac_1d)
    % Downsampling
    filtered = apply_separable_filter(image, filt_decimac_1d);
    if ndims(image) == 3
        down = filtered(1:2:end, 1:2:end, :);
    else
        down = filtered(1:2:end, 1:2:end);
    end
end

function up = upsample_image(image, filt_interp_1d, target_size)
    % Upsampling
    if ndims(image) == 3
        up = zeros(target_size);
        for ch = 1:size(image, 3)
            temp = zeros(target_size(1), target_size(2));
            temp(1:2:end, 1:2:end) = image(:,:,ch);
            up(:,:,ch) = apply_separable_filter(temp, filt_interp_1d);
        end
    else
        up = zeros(target_size);
        up(1:2:end, 1:2:end) = image;
        up = apply_separable_filter(up, filt_interp_1d);
    end
end

function pyramid = build_gaussian_pyramid(image, levels, filt_decimac_1d)
    % Create Gaussian pyramid
    pyramid = cell(levels, 1);
    pyramid{1} = image;

    for i = 2:levels

        pyramid{i} = downsample_image(pyramid{i-1}, filt_decimac_1d);
    end
end

function pyramid = build_laplacian_pyramid(image, levels, filt_decimac_1d, filt_interp_1d)
    % Create Gaussian pyramid
    gaussian_pyramid = build_gaussian_pyramid(image, levels, filt_decimac_1d);
    pyramid = cell(levels, 1);

    % Create Laplacian pyramid using the Gaussian pyramid
    for i = 1:levels-1
        current_size = size(gaussian_pyramid{i});
        upsampled = upsample_image(gaussian_pyramid{i+1}, filt_interp_1d, [current_size(1), current_size(2)]);
        pyramid{i} = gaussian_pyramid{i} - upsampled;
    end

    % The last level of Laplacian pyramid is the last level of the Gaussian pyramid
    pyramid{levels} = gaussian_pyramid{levels};
end

function mask_pyramid = build_mask_pyramid(mask, levels, filt_decimac_1d)
    % Filter using Gaussian filter with sigma=0.5% dimensions of the mask
    sigma_mask = 0.005 * min(size(mask, 1), size(mask, 2));
    filter_size = ceil(6 * sigma_mask);
    mask_filter = fspecial('gaussian', [filter_size, filter_size], sigma_mask);
    mask = imfilter(mask, mask_filter, 'replicate');

    % Build Gaussian pyramid
    mask_pyramid = cell(levels, 1);
    mask_pyramid{1} = mask;

    for i = 2:levels
        mask_pyramid{i} = downsample_image(mask_pyramid{i-1}, filt_decimac_1d);
    end
end

function blended = blend_pyramids(pyr_A, pyr_B, mask_pyr)
    % Blends two images using LAB = LA*GMA + LB*GMB
    levels = length(pyr_A);
    blended = cell(levels, 1);

    for i = 1:levels
        mask = repmat(mask_pyr{i}, [1, 1, size(pyr_A{i}, 3)]);
        blended{i} = pyr_A{i} .* mask + pyr_B{i} .* (1 - mask);
    end
end

function reconstructed = reconstruct_from_laplacian(pyramid, filt_interp_1d)
    % Reconstruction from Laplacian pyramid
    levels = length(pyramid);
    reconstructed = pyramid{levels};

    for i = levels-1:-1:1
        target_size = [size(pyramid{i}, 1), size(pyramid{i}, 2)];
        upsampled = upsample_image(reconstructed, filt_interp_1d, target_size);
        reconstructed = upsampled + pyramid{i};
    end
end


function result = multi_resolution_blend(A, B, mask, levels, visualize=false)
    % Generate decimation and interpolation filters
    dim = min(size(A, 1), size(A, 2));
    [filt_decimac_1d, filt_interp_1d] = generate_pyramid_filters(dim);

    % Laplacian pyramids of both images
    LA = build_laplacian_pyramid(A, levels, filt_decimac_1d, filt_interp_1d);
    LB = build_laplacian_pyramid(B, levels, filt_decimac_1d, filt_interp_1d);

    % Gaussian pyramid of the mask
    mask_pyr = build_mask_pyramid(mask, levels, filt_decimac_1d);


    % Bledning
    blended_pyr = blend_pyramids(LA, LB, mask_pyr);

    % Visualization
    if visualize
      visualize_laplacian_pyramid(LA);
      visualize_laplacian_pyramid(LB);
      visualize_gaussian_pyramid(mask_pyr);
      visualize_laplacian_pyramid(blended_pyr);
    endif


    % Reconstruction
    result = reconstruct_from_laplacian(blended_pyr, filt_interp_1d);
end

function visualize_gaussian_pyramid(gaussian_pyramid)
  levels = length(gaussian_pyramid);

  figure;
  for i = 1:levels
      subplot(1, levels, i);
      imshow(gaussian_pyramid{i});
      title(sprintf('Level %d', i));
  end
end


function visualize_laplacian_pyramid(laplacian_pyramid)
  levels = length(laplacian_pyramid);

  figure;
  for i = 1:levels
      laplacian_level = laplacian_pyramid{i};

      % Normalize for visualization
      min_val = min(laplacian_level(:));
      max_val = max(laplacian_level(:));
      normalized_laplacian = (laplacian_level - min_val) / (max_val - min_val + eps);

      subplot(1, levels, i);
      imshow(normalized_laplacian, []);
      title(sprintf('Level %d', i));
  end
end


levels = 5;

A = im2double(imread('images/apple.jpeg'));
B = im2double(imread('images/orange.jpeg'));

[rows, cols, ~] = size(A);
B = imresize(B, [rows, cols]);
mask = zeros(rows, cols);
mask(:, 1:floor(cols/2)) = 1;  % Left part is white

result = multi_resolution_blend(A, B, mask, levels);


figure;

subplot(2, 2, 1);
imshow(A);
title('Image A');

subplot(2, 2, 2);
imshow(B);
title('Image B');

subplot(2, 2, 3);
imshow(mask);
title('Blending Mask');

subplot(2, 2, 4);
imshow(result);
title('Blended Result');
