pkg load image;

% A hybrid image is created by combining the image of a dog and a cat.
% The image of the dog is filtered with a lowpass filter, then the image of the cat
% filtered with a highpass filter (the difference between the original and the lowpass filtered cat image).
% The final hybrid image is obtained by adding these two images together. The resulting image
% looks more like a cat when seen up close, and a dog when seen from a distance.
% Thus, the properties of an image that has been filtered with a highpass filter
% dominate closely, and the properties of the lowpass filtered image are
% more dominant from afar.

function hybrid_img = create_hybrid_image(low_img, high_img, sigma_low, sigma_high)
    low_img = im2double(low_img);
    high_img = im2double(high_img);

    % Gaussian filter
    kernel_size_low = 2 * ceil(3 * sigma_low) + 1;
    kernel_size_high = 2 * ceil(3 * sigma_high) + 1;

    % Lowpass
    low_pass_filter = fspecial('gaussian', kernel_size_low, sigma_low);
    low_freqs = imfilter(low_img, low_pass_filter, 'replicate');

    figure;
    imshow(low_freqs, []);
    title('Lowpass filtered image');

    % Highpass = Original - Lowpass
    high_pass_filter = fspecial('gaussian', kernel_size_high, sigma_high);
    high_img_low_freqs = imfilter(high_img, high_pass_filter, 'replicate');
    high_freqs = high_img - high_img_low_freqs;

    figure;
    imshow(high_freqs, []);
    title('Highpass filtered image');

    % Combining
    hybrid_img = low_freqs + high_freqs;

    % Cap between 0 and 1
    hybrid_img = max(0, min(1, hybrid_img));
end

dog_img = imread('images/dog.jpg');
cat_img = imread('images/cat.jpg');

% Sigma values
sigma_low = 10;
sigma_high = 2;

hybrid_img = create_hybrid_image(dog_img, cat_img, sigma_low, sigma_high);

figure;
imshow(dog_img);
title('Low freqs from:');

figure;
imshow(cat_img);
title('High freqs from:');

figure;
imshow(hybrid_img);
title('Hybrid image');

