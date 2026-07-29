extends Node

## MonetizationSystem
## Optional IAP/ad layer behind a feature flag.
## Everything is no-op until a store integration (Google Play, App Store,
## AdMob, etc.) is wired in. Game code can call these methods safely today.

## Master switch. Set to true only when a backend is ready.
@export var enabled: bool = false

## Toggle ad placements independently.
@export var show_banner_ads: bool = false
@export var show_interstitial_ads: bool = false
@export var show_rewarded_ads: bool = false
@export var enable_iap: bool = false

## Internal state for mocking.
var _iap_products: Dictionary = {}
var _owned_skins: Array[String] = []
var _pending_reward: Callable


func _ready() -> void:
	if enabled:
		push_warning("MonetizationSystem is enabled but no backend is implemented yet.")


## Feature checks ----------------------------------------------------------

func are_ads_enabled() -> bool:
	return enabled and (show_banner_ads or show_interstitial_ads or show_rewarded_ads)


func is_iap_enabled() -> bool:
	return enabled and enable_iap


## Banner ads -------------------------------------------------------------

func show_banner() -> void:
	if not enabled or not show_banner_ads:
		return
	# Backend integration point.
	pass


func hide_banner() -> void:
	if not enabled or not show_banner_ads:
		return
	# Backend integration point.
	pass


## Interstitial ads -------------------------------------------------------

func show_interstitial() -> void:
	if not enabled or not show_interstitial_ads:
		return
	# Backend integration point.
	pass


## Rewarded ads -----------------------------------------------------------

func show_rewarded(reward_callback: Callable) -> void:
	if not enabled or not show_rewarded_ads:
		return
	_pending_reward = reward_callback
	# Backend integration point. On success, call _grant_reward().
	pass


func _grant_reward() -> void:
	if _pending_reward.is_valid():
		_pending_reward.call()
	_pending_reward = Callable()


## In-app purchases -------------------------------------------------------

func register_product(product_id: String, price: String, description: String) -> void:
	_iap_products[product_id] = {"price": price, "description": description}


func purchase_product(_product_id: String, _success_callback: Callable) -> void:
	if not is_iap_enabled():
		return
	# Backend integration point. On success, call success_callback and
	# mark the product as owned.
	pass


func owns_product(product_id: String) -> bool:
	return product_id in _owned_skins


func consume_product(product_id: String) -> void:
	_owned_skins.erase(product_id)
