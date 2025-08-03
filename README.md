# Image Processing with Octave
This repository demonstrates various image processing techniques implemented using [GNU Octave](https://www.gnu.org/software/octave/). The aim is to showcase foundational methods in image filtering, enhancement, and analysis, ideal for learning and experimentation.


## 🚀 Getting Started

### Requirements

- GNU Octave (version ≥ 6.0 recommended)
- Image package:  
  Open Octave and run:
  ```octave
  pkg install -forge image
  pkg load image
  ```
### Running the Scripts
Clone the repository and run any `.m` file (except `helper_functions.m`):
```bash
git clone https://github.com/yourusername/image-processing-octave.git
cd image-processing-octave
octave technique1.m
```

## 🧪 Techniques Implemented

### 1. Linear Gaussian Filtering (Manual vs Built-in)
This script demonstrates linear spatial filtering using a Gaussian kernel to achieve image blurring. Gaussian blur is a fundamental technique in image processing used for noise reduction and smoothing. The method works by convolving the image with a kernel derived from the Gaussian function, which applies a weighted average over each pixel’s neighborhood.

In this implementation, we manually perform convolution using a custom function `f_linFilt`:
- The kernel is flipped as per convolution requirements.
- The image is padded using replicated edge values to avoid boundary artifacts.
- Each pixel is processed by multiplying its local neighborhood with the kernel and summing the result.

To validate our implementation, we compare its results with Octave's built-in `imfilter` function using the same kernel. The script calculates and prints the difference between the two outputs to verify correctness.

Multiple sigma values (`σ = 1, 3, 7`) are used to observe how the degree of blurring increases with larger Gaussian kernels. A visual comparison is provided using subplots showing the original image and the outputs for different sigmas.

This exercise reinforces understanding of convolution, kernel design, image padding, and Gaussian filtering fundamentals.

<img src="https://github.com/user-attachments/assets/384fc8c4-ecad-4d95-b992-5974fe7ad0ed" width="50%">

### 2. Marr-Hildreth Edge Detection
This script implements the Marr-Hildreth edge detection technique, which is based on the Laplacian of Gaussian (LoG) operator. The method identifies edges by locating zero-crossings in the second derivative of the image intensity.

**Steps involved:**
1. **Smoothing with Gaussian Filter**: The input image is first smoothed using a Gaussian filter to reduce noise and irrelevant details. A custom convolution is used for this step, similar to the linear filtering in Technique 1.
2. **Applying Laplacian Operator**: The Laplacian kernel is convolved with the smoothed image to highlight regions of rapid intensity change.
3. **Zero-Crossing Detection**: Edges are identified where the Laplacian response changes sign (i.e., from positive to negative or vice versa), provided the change is significant enough, determined by a threshold set as a fraction of the maximum absolute Laplacian value.

This implementation explores vertical, horizontal, and both diagonal directions when detecting zero-crossings, ensuring robustness to different edge orientations.

The result is a binary edge map showing where significant transitions occur. This approach is inspired by early visual processing models in the human visual system, making it both biologically plausible and computationally effective.

<img src="https://github.com/user-attachments/assets/8ade17d2-aadf-476f-a5a7-799e32cb6e37" width="50%">

### 3. Hybrid Image Generation (Low + High Frequencies)
This script creates a hybrid image by combining two source images: one filtered with a low-pass filter and the other with a high-pass filter. The resulting image exhibits an interesting optical illusion, from a close distance, high-frequency details dominate (e.g., the cat), while from afar, low-frequency information becomes prominent (e.g., the dog).

**How it works:**
1. **Low-Pass Filtering**: A Gaussian blur is applied to the first image (e.g., a dog), removing high-frequency components and leaving only coarse structures.
2. **High-Pass Filtering**: The second image (e.g., a cat) is also Gaussian blurred, and this blurred version is subtracted from the original to isolate its high-frequency content.
3. **Image Fusion**: The low-pass result and the high-pass result are added together to form a single image, the hybrid.

By adjusting the sigma values for each filter (e.g., σₗ = 10, σₕ = 2), we control the level of blurring or sharpness in the frequency components. The final image appears different depending on viewing distance due to the way human vision perceives spatial frequencies.

This technique is inspired by visual cognition studies and popularized by work from Oliva, Torralba, and others in the hybrid images field.

<img src="https://github.com/user-attachments/assets/5f6ada7d-2560-454c-8696-f7c583be359a" width="35%">

### 4. Multi-Resolution Blending using Laplacian Pyramids

This script demonstrates a powerful image processing technique called **multi-resolution blending**, which combines two images seamlessly using Gaussian and Laplacian pyramids. It's especially useful for blending images with soft transitions, such as in panorama stitching or object compositing. A vertical mask is used to blend the left half of the apple with the right half of the orange. The result is a smooth composite where no harsh seams are visible, even though the original inputs are visually distinct.

The method is inspired by Burt and Adelson’s pyramid-based approach to image fusion.

**Key Concepts:**

* **Gaussian Pyramid**: A sequence of images obtained by iteratively applying a Gaussian filter and downsampling. Each level represents a progressively more blurred and lower-resolution version of the original.
* **Laplacian Pyramid**: Formed by subtracting consecutive levels of the Gaussian pyramid, this highlights detail (i.e., high-frequency information) at each scale.
* **Blending Mask Pyramid**: A spatial mask, typically binary (left vs. right), defines which parts of the two images to blend. This mask is also downsampled to match each pyramid level, ensuring a gradual transition.

**Steps in the Script:**

1. **Generate 1D Gaussian filters** for both downsampling (decimation) and upsampling (interpolation), where the standard deviation σ is based on 1% of the image size.
2. **Build Laplacian pyramids** for both images to be blended. This includes Gaussian pyramid construction and subtractive generation of detail layers.
3. **Build a Gaussian pyramid for the blending mask** (e.g., left half white, right half black), ensuring smooth transitions across scales.
4. **Blend the images at each pyramid level** using the corresponding mask. This ensures that blending respects spatial frequency characteristics at every resolution.
5. **Reconstruct the final image** from the blended Laplacian pyramid via successive upsampling and addition.

**Visualization:**
Optional pyramid visualizations are included to inspect each level of the Laplacian and mask pyramids. These help understand how fine details are blended at different resolutions.

<img src="https://github.com/user-attachments/assets/00d65271-1c68-4da4-8951-cc1cfac06b2a" width="50%">


### 5. Wavelet Decomposition via Lifting Scheme

This script demonstrates an efficient and fully reversible method for decomposing an image using **wavelet transforms**, specifically employing the **lifting scheme**. Unlike traditional convolution-based wavelets, the lifting scheme is computationally lightweight, integer-friendly, and suitable for scalable image analysis and compression.

#### Overview of the Lifting Scheme

Wavelet decomposition breaks down an image into approximations and details at multiple scales. The lifting scheme performs this using a sequence of predict and update steps:

1. **Split**: The image is separated into even and odd pixel indices, first across rows, then across columns.
2. **Predict**: Differences (details) are computed between the odd and even indexed pixels. These represent high-frequency (edge) information.
3. **Update**: The even pixels are updated using a weighted sum of the details to better represent low-frequency (smooth) components.
4. **Repeat**: This process is recursively applied to the low-frequency component (approximation) to create a multi-level decomposition.

The decomposition stores:

* Three **detail subbands** (horizontal, vertical, diagonal edges),
* One **approximation subband**.

These are stored in a structured pyramid (`pyr`) along with shape metadata (`pind`) for later reconstruction.

#### Reconstruction

The reverse process uses the stored pyramid to rebuild the image. It performs:

* Reverse update and predict steps,
* Interleaving of odd and even pixel locations,
* Upsampling to restore original dimensions.

A difference check (`min/max`) is performed to verify lossless reconstruction, confirming the accuracy of the implementation.

#### Visualization

Two outputs are shown:

1. **Reconstructed image**: Demonstrates the exact recovery from the wavelet coefficients.
2. **Isolated Edges**: By zeroing out the final approximation layer and reconstructing only from details, we visualize high-frequency content (i.e., edges).

This implementation gives insight into scalable transforms, foundational to applications in image compression (e.g., JPEG 2000), denoising, and feature extraction.

<img src="https://github.com/user-attachments/assets/9b1dc0be-7dfe-43ef-8bc9-cec3da3ba2ae" width="45%">
<img src="https://github.com/user-attachments/assets/009fd922-eb9d-4bbc-ba33-e8b12ec421cf" width="45%">


## 📄 License
This project is open-source under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📖 Resources
1. [Theory of Edge Detection - D. C. Marr, Ellen C Hildreth](https://www.researchgate.net/publication/17083076_Theory_of_Edge_Detection)
2. [Hybrid images - Aude Oliva, Antonio Torralba, Philippe G Schyns](https://www.researchgate.net/publication/220184425_Hybrid_images)
3. [A Multiresolution Spline With Application to Image Mosaics - Peter J. Burt and Edward H. Adelson](https://persci.mit.edu/pub_pdfs/spline83.pdf)
4. [The Lifting Scheme:A Construction of Second Generation Wavelets - Wim Sweldens](https://cm-bell-labs.github.io/who/wim/papers/lift2.pdf)
---

Feel free to star ⭐ the repo if you find it useful!
