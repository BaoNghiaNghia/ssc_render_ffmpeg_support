@REM Step 1: convert to base video
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i thumbnail.png -i audio.mp3 -filter_complex "[0:v]scale=1920:1080:flags=lanczos,format=yuv420p[base_video]" -map "[base_video]" -map 1:a -c:v h264_nvenc -profile:v high -level:v 4.1 -cq 20 -c:a aac -b:a 192k -r 25 -pix_fmt yuv420p -color_primaries bt709 -color_trc bt709 -colorspace bt709 base_video.mp4


@REM Step 2: Smarter way to blend video loop to background video (Old way)
ffmpeg -hwaccel cuda -i base_video.mp4 -i loop_video.mp4 -filter_complex "[0][1]blend=all_mode='lighten':all_opacity=0.5[out]" -map "[out]" -c:v h264_nvenc -r 25 -color_primaries bt709 -color_trc bt709 -colorspace bt709 video_step_1.mp4



@REM Step 3: render final video (Old way)
ffmpeg -hwaccel cuda -i video_step_1.mp4 -i wave.mp4 -filter_complex "[1]scale=759:268[loop_resized]; [0][loop_resized]overlay=972:525[overlayed]; [0][overlayed]blend=all_mode='addition':all_opacity=1[out]" -map "[out]" -c:v h264_nvenc -r 25 -color_primaries bt709 -color_trc bt709 -colorspace bt709 video_step_2.mp4
