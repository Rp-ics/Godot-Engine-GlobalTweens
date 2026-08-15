# =============================================================================
#  GlobalTweens — EditorPlugin
#  Registers / removes the GlobalTweens autoload singleton automatically.
#  Safe: idempotent — if the autoload already exists (declared in
#  project.godot) it is skipped, and disabling/deleting the plugin never
#  leaves the project in a broken state.
# =============================================================================

@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GlobalTweens"
const AUTOLOAD_PATH := "res://addons/global_tweens/global_tweens.gd"


func _enter_tree() -> void:
	var autoloads: Dictionary = ProjectSettings.get_setting("autoload", {})
	if not autoloads.has(AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
