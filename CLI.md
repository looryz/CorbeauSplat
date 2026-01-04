# Command Line Interface (CLI) Guide

CorbeauSplat exposes all its features via the command line, making it easy to integrate into automated pipelines or run on headless machines.

## 🚀 Quick Usage

### 1. Create a COLMAP Dataset
This runs the full pipeline: video frame extraction -> feature extraction -> matching -> sparse reconstruction -> undistortion.

```bash
# From Video
python3 main.py --input /path/to/video.mp4 --output /path/to/project_folder --type video

# From Images folder
python3 main.py --input /path/to/images --output /path/to/project_folder --type images
```

### 2. Train a Splat (Brush)
Train a Gaussian Splatting model using the dataset created in step 1.

```bash
python3 main.py --train --input /path/to/project_folder --output /path/to/output_model --iterations 30000
```
*Note: `--input` must be the directory containing the 'images' and 'sparse' folders.*

### 3. Visualise (SuperSplat)
Launch a local web viewer for your trained `.ply` file.

```bash
python3 main.py --view --input /path/to/output_model/splat.ply
```

### 4. Single Image to 3D (ML-Sharp)
Use Apple's machine learning model to generate a splat from a single photo.

```bash
python3 main.py --predict --input photo.jpg --output /path/to/output_dir
```

## ⚙️ Advanced Options

### General
| Flag | Description |
| :--- | :--- |
| `--gui` | Force launch the Graphical Interface (default if no args are passed). |
| `--help` | Show the full help message with all available flags. |

### COLMAP Options
| Flag | Description |
| :--- | :--- |
| `--fps <int>` | Frames per second for video extraction (Default: 5). |
| `--camera_model <str>` | COLMAP camera model (SIMPLE_RADIAL, PINHOLE, etc.). |
| `--undistort` | Add this flag to run image undistortion after reconstruction. |

### Brush Options
| Flag | Description |
| :--- | :--- |
| `--iterations <int>` | Training steps (Default: 30000). |
| `--sh_degree <int>` | Spherical Harmonics degree (Default: 3). |
| `--device <str>` | Force device (e.g., `mps`, `cpu`). Default: `auto`. |

### SuperSplat Options
| Flag | Description |
| :--- | :--- |
| `--port <int>` | Web server port (Default: 3000). |
| `--data_port <int>` | Data server port (Default: 8000). |
