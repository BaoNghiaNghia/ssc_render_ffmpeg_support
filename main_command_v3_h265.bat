@REM Step 1: Convert to base video using H265
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i thumbnail.png -i audio.mp3 -filter_complex "[0:v]scale=1920:1080:flags=lanczos,format=yuv420p[base_video]" -map "[base_video]" -map 1:a -c:v hevc_nvenc -profile:v main10 -level:v 5.1 -cq 20 -c:a aac -b:a 192k -r 25 -pix_fmt yuv420p -color_primaries bt709 -color_trc bt709 -colorspace bt709 base_video.mp4

@REM Step 2: Smarter way to blend video loop to background video (New way)
ffmpeg -hwaccel cuda -i base_video.mp4 -i loop_video.mp4 -filter_complex "[0:v]format=gbrp[base];[1:v]format=gbrp[loop];[base][loop]blend=all_mode='lighten':all_opacity=1[out];[out]format=yuv420p[out_final_step_1]" -map "[out_final_step_1]" -c:v hevc_nvenc -r 25 -color_primaries bt709 -color_trc bt709 -colorspace bt709 video_step_1.mp4

@REM Step 3: Render final video (New way) with H265
ffmpeg -hwaccel cuda -i video_step_1.mp4 -i wave.mp4 -filter_complex "[1:v]scale=759:268,format=gbrp[wave_resized];[0:v]format=gbrp[base];[base][wave_resized]overlay=972:525[overlayed];[base][overlayed]blend=all_mode='lighten':all_opacity=1[blended];[blended]format=yuv420p[out_final_step_2]" -map "[out_final_step_2]" -c:v hevc_nvenc -r 25 -color_primaries bt709 -color_trc bt709 -colorspace bt709 video_step_2.mp4
