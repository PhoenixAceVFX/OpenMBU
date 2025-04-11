#!/usr/bin/env bash

# Exit on any error
set -euo pipefail

# Change these as needed
BUILD_TYPE="Release"
C_COMPILER="clang"
CPP_COMPILER="clang++"
ASM_COMPILER="nasm"
BUILD_DIR="./build"
ARTIFACT_NAME="OpenMBU-Linux-Clang"
ARTIFACT_OUTPUT_DIR="./artifacts"

# Step 1: Install prerequisites (for Arch Linux)
echo "Installing prerequisites..."
sudo pacman -Syu --noconfirm \
  clang \
  nasm \
  sdl \
  libx11 \
  libxft \
  libxxf86vm \
  util-linux \
  cmake \
  make \
  gcc \
  git

# Step 2: Configure build
echo "Configuring CMake..."
cmake -B "$BUILD_DIR" \
  -DCMAKE_C_COMPILER="$C_COMPILER" \
  -DCMAKE_CXX_COMPILER="$CPP_COMPILER" \
  -DCMAKE_ASM_NASM_COMPILER="$ASM_COMPILER" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -S .

# Step 3: Build
echo "Building project..."
cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" -j$(nproc)

# Step 4: Run tests
echo "Running tests..."
cd "$BUILD_DIR"
ctest --build-config "$BUILD_TYPE"
cd -

# Step 5: Package artifacts
# Adjust the `game` folder path based on your actual output structure
if [ -d "$BUILD_DIR/game" ]; then
  echo "Archiving production artifacts..."
  mkdir -p "$ARTIFACT_OUTPUT_DIR"
  tar -czf "${ARTIFACT_OUTPUT_DIR}/${ARTIFACT_NAME}.tar.gz" -C "$BUILD_DIR" game
  echo "Artifact created: ${ARTIFACT_OUTPUT_DIR}/${ARTIFACT_NAME}.tar.gz"
else
  echo "❌ Game directory not found at '$BUILD_DIR/game'. Skipping artifact creation."
fi
