pkg load image;

function LP = create_laplace_pyramid(img)
    % Check if the image is grayscale, if not convert it to grayscale
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Calculate sigma as 1% of the image dimension
    sigma = 0.01 * min(size(img));

    % Create the Laplacian pyramid
    laplace_pyramid = {};

    % Generate the Gaussian pyramid
    gaussian_pyramid = {};
    gaussian_pyramid{1} = img;

    % Create the Gaussian pyramid
    for i = 2:5  % You can change the number of levels as needed
        gaussian_pyramid{i} = imgaussfilt(gaussian_pyramid{i-1}, sigma);
    end

    % Generate the Laplacian pyramid
    for i = 1:(length(gaussian_pyramid) - 1)
        % Compute the Laplacian by subtracting Gaussian pyramid from the next level
        laplace_pyramid{i} = gaussian_pyramid{i} - imresize(gaussian_pyramid{i+1}, size(gaussian_pyramid{i}));
    end

    % Add the last level of the Gaussian pyramid to the Laplacian pyramid
    laplace_pyramid{end+1} = gaussian_pyramid{end};

    % Return the Laplacian pyramid
    return;
end


function GP = createGaussianPyramidForMask(img, levels=5, white_left=true)
  % Create the mask: half black, half white
  [rows, cols, ~] = size(img);
  mask = zeros(rows, cols);
  if white_left
    mask(:, 1:floor(cols / 2)) = 1;  % Left half white, right half black
  else
    mask(1:floor(cols / 2), :) = 1;  % Right half white, left half black
  endif

  % Apply Gaussian filter with sigma = 0.5% of image dimensions
  sigma = 0.005 * max(rows, cols);  % Sigma is 0.5% of the largest dimension
  mask_filtered = imgaussfilt(mask, sigma);  % Apply Gaussian filter

  % Create the Gaussian pyramid
  pyramid = cell(1, levels);  % Initialize cell array for pyramid
  pyramid{1} = mask_filtered;  % First level of the pyramid is the filtered mask

  % Generate remaining levels of the pyramid
  for i = 2:levels
    mask_filtered = imresize(mask_filtered, 0.5);  % Downsample the mask
    pyramid{i} = imgaussfilt(mask_filtered, sigma);  % Apply Gaussian filter
  end
end


