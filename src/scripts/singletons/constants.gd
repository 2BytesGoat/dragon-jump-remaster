class_name Constants
extends RefCounted

## Constants
## Static helper for V1.0. Default values and shared resource references only;
## tunable data lives in Resource assets under res://resources/. Not an autoload.

const DEFAULT_PLAYER_NAME := "UNK"

## Social links shown in the main menu footer. Replace with real URLs before launch.
const DISCORD_URL := "https://discord.gg/your-invite"
const WEBSITE_URL := "https://your-website.example"

const PHYSICS_PARAMS := preload("res://resources/physics_params.tres")
const MEDAL_CONFIG := preload("res://resources/medal_config.tres")
const POWERUP_PALETTE := preload("res://resources/powerup_palette.tres")
const AUDIO_BUS_CONFIG := preload("res://resources/audio_bus_config.tres")
