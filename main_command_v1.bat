@REM Step 1: convert to base video
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i thumbnail.png -i audio.mp3 -filter_complex "[0:v]scale=1920:1080:flags=lanczos,format=yuv420p[base_video]" -map "[base_video]" -map 1:a -c:v h264_nvenc -profile:v high -level:v 4.1 -cq 20 -c:a aac -b:a 192k -r 25 -pix_fmt yuv420p -color_primaries bt709 -color_trc bt709 -colorspace bt709 base_video.mp4

@REM Step 2: add thumbnail to video
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i loop_video.mp4 -hwaccel cuda -hwaccel_output_format cuda -i base_video.mp4 -init_hw_device cuda -filter_complex "[0:v]chromakey_cuda=0x000000:0.4:0.3:1[overlay_video];[1:v]scale_cuda=format=yuv420p,hwdownload,format=yuv420p,eq=brightness=0.0:contrast=1.0,hwupload[base];[base][overlay_video]overlay_cuda[video_step_1]" -map "[video_step_1]" -an -sn -c:v hevc_nvenc -preset p4 -cq 20 -color_primaries bt709 -color_trc bt709 -colorspace bt709 video_step_1.mp4


@REM Step 3: Convert wave video to codec h264 (Pixel format: yuv420p)
ffmpeg -i wave.mp4 -c:v h264_nvenc -profile:v high -preset fast -b:v 680k -r 50 -pix_fmt yuv420p -colorspace bt709 -color_primaries bt709 -color_trc bt709 -c:a aac -b:a 128k wave_converted.mp4

@REM Step 4: Add wave to video final
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i wave_converted.mp4 -hwaccel cuda -hwaccel_output_format cuda -i video_step_1.mp4 -init_hw_device cuda -filter_complex "[0:v]scale_cuda=759:268[wave_resize];[wave_resize]chromakey_cuda=0x000000:0.4:0.3:1[overlay_video];[1:v]scale_cuda=format=yuv420p,hwdownload,format=yuv420p,eq=brightness=0.0:contrast=1.0,hwupload[base];[base][overlay_video]overlay_cuda=972:525[video_step_2]" -map "[video_step_2]" -an -sn -c:v hevc_nvenc -preset p4 -cq 20 final.mp4
