"""Cuts frozen stretches (3 s or more of the same picture, such as the pause while
the game loads the next chapter) out of a recording.
Usage: trim_freezes.py <in.mp4> <out.mp4>"""
import re
import subprocess
import sys

src, dst = sys.argv[1], sys.argv[2]
MIN_FREEZE_S = 3.0
KEEP_S = 0.3  # keep a moment of each frozen stretch so cuts aren't abrupt

probe = subprocess.run(
    ["ffmpeg", "-i", src, "-vf", f"freezedetect=n=-55dB:d={MIN_FREEZE_S}", "-an", "-f", "null", "-"],
    capture_output=True, text=True)
starts = [float(x) for x in re.findall(r"freeze_start: ([\d.]+)", probe.stderr)]
durations = [float(x) for x in re.findall(r"freeze_duration: ([\d.]+)", probe.stderr)]
cuts = []
for i, start in enumerate(starts):
    end = start + durations[i] if i < len(durations) else start + 100000.0  # frozen to the end
    if end - start > KEEP_S:
        cuts.append((start + KEEP_S, end))
print(f"[trim] frozen stretches cut: {len(cuts)} {cuts}")
if not cuts:
    subprocess.run(["cp", src, dst], check=True)
    sys.exit(0)
gone = "+".join(f"between(t,{a:.3f},{b:.3f})" for a, b in cuts)
result = subprocess.run(
    ["ffmpeg", "-y", "-loglevel", "error", "-i", src, "-vf", f"select='not({gone})',setpts=N/FRAME_RATE/TB",
     "-an", "-c:v", "libx264", "-preset", "veryfast", "-crf", "20", "-pix_fmt", "yuv420p",
     "-movflags", "+faststart", dst])
if result.returncode != 0:
    print("[trim] trimming failed; keeping the untrimmed clip")
    subprocess.run(["cp", src, dst], check=True)
