# Catalogue

GlobalTweens.play(node, "category.name", opts)

153 animations in 16 categories. Every animation accepts the
[unified options](OPTIONS.md): dur, loops, delay, trans, ease, keep_end_state.

- [hit](#hit)
- [jump](#jump)
- [death](#death)
- [squish](#squish)
- [slime](#slime)
- [player](#player)
- [boss](#boss)
- [ui_buttons](#ui_buttons)
- [ui_text](#ui_text)
- [ui_generic](#ui_generic)
- [environment](#environment)
- [fog](#fog)
- [flash](#flash)
- [camera](#camera)
- [fx](#fx)
- [generic](#generic)

---

## hit

| id | Description | Params |
|---|---|---|
| hit.flash | Flash the node to a color and back | color, dur |
| hit.knockback | Push away along dir with a flash, then spring back | dir, power, dur |
| hit.launch | Fly up in an arc, fall back and land with a squash | height, dur |
| hit.stun_tilt | Stunned wobble: tilts left/right, then recovers | angle, dur |
| hit.flinch | Quick defensive jerk, then returns | dir, dist, dur |
| hit.damage_popup | Spawn a damage number that floats up and fades | text, color, font_size, rise, dur |
| hit.crit | Critical hit: yellow flash, pop, shockwave + bigger popup | text, dur |
| hit.spark | Radial burst of small impact particles | count, speed, dur |
| hit.absorb | Shrink + cyan flash, then elastic rebound | factor, dur |
| hit.push | Persistent displacement (gameplay knockback, stays) | dir, dist, dur |
| hit.hitstop | Brief Engine.time_scale freeze for impact weight | dur, scale |
| hit.graze | Near-miss flicker: white/transparent pulses | times, dur |
| hit.shield_break | Cyan flash, shockwave ring and shake | dur |

## jump

| id | Description | Params |
|---|---|---|
| jump.arc | Crouch squash, rise, fall, land squash | height, dur |
| jump.hop | Small bounce | height, dur |
| jump.big_leap | Leap to a target point with lean and dust | target, height, dur |
| jump.double_flip | Jump with two full rotations | height, rotations, dur |
| jump.land | Landing squash + dust | dur |
| jump.ledge_hang | Hanging wobble on a ledge | angle, dur |
| jump.soar | Smooth rise, hold, gentle land | height, dur |
| jump.coyote_dust | Dust puff at the feet (coyote time) | dur |

## death

All death animations free the node when finished. restore: false.

| id | Description | Params |
|---|---|---|
| death.dissolve | Fade out, shrink and sink | dur |
| death.collapse | Vertical collapse to a thin line + fade | dur |
| death.puff | Mario-style: up, grow, vanish | dur |
| death.wilt | Rotates over, sinks, fades | dur |
| death.zap | Flash + jitter steps + vanish | steps, dur |
| death.shatter | Break into flying shards that fade | shards, dur |
| death.vanish | Horizontal stretch + fade | dur |
| death.sink | Drop through the floor + fade | dur |
| death.float_away | Float up + fade + rotate | dur |
| death.implode | Scale to nothing + white flash | dur |

## squish

| id | Description | Params |
|---|---|---|
| squish.squeeze | Hard vertical squeeze, then overshoot back | factor, dur |
| squish.stretch | Tall stretch, then overshoot back | factor, dur |
| squish.jelly | Loose springy wobble on both axes | factor, dur |
| squish.thud | Heavy squash + small bounce | dur |
| squish.flatten | Squash into the floor and stay (kept end state) | factor, dur |
| squish.bounce_squash | Squash on land, stretch on launch, repeat | factor, dur |
| squish.snap | Snap squash with rotation kick | factor, dur |

## slime

| id | Description | Params |
|---|---|---|
| slime.idle | Breathing blob (loop) | dur |
| slime.drip | Slow drip and reset (loop) | height, dur |
| slime.hop | Squat, hop, land squash (loop) | height, dur |
| slime.grow | Grow big and settle back | factor, dur |
| slime.shiver | Fast tiny scale tremble | dur |
| slime.squish_floor | Pancake against the floor, spring back | dur |
| slime.blob_wobble | Jelly wobble (loop) | dur |
| slime.goo_smear | Stretch smear toward a direction, snap back | dir, dist, dur |

## player

| id | Description | Params |
|---|---|---|
| player.idle_bob | Gentle idle bob (loop) | dist, dur |
| player.run_bob | Run cycle: bob + slight rotation (loop) | dist, angle, dur |
| player.dash | Fast dash with stretch (kept end state) | dist, dur |
| player.dash_trail | Afterimage dash + trail ghosts | dist, dur, ghosts |
| player.land | Landing squash + dust | dur |
| player.wall_slide | Sideways stretch + dust | dur |
| player.jump_crouch | Crouch before jumping | factor, dur |
| player.air_flip | Full rotate in the air | dur |
| player.hurt | Flash + knockback + tilt | dur |
| player.revive | Elastics grow from zero + glow | dur |

## boss

| id | Description | Params |
|---|---|---|
| boss.intro_slam | Drop from above with impact and camera shake | height, dur |
| boss.stagger | Heavy stumble back and forth | dist, dur |
| boss.enrage | Red flash, grow, shake | factor, dur |
| boss.telegraph | Anticipation: shake + glow before attack | dur |
| boss.weakpoint | Soft spot pulse: cyan glow + size wobble | dur |
| boss.roar | Screen shake + radial waves | dur |
| boss.aura_pulse | Menacing aura pulses (loop) | factor, dur |
| boss.rush | Charge forward with trail | dist, dur |
| boss.enter | Dramatic descending entrance | dur |
| boss.death | Cinematic death: flash, implode, ring | dur |

## ui_buttons

| id | Description | Params |
|---|---|---|
| ui_buttons.hover | Scale up on mouse enter | factor, dur |
| ui_buttons.unhover | Scale back on mouse exit | dur |
| ui_buttons.press | Quick squish on click | dur |
| ui_buttons.pop_in | Spawn pop with back overshoot | dur |
| ui_buttons.wiggle | Annoying wiggle (great for "don't click me") | angle, dur |
| ui_buttons.notify_bounce | Attention bounce when new content arrives | dur |
| ui_buttons.click_zoom | Zoom punch like a camera flash on click | factor, dur |
| ui_buttons.focus_pulse | Breathing scale while focused (loop) | factor, dur |
| ui_buttons.ripple | Expanding ring from the click position | dur |
| ui_buttons.shiny_sweep | Shine sweep across the label | dur |
| ui_buttons.disable_fade | Fade + shrink for disabled state | dur |

## ui_text

| id | Description | Params |
|---|---|---|
| ui_text.pop | Pop in with overshoot | dur |
| ui_text.shake | Damage-style shake | intensity, dur |
| ui_text.bounce | Bounce like a dropped object | dur |
| ui_text.wave | Per-character wave | wave, dur |
| ui_text.glitch | RGB-split style glitch flicker | steps, dur |
| ui_text.scramble | Letters scramble then settle (kept end text) | text, dur |
| ui_text.reveal | Typewriter-style reveal | char_dur |
| ui_text.rise | Slide up + fade in | dist, dur |
| ui_text.emphasis | Big pop on a subtitle | scale, dur |
| ui_text.sway | Gentle pendulum sway (loop) | angle, dur |
| ui_text.breathe | Subtle breathing scale (loop) | factor, dur |

## ui_generic

| id | Description | Params |
|---|---|---|
| ui_generic.toast | Slide in from the edge, hold, slide out | dir, dur, hold |
| ui_generic.tooltip_pop | Tooltip scale pop | dur |
| ui_generic.panel_slide | Panel slides in from a direction | dir, dist, dur |
| ui_generic.list_stagger | Children fade in one by one | dur, stagger |
| ui_generic.card_flip | Flip on the X axis like a card | dur |
| ui_generic.icon_bounce | Icon bounce loop | dur |
| ui_generic.badge_pulse | Pulsing notification badge (loop) | dur |
| ui_generic.progress_flash | Flash a progress bar's value color | color, dur |
| ui_generic.slider_fill | Animate a Range value smoothly | value, dur |
| ui_generic.notification_slide | Full-panel notification slide + fade | dir, dur |

## environment

| id | Description | Params |
|---|---|---|
| environment.wind_sway | Gentle wind blow | angle, dur |
| environment.grass_sway | Fast low grass sway (loop) | angle, dur |
| environment.ripple | Water ripple trough | dir, dur |
| environment.cloud_drift | Slow cloud drift (loop) | dist, dur |
| environment.leaf_fall | Leaf falls with sway | dist, dur |
| environment.torch | Torch flame flicker (loop) | steps, dur |
| environment.tree_sway | Heavy tree sway (loop) | angle, dur |
| environment.flower_bob | Flower bobs in the wind (loop) | dist, dur |
| environment.wave | Rolling wave motion (loop) | dist, dur |
| environment.tornado | Spin + climb (kept end state) | rise, dur |
| environment.meteor | Fall at an angle, fade, free | dir, dist, dur |
| environment.vine_grow | Vine grows from the origin (kept end state) | dist, dur |

## fog

| id | Description | Params |
|---|---|---|
| fog.drift | Slow horizontal drift (loop) | dist, dur |
| fog.scroll | One-way linear scroll (kept end state) | dir, dist, dur |
| fog.thicken | Rolls in: alpha + size up (kept end state) | alpha, dur |
| fog.dissipate | Fades away drifting up (kept end state) | dur |
| fog.pulse | Breathing alpha (loop) | min_alpha, max_alpha, dur |
| fog.swirl | Circular drift + rotation (loop) | radius, dur |
| fog.rise | Rises then resets (loop) | dist, dur |
| fog.billow | Scale breathes out while alpha pulses (loop) | factor, dur |

## flash

| id | Description | Params |
|---|---|---|
| flash.screen_white | Full-screen white flash | dur |
| flash.screen_red | Full-screen red flash (damage) | dur |
| flash.screen_green | Full-screen green flash (heal) | dur |
| flash.screen_fade_black | Dip to black and back | dur, hold |
| flash.node_flash | Flash just the node white | color, dur |
| flash.ring | Expanding ring shockwave | size, dur, color |
| flash.afterimage | One fading ghost copy of the node | fade, alpha |
| flash.lightning | Random lightning strobe | count, dur |

## camera

| id | Description | Params |
|---|---|---|
| camera.zoom_kick | Quick zoom punch and back | target, dur |
| camera.focus | Pan + zoom to a point, then return | target, zoom, dur, hold |
| camera.cut_kick | Directional offset kick | dir, power, dur |
| camera.slow_motion | Time slows while the camera closes in | target, time_scale, dur |
| camera.orbit_drift | Slow orbiting offset (loop) | radius, dur |
| camera.fov_pulse | Breathing zoom (loop) | factor, dur |

## fx

| id | Description | Params |
|---|---|---|
| fx.ring_wave | Staggered expanding shockwave rings | rings, size, dur, color |
| fx.sparkle | Twinkling sparkle particles | count, radius, dur |
| fx.dust | Landing dust puffs | count, dur |
| fx.confetti | Colorful confetti burst | count, spread, dur |
| fx.heal_glow | Green flash + expanding soft glow | dur |
| fx.magic_swirl | Orbs orbiting the node | count, radius, dur, color |
| fx.poison_bubble | Green bubbles wobbling up | count, dur |
| fx.electric | Electric jitter + blue flashes | steps, dur |
| fx.vignette | Screen darkens into a vignette, then back | alpha, dur, hold |
| fx.xp_gain | Orbs fly into the node + '+XP' popup | count, dur |

## generic

| id | Description | Params |
|---|---|---|
| generic.pulse_loop | Scale pulses (loop) | min_scale, max_scale, dur |
| generic.wiggle_loop | Rotation wobble (loop) | angle, dur |
| generic.breathe_loop | Scale + alpha breathing (loop) | factor, dur |
| generic.rock | Slow pendulum rock (loop) | angle, dur |
| generic.flicker | Random alpha flicker (loop) | steps, min_alpha, dur |
| generic.fade_in_out | Fade to min_alpha, hold, return (loop) | min_alpha, dur, hold |
| generic.move_loop | Glides between two points (loop) | dir, dist, dur |
| generic.stretch_loop | Alternating x/y stretch (loop) | factor, dur |
| generic.color_cycle | Cycles modulate through the palette (loop) | palette, dur |
| generic.blob | Bouncy squash-stretch (loop) | factor, dur |