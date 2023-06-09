#define TYPING_INDICATOR_LIFETIME 30 * 10	//grace period after which typing indicator disappears regardless of text in chatbar

mob/var/hud_typing = FALSE //set when typing in an input window instead of chatline
mob/var/typing
mob/var/last_typed
mob/var/last_typed_time

mob/var/obj/effect/decal/typing_indicator

/mob/proc/set_typing_indicator(var/state)

	if (!typing_indicator)
		typing_indicator = new
		typing_indicator.icon = 'icons/mob/talk.dmi'
		typing_indicator.icon_state = "typing"

	if (client && !stat)
		typing_indicator.invisibility = invisibility
		if (!is_preference_enabled(/datum/client_preference/show_typing_indicator))
			overlays -= typing_indicator
		else
			if (state)
				if (!typing)
					overlays += typing_indicator
					typing = TRUE
			else
				if (typing)
					overlays -= typing_indicator
					typing = FALSE
			return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	set_typing_indicator(1)
	hud_typing = TRUE
	var/message = input("","fala (text)") as text
	hud_typing = FALSE
	set_typing_indicator(0)
	if (message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	set_typing_indicator(1)
	hud_typing = TRUE
	var/message = input("","faz (text)") as text
	hud_typing = FALSE
	set_typing_indicator(0)
	if (message)
		me_verb(message)

/mob/proc/handle_typing_indicator()
	if (is_preference_enabled(/datum/client_preference/show_typing_indicator) && !hud_typing)
		var/temp = winget(client, "input", "text")

		if (temp != last_typed)
			last_typed = temp
			last_typed_time = world.time

		if (world.time > last_typed_time + TYPING_INDICATOR_LIFETIME)
			set_typing_indicator(0)
			return
		if (length(temp) > 5 && findtext(temp, "Fala \"", TRUE, 7))
			set_typing_indicator(1)
		else if (length(temp) > 3 && findtext(temp, "Faz ", TRUE, 5))
			set_typing_indicator(1)

		else
			set_typing_indicator(0)
