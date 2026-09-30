extends Node
## Store layer for real-money products (products.gd). Picks its backend at start-up:
##   steam – GodotSteam GDExtension present (singleton "Steam"): packs are DLC, ownership via
##           Steam.isDLCInstalled, purchase opens the Steam overlay on the DLC page.
##   play  – Google Play Billing plugin present (singleton "GodotGooglePlayBilling"): products are
##           in-app purchases, bought with purchase(sku) and acknowledged afterwards.
##   local – neither (editor, tests, itch builds): purchases are simulated and stored locally,
##           clearly marked as test mode – no real payment happens.
## The game only asks: owns(id), buy(id), restore(), price_text(id), requires_full_unlock().

signal purchased(product_id: String)
signal ownership_changed

const Products = preload("res://scripts/products.gd")
const LOCAL_SAVE := "user://store_local.cfg"

var backend := "local"
var owned := {}          # product id -> true
var prices := {}         # product id -> price string from the store
var persist := true
var steam = null
var billing = null

func setup() -> void:
	if Engine.has_singleton("Steam"):
		backend = "steam"
		steam = Engine.get_singleton("Steam")
		if steam.has_method("steamInitEx"): steam.steamInitEx()
		elif steam.has_method("steamInit"): steam.steamInit()
		_refresh_steam()
	elif Engine.has_singleton("GodotGooglePlayBilling"):
		backend = "play"
		billing = Engine.get_singleton("GodotGooglePlayBilling")
		for sig in [["connected", _on_play_connected], ["purchases_updated", _on_play_purchases], ["query_purchases_response", _on_play_query],
				["sku_details_query_completed", _on_play_details], ["purchase_error", _on_play_error]]:
			if billing.has_signal(sig[0]): billing.connect(sig[0], sig[1])
		billing.startConnection()
	else:
		backend = "local"
		_load_local()

func _process(_delta: float) -> void:
	if steam != null and steam.has_method("run_callbacks"): steam.run_callbacks()

func products() -> Array:
	return Products.for_backend(backend)

func owns(id: String) -> bool:
	return owned.has(id)

## On Google Play the game is free to start; the Vollversion unlocks the full content.
func requires_full_unlock() -> bool:
	return backend == "play"

func has_full_game() -> bool:
	return not requires_full_unlock() or owns("full_game")

func price_text(id: String) -> String:
	if prices.has(id): return str(prices[id])
	return ("%.2f €" % float(Products.find(id).get("price_eur", 0.0))).replace(".", ",")

func buy(id: String) -> void:
	var p: Dictionary = Products.find(id)
	if p.is_empty() or owns(id): return
	match backend:
		"steam":
			if int(p.steam_dlc) > 0 and steam.has_method("activateGameOverlayToStore"): steam.activateGameOverlayToStore(int(p.steam_dlc), 0)
		"play":
			billing.purchase(str(p.play_sku))
		_:
			_grant(id)
			_save_local()

func restore() -> void:
	match backend:
		"steam": _refresh_steam()
		"play":
			if billing.has_method("queryPurchases"): billing.queryPurchases("inapp")
		_: ownership_changed.emit()

func _grant(id: String) -> void:
	if owned.has(id): return
	owned[id] = true
	purchased.emit(id)
	ownership_changed.emit()

# ── Steam ──

func _refresh_steam() -> void:
	for p in Products.PRODUCTS:
		if int(p.get("steam_dlc", 0)) > 0 and steam.has_method("isDLCInstalled") and steam.isDLCInstalled(int(p.steam_dlc)):
			_grant(p.id)
	# The base game itself is the Steam purchase.
	owned["full_game"] = true
	ownership_changed.emit()

# ── Google Play ──

func _on_play_connected() -> void:
	var skus: Array = Products.PRODUCTS.map(func(p): return str(p.play_sku))
	if billing.has_method("querySkuDetails"): billing.querySkuDetails(skus, "inapp")
	if billing.has_method("queryPurchases"): billing.queryPurchases("inapp")

func _on_play_details(details: Array) -> void:
	for d in details:
		for p in Products.PRODUCTS:
			if str(p.play_sku) == str(d.get("sku", d.get("product_id", ""))): prices[p.id] = str(d.get("price", ""))
	ownership_changed.emit()

func _on_play_query(result: Dictionary) -> void:
	_on_play_purchases(result.get("purchases", []))

func _on_play_purchases(purchases: Array) -> void:
	for pur in purchases:
		var skus: Array = pur.get("skus", [pur.get("sku", "")])
		for p in Products.PRODUCTS:
			if str(p.play_sku) in skus:
				_grant(p.id)
				# Purchases must be acknowledged within three days or Google refunds them.
				if not bool(pur.get("is_acknowledged", false)) and billing.has_method("acknowledgePurchase"):
					billing.acknowledgePurchase(str(pur.get("purchase_token", "")))

func _on_play_error(code, message) -> void:
	push_warning("Play Billing: %s %s" % [str(code), str(message)])

# ── local test mode ──

func _load_local() -> void:
	if not persist: return
	var cfg := ConfigFile.new()
	if cfg.load(LOCAL_SAVE) == OK: owned = cfg.get_value("store", "owned", {})

func _save_local() -> void:
	if not persist: return
	var cfg := ConfigFile.new()
	cfg.set_value("store", "owned", owned)
	cfg.save(LOCAL_SAVE)
