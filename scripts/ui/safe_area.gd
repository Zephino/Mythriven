class_name SafeArea
extends RefCounted
## The part of the screen clear of notches and rounded corners, in the game's
## own (scaled) coordinates. On PC this is simply the whole view.


static func is_handheld() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")


static func rect(viewport: Viewport) -> Rect2:
	var view: Rect2 = viewport.get_visible_rect()
	if not is_handheld():
		return view
	# The phone reports the safe area in screen pixels; convert it back
	# through the screen scaling into game coordinates.
	var safe: Rect2 = viewport.get_final_transform().affine_inverse() * Rect2(DisplayServer.get_display_safe_area())
	var clipped: Rect2 = view.intersection(safe)
	return clipped if clipped.has_area() else view
