obs = obslua

source_name = "GLOBAL_SPONSOR"
background_path = ""   -- set later in script UI

-- Add background source to all scenes
function add_background_to_scenes()
    if background_path == "" then return end

    -- create source if not exists
    local src = obs.obs_get_source_by_name(source_name)
    if src == nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "file", background_path)
        src = obs.obs_source_create("image_source", source_name, settings, nil)
        obs.obs_data_release(settings)
    end

    -- loop scenes
    local scenes = obs.obs_frontend_get_scenes()
    for i, scene_source in ipairs(scenes) do
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

-- Script properties UI
function script_properties()
    local props = obs.obs_properties_create()

    local p = obs.obs_properties_add_path(
        props,
        "background_path",
        "Select Background Image",
        obs.OBS_PATH_FILE,
        "Image Files (*.png *.jpg *.jpeg *.webp);;",
        nil
    )

    return props
end

-- When you select a file
function script_update(settings)
    background_path = obs.obs_data_get_string(settings, "background_path")
    add_background_to_scenes()
end

function script_description()
    return "Automatically applies a single background image to all scenes."
end
