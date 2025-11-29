obs = obslua

source_name = "GLOBAL_VIDEO_BACKGROUND"
video_path = ""

-- Adds video background to all scenes
function add_background_video()
    if video_path == "" then return end

    -- create media source if not exists
    local src = obs.obs_get_source_by_name(source_name)
    if src == nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "local_file", video_path)
        obs.obs_data_set_bool(settings, "looping", true)
        obs.obs_data_set_bool(settings, "is_local_file", true)

        src = obs.obs_source_create("ffmpeg_source", source_name, settings, nil)
        obs.obs_data_release(settings)
    end

    -- Add source to each scene
    local scenes = obs.obs_frontend_get_scenes()
    for _, scene_source in ipairs(scenes) do
        local scene = obs.obs_scene_from_source(scene_source)
        if scene ~= nil then
            local item = obs.obs_scene_find_source(scene, source_name)
            if item == nil then
                obs.obs_scene_add(scene, src)
            end
        end
        obs.obs_source_release(scene_source)
    end

    obs.obs_source_release(src)
end

-- UI in OBS Scripts window
function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_path(
        props,
        "video_path",
        "Select Video Background",
        obs.OBS_PATH_FILE,
        "Video Files (*.mp4 *.mov *.mkv *.webm);;",
        nil
    )

    return props
end

-- Update event (fires when user selects a video)
function script_update(settings)
    video_path = obs.obs_data_get_string(settings, "video_path")
    add_background_video()
end

function script_description()
    return "Automatically adds a single looping video background to all scenes."
end
