# Crop_Quest_movie-options_for_all.ijm

## Overview
This FIJI macro streamlines the process of **cropping actin cable movies** in *Saccharomyces cerevisiae*, allowing users to focus on single-cell dynamics within large microscopy fields.  

When multiple cells are captured in one field, it can be challenging to track actin cable behavior. This macro helps isolate and export individual cells as **cropped time-lapse movies**, generating publication-ready image sequences and GIFs.

---

## Recommended Imaging Setup

- **Probe:** Use a bright, photostable actin probe (e.g., Lifeact or Abp140-fusing protein).  
- **Microscopy:** Spinning disc confocal microscopy is ideal for capturing dynamic actin structures with minimal photobleaching.  
- **Denoising:** If available, use **AI Denoise (Nikon NIS-Elements)** to enhance signal-to-noise ratio before analysis.  
- **Alternative:** If AI Denoise is unavailable, apply a **Gaussian Blur** filter in FIJI to reduce background noise.  

For time-series **3D stack movies**, it is recommended to generate a **Maximum Intensity Projection (MIP)** version to simplify visualization and quantification.

---

## Prerequisites

### Required Software
- [FIJI (ImageJ)](https://fiji.sc/)
- [Bio-Formats plugin](https://www.openmicroscopy.org/bio-formats/)

### Optional
- Nikon **AI-Denoise** (for noise reduction)
- FIJI’s **Bleach Correction** plugin (for time-series photobleaching correction)

---

## Input Preparation

1. Place your actin movie files in a single **input folder**.  
2. Supported formats include `.tif`, `.ome.tiff`, `.nd2`, `.czi` (any Bio-Formats–compatible file).  
3. If you have **transmitted light images** corresponding to your fluorescence movies, use them to mark cells and save the ROIs.  
   These can be used to define cell ROIs more accurately and speed up the cropping process.


---

## Running the Macro

1. Open **`Crop_Quest_movie-options_for_all.ijm`** in FIJI.  
2. When prompted, specify:
   - **Input folder:** directory containing your movie files.  
   - **Output folder:** location for cropped movies and results.
   - **Channel for actin:** cannot be 0.
3. Choose preprocessing options from the prompt menu:
   - **Background subtraction** (recommended).  
   - **Bleach correction** (optional, using FIJI’s built-in plugin).  
   - **Channel for second landmark -- select 0 if none:** (optional, if you want to crop additional channels or markers along with actin).  

---

## Workflow Summary

### 1. Preprocessing
- Loads the movie and applies selected preprocessing:
  - Channel merging  
  - Background subtraction  
  - Optional bleach correction  
- If a transmitted light channel is available, it will be opened and displayed to help guide cell selection.

### 2. Cell ROI Selection
- Users can **manually select cell ROIs** for cropping.  
- If you have previously saved **cell ROIs** (e.g., from earlier analysis), you can **reload** them to reuse.  
- The selected cell(s) will be saved as ROI files for recordkeeping.

### 3. Cropping and Export
- Once ROIs are defined, the macro:
  - Crops each cell from the original movie.  
  - Saves both **raw TIFF stacks** and **Maximum Intensity Projections (MIP)** for each cell.  
  - Generates **GIF animations** from MIP movies for easy visualization and sharing.  
- All output files are saved in your defined **output folder**.

---

## Output Structure

| Folder / File | Description |
|----------------|-------------|
| `-rmBKG50.tif/` | background subtracted original file |
| `-cellxxx.tif/` | Individual cropped cell movies in TIFF format |
| `-cellxxx-MAX.tif/` | MIP versions of each cropped cell movie |
| `-cellxxx-gif.gif/` | Animated GIFs generated from MIP sequences |
| `-CellnumberRoiSet.zip` | Saved ROI file marking all selected cells |
| `cells marked.tif` | Annotated original movie showing selected cells |

---

## Example Workflow (Hidden for Now)

<!--
### Example Workflow
1. **Example Input Movie:** Raw actin cable movie with multiple cells.  
2. **Example Transmitted Light:** Used to assist ROI definition.  
3. **Example Cropped Movie:** Single-cell actin dynamics.  
4. **Example MIP and GIF Output:** Processed cell movie for presentation.
-->

---

## Notes

- Use consistent preprocessing settings across all movies for quantitative comparisons.  
- Transmitted light channel is optional but can greatly speed up cell ROI definition.  
- MIP movies are recommended for analysis if actin cables are primarily planar.  
- For datasets with severe photobleaching, enable bleach correction in the prompt.  

---

## Citation
If you use this macro in your research, please cite:  
> Yang, E.J.-N., Filpo, K., Boldogh, I., Swayne, T.C., and Pon, L.A. "Tying up loose ends: an actin cable organizing center contributes to actin cable polarity, function and quality control in budding yeast." submitted. [2025]

---

## License
Released under the [MIT License](LICENSE).

---

## Contact
For questions, feedback, or bug reports:  
**[Emily J Yang]**  
Email: [emily.jiening.yang@gmail.com]
