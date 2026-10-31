class_name AppActions
extends RefCounted
## Settings → Fullscreen, Install app, Update app (owner request 10/31/2026).
## Fullscreen works in the browser and on PC (phone apps are always full
## screen). Install app and Update app are for the web version: it can be
## installed like an app (export preset: progressive web app), which keeps a
## copy of the game on the device; Update app clears that copy and reloads,
## so the newest version is always one tap away. The page also updates itself:
## for 30 s after opening it checks the online version and switches to a newer
## one (web/update.js, as in Wave Defence), so a run is never interrupted.


## True where the game can switch fullscreen on and off.
static func can_fullscreen() -> bool:
	return OS.has_feature("web") or not OS.has_feature("mobile")


static func is_fullscreen() -> bool:
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


static func toggle_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen() else DisplayServer.WINDOW_MODE_FULLSCREEN)


## Install app and Update app only make sense for the web version.
static func is_web() -> bool:
	return OS.has_feature("web")


## "ready" (the browser can install it now), "installed" (already running as
## an app), "ios" (Safari: Share → Add to Home Screen), or "unavailable".
static func install_state() -> String:
	if not is_web():
		return "unavailable"
	return str(JavaScriptBridge.eval("""(function(){
		var m=function(q){return window.matchMedia&&window.matchMedia(q).matches;};
		if(m('(display-mode: fullscreen)')||m('(display-mode: standalone)')||navigator.standalone)return 'installed';
		if(window.mythrivenInstall)return 'ready';
		if(/iPad|iPhone|iPod/.test(navigator.userAgent)||(navigator.platform==='MacIntel'&&navigator.maxTouchPoints>1))return 'ios';
		return 'unavailable';})()""", true))


## Shows the browser's own "Install Mythriven?" box (the page keeps the
## browser's offer when it loads; see the export preset's head include).
static func install() -> void:
	if is_web():
		JavaScriptBridge.eval("(function(){var e=window.mythrivenInstall;if(e){window.mythrivenInstall=null;e.prompt();}})()", true)


## Forgets the saved copy of the game (service worker and its cache) and
## reloads from the internet. Progress is safe: it's saved separately.
static func update_now() -> void:
	if not is_web():
		return
	# web/update.js (added by the web build) also makes the reload fetch every game file fresh.
	if bool(JavaScriptBridge.eval("typeof window.mythrivenForceUpdate === 'function'", true)):
		JavaScriptBridge.eval("window.mythrivenForceUpdate()", true)
		return
	JavaScriptBridge.eval("""(async function(){
		try{
			if(navigator.serviceWorker){var r=await navigator.serviceWorker.getRegistrations();for(var i=0;i<r.length;i++){await r[i].unregister();}}
			if(window.caches){var k=await caches.keys();for(var j=0;j<k.length;j++){await caches.delete(k[j]);}}
		}catch(e){}
		var u=new URL(location.href);u.searchParams.set('v',Date.now());location.replace(u.toString());})()""", true)
