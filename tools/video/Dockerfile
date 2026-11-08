# Records a gameplay video of Mythriven on Railway (see tools/video/README.md).
# Build context is the repository root; set the Railway variable
# RAILWAY_DOCKERFILE_PATH=tools/video/Dockerfile.
FROM debian:12-slim

ARG GODOT_VERSION=4.7.2

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip xvfb xdotool ffmpeg python3 \
      libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libxext6 \
      libgl1 libglx-mesa0 libgl1-mesa-dri libegl1 libfontconfig1 libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Godot (standard build, Linux). Same version as the web workflow.
RUN curl -fsSL -o /tmp/godot.zip \
      "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && unzip -q /tmp/godot.zip -d /tmp \
    && mv "/tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm /tmp/godot.zip

WORKDIR /game
COPY . /game
# First import builds the .godot cache so the recording starts quickly.
RUN godot --headless --import --path /game || true

CMD ["bash", "/game/tools/video/record.sh"]
