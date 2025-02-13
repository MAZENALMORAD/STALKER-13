/// state = overlay/image/object/type/whatever add_overlay will accept
GLOBAL_LIST_EMPTY(typing_indicator_overlays)

/// Fetches the typing indicator we'll use from GLOB.typing_indicator_overlays
/mob/proc/get_indicator_overlay(state)
	. = GLOB.typing_indicator_overlays[state]
	if(.)
		return
	// doesn't exist, make it and cache it
	if(ispath(state))
		. = GLOB.typing_indicator_overlays[state] = state
	// We only support paths for now because anything else isn't necessary yet.

/// Gets the state we will use for typing indicators. Defaults to src.typing_indicator_state
/mob/proc/get_typing_indicator_icon_state()
	return typing_indicator_state

/**
  * Displays typing indicator.
  * @param timeout_override - Sets how long until this will disappear on its own without the user finishing their message or logging out. Defaults to src.typing_indicator_timeout
  * @param state_override - Sets the state that we will fetch. Defaults to src.get_typing_indicator_icon_state()
  * @param force - shows even if src.typing_indcator_enabled is FALSE.
  */
/mob/proc/display_typing_indicator(timeout_override = TYPING_INDICATOR_TIMEOUT, state_override = get_typing_indicator_icon_state(), force = FALSE)
	if((!typing_indicator_enabled && !force) || typing_indicator_current)
		return
	typing_indicator_current = state_override
	add_overlay(state_override)
	typing_indicator_timerid = addtimer(CALLBACK(src, .proc/clear_typing_indicator), timeout_override, TIMER_STOPPABLE)

/**
  * Removes typing indicator.
  */
/mob/proc/clear_typing_indicator()
	cut_overlay(typing_indicator_current)
	typing_indicator_current = null
	if(typing_indicator_timerid)
		deltimer(typing_indicator_timerid)
		typing_indicator_timerid = null

/// Default typing indicator
/obj/effect/overlay/typing_indicator
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/mob/talk.dmi'
	icon_state = "normal_typing"
	appearance_flags = RESET_COLOR | TILE_BOUND | PIXEL_SCALE
	layer = FLY_LAYER

/mob
	var/hud_typing = FALSE //set when typing in an input window instead of chatline
	var/typing
	var/last_typed
	var/last_typed_time

	var/static/mutable_appearance/typing_indicator

/mob/proc/set_typing_indicator(var/state)
	if(!typing_indicator)
		typing_indicator = mutable_appearance('icons/mob/talk.dmi', "normal_typing", FLY_LAYER)
	if(client && !stat)
		if(state)
			if(!typing)
				add_overlay(typing_indicator)
				typing = TRUE
		else
			if(typing)
				cut_overlay(typing_indicator)
				typing = FALSE
		return state

/mob/proc/handle_typing_indicator()
	if(!client)
		return
	var/temp = winget(client, "input", "text")

	if (temp != last_typed)
		last_typed = temp
		last_typed_time = world.time

	if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
		set_typing_indicator(TRUE)
		return
	if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
		set_typing_indicator(TRUE)
		return
	if(!hud_typing)
		set_typing_indicator(FALSE)