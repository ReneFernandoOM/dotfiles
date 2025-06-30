local events <const> = {
  AEROSPACE_WORKSPACE_CHANGED = "aerospace_workspace_change",
  AEROSPACE_SWITCH = "aerospace_switch",
  FRONT_APP_SWITCHED = "front_app_switched",
  UPDATE_WINDOWS = "update_windows",
}

local items <const> = {
  SPACES = "workspaces",
  FRONT_APPS = "front_apps",
  WIFI = "widgets.wifi",
  VOLUME = "widgets.volume",
  BATTERY = "widgets.battery",
  CALENDAR = "widgets.calendar",
}

local aerospace <const> = {
  LIST_ALL_WORKSPACES = "aerospace list-workspaces --all",
  GET_CURRENT_WORKSPACE = "aerospace list-workspaces --focused",
  LIST_WINDOWS = "aerospace list-windows --focused --format \"id=%{window-id}, name=%{app-name}\"",
  GET_CURRENT_WINDOW = "aerospace list-windows --focused --format %{app-name}",
}

return {
  items = items,
  events = events,
  aerospace = aerospace,
}
