class_name ModularCharacter
extends Node2D

signal equipment_changed(slot: StringName, item_id: String)
signal gesture_started(name: String)
signal motion_changed(motion: StringName)
signal facing_changed(direction: StringName)

const Part := preload("res://src/part_visual.gd")
const Gear := preload("res://src/gear_visual.gd")
const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")
const SlashTrail := preload("res://src/slash_trail_visual.gd")
const GestureEffect := preload("res://src/gesture_effect_visual.gd")
const STORYBOOK_ARROW_PROJECTILE := preload("res://assets/equipment/arrow_projectile_storybook.png")
const STORYBOOK_CROSSBOW_BOLT := preload("res://assets/equipment/crossbow_bolt_storybook.png")
const STORYBOOK_SPELL_PROJECTILE := preload("res://assets/equipment/spell_projectile_storybook.png")

const WEAPON_ATTACKS := [&"jab", &"forehand", &"backhand"]
const BOW_ATTACKS := [&"fire_bow"]
const CROSSBOW_ATTACKS := [&"fire_crossbow"]
const STAFF_ATTACKS := [&"cast_spell"]
const STAFF_WEAPONS := ["staff","branch_staff"]
const MOTIONS := [&"idle", &"stand", &"run", &"stairs", &"climb"]
const RUN_FRAME_DURATION := .085
const STAIR_FRAME_DURATION := .11
const FAE_RUN_WING_CYCLE := [-28.0,-12.0,8.0,24.0,12.0,-8.0,-24.0,-10.0]
const FAE_STAIR_WING_CYCLE := [-14.0,-6.0,4.0,12.0,7.0,-3.0,-11.0,-5.0]
const CAPE_RUN_SWAY_CYCLE := [7.0,11.0,15.0,10.0,6.0,9.0,14.0,11.0]
const SCARF_RUN_SWAY_CYCLE := [3.0,6.0,9.0,5.0,2.0,5.0,8.0,6.0]
const CAPE_STAIR_SWAY_CYCLE := [3.0,5.0,7.0,5.0,2.0,4.0,6.0,4.0]
const SCARF_STAIR_SWAY_CYCLE := [1.0,3.0,4.0,3.0,1.0,2.0,4.0,2.0]
const OUTBOARD_CARRY_ARM_CYCLE := [32.0,35.0,38.0,35.0,32.0,35.0,38.0,35.0]
const OUTBOARD_CARRY_FOREARM_CYCLE := [-38.0,-40.0,-42.0,-40.0,-38.0,-40.0,-42.0,-40.0]
const IDLE_MOTION_PROFILES := {
	"bogkin": {"speed": 3.5, "bob": 2.4, "torso": 1.4, "head": -1.8, "arm": 3.2, "forearm": 2.0, "leg": .7, "tail": 0.0, "wing": 0.0},
	"human": {"speed": 2.4, "bob": 1.7, "torso": .8, "head": -1.0, "arm": 1.5, "forearm": 1.0, "leg": .35, "tail": 0.0, "wing": 0.0},
	"centaur": {"speed": 1.8, "bob": 1.2, "torso": .6, "head": -.8, "arm": 1.2, "forearm": .8, "leg": .3, "tail": 7.5, "wing": 0.0},
	"fae": {"speed": 3.1, "bob": 1.5, "torso": 1.5, "head": -2.0, "arm": 2.5, "forearm": 1.6, "leg": .5, "tail": 0.0, "wing": 11.0},
	"frost_troll": {"speed": 1.5, "bob": 2.0, "torso": .5, "head": -.5, "arm": .9, "forearm": .6, "leg": .25, "tail": 0.0, "wing": 0.0},
	"goblin": {"speed": 3.6, "bob": 2.2, "torso": 1.7, "head": -2.2, "arm": 3.6, "forearm": 2.4, "leg": .8, "tail": 0.0, "wing": 0.0},
	"duneborn": {"speed": 2.0, "bob": 1.5, "torso": .7, "head": -.9, "arm": 1.1, "forearm": .7, "leg": .3, "tail": 0.0, "wing": 0.0},
	"frostling": {"speed": 2.8, "bob": 1.6, "torso": 1.0, "head": -1.3, "arm": 2.0, "forearm": 1.3, "leg": .45, "tail": 0.0, "wing": 0.0},
}
const ATTACK_PHASE_EASING := {
	"chamber": {"trans": Tween.TRANS_QUAD, "ease": Tween.EASE_OUT},
	"guard": {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_IN_OUT},
	# Matched quadratic slopes accelerate into contact without the exponential
	# velocity spike that previously snapped into the follow-through segment.
	"strike": {"trans": Tween.TRANS_QUAD, "ease": Tween.EASE_IN},
	# The paired quadratic ease-out preserves direction and bleeds speed only
	# after contact, keeping the blade moving through the target.
	"follow": {"trans": Tween.TRANS_QUAD, "ease": Tween.EASE_OUT},
	"recover": {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_IN_OUT},
}
const BIPED_ATTACK_FOOTWORK := {
	"jab": {
		"chamber": {"y": 4.0, "left_leg": 20.0, "left_shin": -8.0, "right_leg": -28.0, "right_shin": 38.0},
		"strike": {"y": 1.0, "left_leg": 28.0, "left_shin": -12.0, "right_leg": -36.0, "right_shin": 22.0},
		"recover": {"y": 0.0, "left_leg": 6.0, "left_shin": -3.0, "right_leg": -8.0, "right_shin": 10.0},
	},
	"forehand": {
		"chamber": {"y": 3.0, "left_leg": 18.0, "left_shin": -6.0, "right_leg": -22.0, "right_shin": 34.0},
		"guard": {"y": 4.0, "left_leg": 14.0, "left_shin": -5.0, "right_leg": -28.0, "right_shin": 40.0},
		"strike": {"y": 1.0, "left_leg": -24.0, "left_shin": 28.0, "right_leg": 20.0, "right_shin": -8.0},
		"follow": {"y": 2.0, "left_leg": -18.0, "left_shin": 20.0, "right_leg": 15.0, "right_shin": -6.0},
	},
	"backhand": {
		"chamber": {"y": 3.0, "left_leg": -20.0, "left_shin": 32.0, "right_leg": 16.0, "right_shin": -6.0},
		"guard": {"y": 4.0, "left_leg": -26.0, "left_shin": 38.0, "right_leg": 19.0, "right_shin": -8.0},
		"strike": {"y": 1.0, "left_leg": 22.0, "left_shin": -8.0, "right_leg": -28.0, "right_shin": 38.0},
		"follow": {"y": 2.0, "left_leg": 25.0, "left_shin": -10.0, "right_leg": -20.0, "right_shin": 30.0},
	},
}
const CENTAUR_ATTACK_FOOTWORK := {
	"jab": {
		"chamber": {"y": 3.0, "horse_tail": -10.0, "horse_leg_0": 18.0, "horse_shin_0": -8.0, "horse_leg_1": -18.0, "horse_shin_1": 28.0, "horse_leg_2": 14.0, "horse_shin_2": -6.0, "horse_leg_3": -20.0, "horse_shin_3": 32.0},
		"strike": {"y": -1.0, "horse_tail": 8.0, "horse_leg_0": -18.0, "horse_shin_0": 30.0, "horse_leg_1": 16.0, "horse_shin_1": -7.0, "horse_leg_2": -22.0, "horse_shin_2": 34.0, "horse_leg_3": 18.0, "horse_shin_3": -8.0},
		"recover": {"y": 0.0, "horse_tail": 0.0},
	},
	"forehand": {
		"chamber": {"y": 2.0, "horse_tail": 12.0, "horse_leg_0": -16.0, "horse_shin_0": 28.0, "horse_leg_1": 13.0, "horse_shin_1": -5.0, "horse_leg_2": 18.0, "horse_shin_2": -8.0, "horse_leg_3": -20.0, "horse_shin_3": 32.0},
		"guard": {"y": 4.0, "horse_tail": 15.0, "horse_leg_0": -22.0, "horse_shin_0": 36.0, "horse_leg_1": 18.0, "horse_shin_1": -8.0, "horse_leg_2": 20.0, "horse_shin_2": -9.0, "horse_leg_3": -24.0, "horse_shin_3": 38.0},
		"strike": {"y": -1.0, "horse_tail": -10.0, "horse_leg_0": 20.0, "horse_shin_0": -8.0, "horse_leg_1": -22.0, "horse_shin_1": 34.0, "horse_leg_2": -18.0, "horse_shin_2": 30.0, "horse_leg_3": 16.0, "horse_shin_3": -7.0},
		"follow": {"y": 1.0, "horse_tail": -7.0, "horse_leg_0": 15.0, "horse_shin_0": -6.0, "horse_leg_1": -16.0, "horse_shin_1": 25.0, "horse_leg_2": -13.0, "horse_shin_2": 22.0, "horse_leg_3": 12.0, "horse_shin_3": -5.0},
	},
	"backhand": {
		"chamber": {"y": 2.0, "horse_tail": -12.0, "horse_leg_0": 17.0, "horse_shin_0": -7.0, "horse_leg_1": -20.0, "horse_shin_1": 32.0, "horse_leg_2": -16.0, "horse_shin_2": 28.0, "horse_leg_3": 14.0, "horse_shin_3": -6.0},
		"guard": {"y": 4.0, "horse_tail": -15.0, "horse_leg_0": 21.0, "horse_shin_0": -9.0, "horse_leg_1": -24.0, "horse_shin_1": 38.0, "horse_leg_2": -20.0, "horse_shin_2": 34.0, "horse_leg_3": 18.0, "horse_shin_3": -8.0},
		"strike": {"y": -1.0, "horse_tail": 10.0, "horse_leg_0": -22.0, "horse_shin_0": 34.0, "horse_leg_1": 18.0, "horse_shin_1": -8.0, "horse_leg_2": 20.0, "horse_shin_2": -8.0, "horse_leg_3": -18.0, "horse_shin_3": 30.0},
		"follow": {"y": 1.0, "horse_tail": 7.0, "horse_leg_0": -16.0, "horse_shin_0": 25.0, "horse_leg_1": 13.0, "horse_shin_1": -5.0, "horse_leg_2": 15.0, "horse_shin_2": -6.0, "horse_leg_3": -13.0, "horse_shin_3": 22.0},
	},
}
const BIPED_RANGED_FOOTWORK := {
	"bow": {
		"ready": {"y": 2.0, "left_leg": 18.0, "left_shin": -6.0, "right_leg": -20.0, "right_shin": 30.0},
		"draw": {"y": 3.0, "left_leg": 24.0, "left_shin": -8.0, "right_leg": -26.0, "right_shin": 36.0},
		"recoil": {"y": 1.0, "left_leg": 20.0, "left_shin": -6.0, "right_leg": -22.0, "right_shin": 30.0},
	},
	"staff": {
		"gather": {"y": 3.0, "left_leg": 16.0, "left_shin": -5.0, "right_leg": -22.0, "right_shin": 34.0},
		"release": {"y": 0.0, "left_leg": -18.0, "left_shin": 22.0, "right_leg": 20.0, "right_shin": -7.0},
	},
}
const CENTAUR_RANGED_FOOTWORK := {
	"bow": {
		"ready": {"y": 2.0, "horse_tail": 8.0, "horse_leg_0": -14.0, "horse_shin_0": 24.0, "horse_leg_1": 12.0, "horse_shin_1": -5.0, "horse_leg_2": 14.0, "horse_shin_2": -6.0, "horse_leg_3": -16.0, "horse_shin_3": 27.0},
		"draw": {"y": 3.0, "horse_tail": 12.0, "horse_leg_0": -20.0, "horse_shin_0": 32.0, "horse_leg_1": 17.0, "horse_shin_1": -7.0, "horse_leg_2": 18.0, "horse_shin_2": -8.0, "horse_leg_3": -22.0, "horse_shin_3": 35.0},
		"recoil": {"y": 1.0, "horse_tail": -7.0, "horse_leg_0": -16.0, "horse_shin_0": 26.0, "horse_leg_1": 14.0, "horse_shin_1": -6.0, "horse_leg_2": 15.0, "horse_shin_2": -6.0, "horse_leg_3": -18.0, "horse_shin_3": 29.0},
	},
	"staff": {
		"gather": {"y": 3.0, "horse_tail": -11.0, "horse_leg_0": 16.0, "horse_shin_0": -7.0, "horse_leg_1": -20.0, "horse_shin_1": 32.0, "horse_leg_2": -18.0, "horse_shin_2": 29.0, "horse_leg_3": 14.0, "horse_shin_3": -6.0},
		"release": {"y": -1.0, "horse_tail": 10.0, "horse_leg_0": -20.0, "horse_shin_0": 32.0, "horse_leg_1": 17.0, "horse_shin_1": -7.0, "horse_leg_2": 19.0, "horse_shin_2": -8.0, "horse_leg_3": -17.0, "horse_shin_3": 28.0},
	},
}
const WEAPON_GRIP_ROTATIONS := {
	"sword": -90.0,
	"axe": -90.0,
	"spear": 180.0,
	"staff": 180.0,
	"branch_staff": 180.0,
	"bow": 90.0,
	"crossbow": -90.0,
}
const BALLISTIC_PROJECTILE_TRANSITION := Tween.TRANS_LINEAR
const LANTERN_HANG_RESPONSE := 14.0
const LANTERN_IDLE_SWAY_DEGREES := 2.0
const ANATOMY_JOINT_OVERLAP_RATIO := .28
const ANATOMY_JOINT_OVERLAP_MAX := 6.0
const FROST_TROLL_JOINT_OVERLAP_RATIO := .36
const FROST_TROLL_JOINT_OVERLAP_MAX := 10.0
const BIPED_RUN_CYCLE := [
	# Contact, compression, passing, and recovery for the lead leg, followed
	# by the same four phases mirrored onto the opposite leg.
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": -35.0, "left_forearm": -80.0, "right_arm": 30.0, "right_forearm": -95.0, "left_leg": -62.0, "left_shin": 5.0, "right_leg": 55.0, "right_shin": -5.0}},
	{"y": 3.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -30.0, "left_forearm": -85.0, "right_arm": 20.0, "right_forearm": -100.0, "left_leg": -32.0, "left_shin": 42.0, "right_leg": 28.0, "right_shin": 25.0}},
	{"y": 5.0, "rotations": {"torso": 14.0, "head": -4.0, "left_arm": -15.0, "left_forearm": -95.0, "right_arm": 5.0, "right_forearm": -90.0, "left_leg": 4.0, "left_shin": 72.0, "right_leg": 4.0, "right_shin": 12.0}},
	{"y": -4.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": 15.0, "left_forearm": -105.0, "right_arm": -25.0, "right_forearm": -75.0, "left_leg": 45.0, "left_shin": -5.0, "right_leg": -55.0, "right_shin": 5.0}},
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": 30.0, "left_forearm": -95.0, "right_arm": -35.0, "right_forearm": -80.0, "left_leg": 38.0, "left_shin": -8.0, "right_leg": -46.0, "right_shin": 10.0}},
	{"y": 3.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": 20.0, "left_forearm": -100.0, "right_arm": -30.0, "right_forearm": -85.0, "left_leg": 28.0, "left_shin": 25.0, "right_leg": -32.0, "right_shin": 42.0}},
	{"y": 5.0, "rotations": {"torso": 14.0, "head": -4.0, "left_arm": 5.0, "left_forearm": -90.0, "right_arm": -15.0, "right_forearm": -95.0, "left_leg": 4.0, "left_shin": 12.0, "right_leg": 4.0, "right_shin": 72.0}},
	{"y": -4.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -25.0, "left_forearm": -75.0, "right_arm": 15.0, "right_forearm": -105.0, "left_leg": -55.0, "left_shin": 5.0, "right_leg": 45.0, "right_shin": -5.0}},
]
const CENTAUR_RUN_CYCLE := [
	# Eight-phase diagonal-pair gallop. Horse legs 0/3 travel together while
	# 1/2 form the opposing pair, but compression and passing poses bend every
	# knee independently enough to avoid the old two-frame rocking silhouette.
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": -78.0, "left_forearm": -14.0, "right_arm": 13.0, "right_forearm": -66.0, "horse_tail": -15.0, "horse_leg_0": -42.0, "horse_shin_0": 10.0, "horse_leg_1": 38.0, "horse_shin_1": -10.0, "horse_leg_2": 38.0, "horse_shin_2": -10.0, "horse_leg_3": -42.0, "horse_shin_3": 10.0}},
	{"y": 3.0, "rotations": {"torso": 11.0, "head": -3.0, "left_arm": -74.0, "left_forearm": -18.0, "right_arm": 8.0, "right_forearm": -63.0, "horse_tail": -9.0, "horse_leg_0": -25.0, "horse_shin_0": 45.0, "horse_leg_1": 22.0, "horse_shin_1": 25.0, "horse_leg_2": 22.0, "horse_shin_2": 25.0, "horse_leg_3": -25.0, "horse_shin_3": 45.0}},
	{"y": 5.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -68.0, "left_forearm": -23.0, "right_arm": 2.0, "right_forearm": -58.0, "horse_tail": -2.0, "horse_leg_0": 2.0, "horse_shin_0": 72.0, "horse_leg_1": 4.0, "horse_shin_1": 15.0, "horse_leg_2": 4.0, "horse_shin_2": 15.0, "horse_leg_3": 2.0, "horse_shin_3": 72.0}},
	{"y": -4.0, "rotations": {"torso": 11.0, "head": -3.0, "left_arm": -62.0, "left_forearm": -27.0, "right_arm": -3.0, "right_forearm": -53.0, "horse_tail": 10.0, "horse_leg_0": 38.0, "horse_shin_0": -8.0, "horse_leg_1": -45.0, "horse_shin_1": 12.0, "horse_leg_2": -45.0, "horse_shin_2": 12.0, "horse_leg_3": 38.0, "horse_shin_3": -8.0}},
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": -58.0, "left_forearm": -30.0, "right_arm": -8.0, "right_forearm": -50.0, "horse_tail": 15.0, "horse_leg_0": 38.0, "horse_shin_0": -10.0, "horse_leg_1": -42.0, "horse_shin_1": 10.0, "horse_leg_2": -42.0, "horse_shin_2": 10.0, "horse_leg_3": 38.0, "horse_shin_3": -10.0}},
	{"y": 3.0, "rotations": {"torso": 11.0, "head": -3.0, "left_arm": -62.0, "left_forearm": -27.0, "right_arm": -3.0, "right_forearm": -53.0, "horse_tail": 9.0, "horse_leg_0": 22.0, "horse_shin_0": 25.0, "horse_leg_1": -25.0, "horse_shin_1": 45.0, "horse_leg_2": -25.0, "horse_shin_2": 45.0, "horse_leg_3": 22.0, "horse_shin_3": 25.0}},
	{"y": 5.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -68.0, "left_forearm": -23.0, "right_arm": 2.0, "right_forearm": -58.0, "horse_tail": 2.0, "horse_leg_0": 4.0, "horse_shin_0": 15.0, "horse_leg_1": 2.0, "horse_shin_1": 72.0, "horse_leg_2": 2.0, "horse_shin_2": 72.0, "horse_leg_3": 4.0, "horse_shin_3": 15.0}},
	{"y": -4.0, "rotations": {"torso": 11.0, "head": -3.0, "left_arm": -74.0, "left_forearm": -18.0, "right_arm": 8.0, "right_forearm": -63.0, "horse_tail": -10.0, "horse_leg_0": -45.0, "horse_shin_0": 12.0, "horse_leg_1": 38.0, "horse_shin_1": -8.0, "horse_leg_2": 38.0, "horse_shin_2": -8.0, "horse_leg_3": -45.0, "horse_shin_3": 12.0}},
]
const BIPED_STAIR_CYCLE := [
	# In-place ascent preview: each foot reaches one tread ahead, accepts the
	# body weight, then drives the hip upward while the trailing knee passes.
	{"y": 0.0, "rotations": {"torso": 5.0, "head": -1.0, "left_arm": -25.0, "left_forearm": -70.0, "right_arm": 20.0, "right_forearm": -55.0, "left_leg": -55.0, "left_shin": 62.0, "right_leg": 15.0, "right_shin": -5.0}},
	{"y": -6.0, "rotations": {"torso": 7.0, "head": -2.0, "left_arm": -18.0, "left_forearm": -76.0, "right_arm": 12.0, "right_forearm": -62.0, "left_leg": -38.0, "left_shin": 35.0, "right_leg": 25.0, "right_shin": 15.0}},
	{"y": -12.0, "rotations": {"torso": 8.0, "head": -2.0, "left_arm": -10.0, "left_forearm": -82.0, "right_arm": 4.0, "right_forearm": -68.0, "left_leg": -10.0, "left_shin": 5.0, "right_leg": 38.0, "right_shin": 30.0}},
	{"y": -8.0, "rotations": {"torso": 7.0, "head": -2.0, "left_arm": 8.0, "left_forearm": -88.0, "right_arm": -15.0, "right_forearm": -62.0, "left_leg": 18.0, "left_shin": -8.0, "right_leg": -48.0, "right_shin": 75.0}},
	{"y": 0.0, "rotations": {"torso": 5.0, "head": -1.0, "left_arm": 20.0, "left_forearm": -55.0, "right_arm": -25.0, "right_forearm": -70.0, "left_leg": 15.0, "left_shin": -5.0, "right_leg": -55.0, "right_shin": 62.0}},
	{"y": -6.0, "rotations": {"torso": 7.0, "head": -2.0, "left_arm": 12.0, "left_forearm": -62.0, "right_arm": -18.0, "right_forearm": -76.0, "left_leg": 25.0, "left_shin": 15.0, "right_leg": -38.0, "right_shin": 35.0}},
	{"y": -12.0, "rotations": {"torso": 8.0, "head": -2.0, "left_arm": 4.0, "left_forearm": -68.0, "right_arm": -10.0, "right_forearm": -82.0, "left_leg": 38.0, "left_shin": 30.0, "right_leg": -10.0, "right_shin": 5.0}},
	{"y": -8.0, "rotations": {"torso": 7.0, "head": -2.0, "left_arm": -15.0, "left_forearm": -62.0, "right_arm": 8.0, "right_forearm": -88.0, "left_leg": -48.0, "left_shin": 75.0, "right_leg": 18.0, "right_shin": -8.0}},
]
const CENTAUR_STAIR_CYCLE := [
	{"y": 0.0, "rotations": {"torso": 6.0, "head": -1.0, "left_arm": -30.0, "left_forearm": -68.0, "right_arm": 18.0, "right_forearm": -58.0, "horse_tail": -7.0, "horse_leg_0": 18.0, "horse_shin_0": -5.0, "horse_leg_1": -35.0, "horse_shin_1": 58.0, "horse_leg_2": 12.0, "horse_shin_2": 5.0, "horse_leg_3": -45.0, "horse_shin_3": 64.0}},
	{"y": -10.0, "rotations": {"torso": 8.0, "head": -2.0, "left_arm": -15.0, "left_forearm": -76.0, "right_arm": 5.0, "right_forearm": -64.0, "horse_tail": 0.0, "horse_leg_0": 30.0, "horse_shin_0": 20.0, "horse_leg_1": -10.0, "horse_shin_1": 15.0, "horse_leg_2": -12.0, "horse_shin_2": 36.0, "horse_leg_3": -20.0, "horse_shin_3": 28.0}},
	{"y": 0.0, "rotations": {"torso": 6.0, "head": -1.0, "left_arm": 18.0, "left_forearm": -58.0, "right_arm": -30.0, "right_forearm": -68.0, "horse_tail": 7.0, "horse_leg_0": -35.0, "horse_shin_0": 58.0, "horse_leg_1": 18.0, "horse_shin_1": -5.0, "horse_leg_2": -45.0, "horse_shin_2": 64.0, "horse_leg_3": 12.0, "horse_shin_3": 5.0}},
	{"y": -10.0, "rotations": {"torso": 8.0, "head": -2.0, "left_arm": 5.0, "left_forearm": -64.0, "right_arm": -15.0, "right_forearm": -76.0, "horse_tail": 0.0, "horse_leg_0": -10.0, "horse_shin_0": 15.0, "horse_leg_1": 30.0, "horse_shin_1": 20.0, "horse_leg_2": -20.0, "horse_shin_2": 28.0, "horse_leg_3": -12.0, "horse_shin_3": 36.0}},
]
const ATTACK_CURVES := {
	"jab": [
		# Pull the elbow well behind the torso, then drive the shoulder, hand,
		# and horizontal blade through a long straight thrust. A short carry
		# continues through contact and decelerates before withdrawal reverses.
		{"phase": "chamber", "upper": 105.0, "forearm": -105.0, "torso": 13.0, "x": -24.0, "duration": 0.22},
		{"phase": "strike", "upper": -55.0, "forearm": 55.0, "torso": -15.0, "x": 36.0, "duration": 0.12},
		{"phase": "follow", "upper": -62.0, "forearm": 62.0, "torso": -12.0, "x": 44.0, "duration": 0.08},
	],
	"forehand": [
		# Open into a high reach-back, snap through a broad diagonal cutting
		# line, and carry the blade beyond the target into a visible follow-through.
		{"phase": "chamber", "upper": -190.0, "forearm": -70.0, "torso": -13.0, "x": -16.0, "duration": 0.23},
		{"phase": "guard", "upper": -155.0, "forearm": 45.0, "torso": -17.0, "x": -20.0, "duration": 0.10},
		{"phase": "strike", "upper": -55.0, "forearm": 85.0, "torso": 18.0, "x": 24.0, "duration": 0.12},
		{"phase": "follow", "upper": 15.0, "forearm": 65.0, "torso": 12.0, "x": 18.0, "duration": 0.10},
	],
	"backhand": [
		# Circle the weapon hand across the far shoulder, settle the blade beside
		# the far hip on a low diagonal, then unwind into a rising reverse cut.
		# The hand continues beyond contact instead of snapping straight home.
		{"phase": "chamber", "upper": 70.0, "forearm": 55.0, "torso": 12.0, "x": -14.0, "duration": 0.20},
		{"phase": "guard", "upper": 25.0, "forearm": 45.0, "torso": 8.0, "x": -8.0, "duration": 0.08},
		{"phase": "strike", "upper": -45.0, "forearm": 0.0, "torso": -16.0, "x": 28.0, "duration": 0.11},
		{"phase": "follow", "upper": -90.0, "forearm": 15.0, "torso": -12.0, "x": 20.0, "duration": 0.12},
	],
}
const WEAPON_ATTACK_CURVES := {
	"spear": {
		"jab": [
			# Drop into a low, deep chamber while turning the upright spear flat.
			{"phase": "chamber", "upper": 85.0, "forearm": -85.0, "torso": 11.0, "x": -30.0, "weapon_rotation": 259.0, "duration": 0.22},
			# Drive the point through a long, level thrust from below.
			{"phase": "strike", "upper": -60.0, "forearm": 60.0, "torso": -16.0, "x": 42.0, "weapon_rotation": 286.0, "duration": 0.13},
			# Continue the point past contact while bleeding speed along the same
			# horizontal line, then reverse only after reaching full extension.
			{"phase": "follow", "upper": -65.0, "forearm": 65.0, "torso": -16.0, "x": 60.0, "weapon_rotation": 286.0, "duration": 0.05},
			# Withdraw and stand the spear upright before settling into idle.
			{"phase": "recover", "upper": 15.0, "forearm": -15.0, "torso": 0.0, "x": 0.0, "weapon_rotation": 180.0, "duration": 0.18},
		],
	},
	"two_handed_axe": {
		"forehand": [
			# Both grips remain reachable while the long shaft rotates from a
			# rear overhead load through a diagonal strike. The torso continues
			# through contact so the long tip keeps its downward path while both
			# shaft sockets stay inside the support arm's IK envelope.
			{"phase": "chamber", "upper": -120.0, "forearm": 60.0, "torso": -10.0, "x": -12.0, "duration": 0.22},
			{"phase": "guard", "upper": -100.0, "forearm": 70.0, "torso": -14.0, "x": -8.0, "duration": 0.10},
			{"phase": "strike", "upper": -100.0, "forearm": 130.0, "torso": 16.0, "x": 22.0, "duration": 0.13},
			{"phase": "follow", "upper": -120.0, "forearm": 165.0, "torso": 40.0, "x": 28.0, "duration": 0.10},
		],
		"backhand": [
			# The larger two-handed weapon uses the same four readable beats but
			# keeps both grip sockets within the support arm's proven IK envelope.
			# These arm pairs traverse the reachable forehand envelope in reverse.
			{"phase": "chamber", "upper": -120.0, "forearm": 165.0, "torso": 10.0, "x": -8.0, "duration": 0.21},
			{"phase": "guard", "upper": -100.0, "forearm": 130.0, "torso": 7.0, "x": -4.0, "duration": 0.09},
			{"phase": "strike", "upper": -100.0, "forearm": 70.0, "torso": -12.0, "x": 18.0, "duration": 0.13},
			{"phase": "follow", "upper": -120.0, "forearm": 60.0, "torso": -14.0, "x": 14.0, "duration": 0.12},
		],
	},
}

# Each named lineage gesture gets its own staged silhouette rather than merely
# aliasing one of the generic slash/thrust/cast helpers. Pose arrays are:
# torso, left upper/lower arm, right upper/lower arm, rig x, rig y.
const RACE_GESTURE_MOTIONS := {
	"bogkin_0": {"windup": [10,-70,-40,90,-130,-6,2], "impact": [-8,-95,-10,-85,5,18,0], "times": [.16,.10,.08]},
	"bogkin_1": {"windup": [15,25,-110,-20,-100,0,10], "impact": [-8,-145,20,140,-20,8,-56], "times": [.18,.22,.06]},
	"bogkin_2": {"windup": [0,-135,20,135,-20,0,4], "impact": [0,-175,0,175,0,0,-8], "times": [.22,.16,.14]},
	"human_0": {"windup": [-14,35,-100,-190,-70,-14,0], "impact": [18,-35,-70,-55,85,25,2], "times": [.20,.13,.08]},
	"human_1": {"windup": [12,-15,-75,75,-110,-22,3], "impact": [-14,-90,-10,-55,50,34,1], "times": [.18,.14,.10]},
	"human_2": {"windup": [15,40,-90,-30,-80,-4,12], "impact": [-10,-150,20,130,-10,20,-62], "times": [.18,.24,.06]},
	"centaur_0": {"windup": [8,-88,-8,-78,-12,-18,-4], "impact": [12,-70,-15,-25,-25,34,-8], "times": [.20,.12,.08]},
	"centaur_1": {"windup": [10,-30,-80,-145,35,-10,10], "impact": [-12,-130,10,-25,75,16,-36], "times": [.22,.18,.10]},
	"centaur_2": {"windup": [0,-150,15,150,-15,0,2], "impact": [18,-178,0,178,0,0,-18], "times": [.24,.18,.14]},
	"fae_0": {"windup": [-12,45,-20,-175,-35,-10,-12], "impact": [16,-30,-60,-40,95,20,-28], "times": [.17,.12,.07]},
	"fae_1": {"windup": [18,25,-80,-35,-80,-16,2], "impact": [-16,-120,10,105,-15,42,-18], "times": [.18,.14,.08]},
	"fae_2": {"windup": [0,-160,5,160,-5,0,-14], "impact": [0,-180,0,180,0,0,-38], "times": [.22,.20,.16]},
	"frost_troll_0": {"windup": [-16,45,-110,-160,40,-14,5], "impact": [22,-35,-45,-65,95,28,12], "times": [.26,.13,.12]},
	"frost_troll_1": {"windup": [14,-30,-80,70,-115,-26,8], "impact": [-12,-85,-5,-40,35,40,4], "times": [.22,.16,.12]},
	"frost_troll_2": {"windup": [10,40,-100,-40,-100,0,14], "impact": [24,-130,20,120,-20,14,-38], "times": [.24,.20,.14]},
	"goblin_0": {"windup": [6,-85,-5,-65,-135,-12,1], "impact": [-8,-75,-10,35,-45,22,-4], "times": [.14,.09,.07]},
	"goblin_1": {"windup": [18,30,-110,-135,-10,-18,10], "impact": [-22,-45,-35,35,80,28,5], "times": [.16,.10,.08]},
	"goblin_2": {"windup": [-10,-120,45,90,-135,-8,4], "impact": [12,-165,0,155,0,18,-22], "times": [.20,.12,.16]},
	"duneborn_0": {"windup": [12,95,-105,35,-100,-28,2], "impact": [-16,-58,58,-70,70,40,0], "times": [.20,.12,.08]},
	"duneborn_1": {"windup": [-18,45,-40,-150,10,-12,-2], "impact": [20,-35,-70,-35,105,24,-6], "times": [.18,.14,.10]},
	"duneborn_2": {"windup": [0,-145,30,145,-30,0,0], "impact": [0,-175,0,175,0,-8,-12], "times": [.24,.18,.16]},
	"frostling_0": {"windup": [10,100,-110,20,-90,-20,4], "impact": [-14,-60,60,-40,45,32,0], "times": [.18,.11,.08]},
	"frostling_1": {"windup": [0,-150,10,150,-10,0,4], "impact": [0,-180,0,180,0,0,-22], "times": [.22,.18,.16]},
	"frostling_2": {"windup": [20,35,-105,-30,-100,-6,12], "impact": [-10,-130,15,120,-20,20,-44], "times": [.18,.22,.10]},
}
const RACE_GESTURE_EFFECTS := {
	"bogkin_0": {"effect":"tongue_snap", "anchor":"head"},
	"bogkin_1": {"effect":"lily_leap", "anchor":"ground", "offset":Vector2(0,-14), "scale":1.2},
	"bogkin_2": {"effect":"bog_burst", "anchor":"front", "offset":Vector2(14,0), "scale":1.45},
	"human_0": {"effect":"crosscut", "anchor":"weapon"},
	"human_1": {"effect":"shield_rush", "anchor":"front", "offset":Vector2(12,0), "scale":1.3},
	"human_2": {"effect":"heroic_vault", "anchor":"ground", "offset":Vector2(0,-18)},
	"centaur_0": {"effect":"gallop_shot", "anchor":"hand"},
	"centaur_1": {"effect":"rearing_strike", "anchor":"ground", "offset":Vector2(45,-30), "scale":1.5},
	"centaur_2": {"effect":"grove_tempest", "anchor":"torso"},
	"fae_0": {"effect":"wand_arc", "anchor":"weapon"},
	"fae_1": {"effect":"gale_step", "anchor":"ground"},
	"fae_2": {"effect":"star_bloom", "anchor":"front", "offset":Vector2(18,-4), "scale":1.45},
	"frost_troll_0": {"effect":"glacier_cleave", "anchor":"weapon"},
	"frost_troll_1": {"effect":"boulder_rush", "anchor":"ground", "offset":Vector2(42,-28), "scale":1.4},
	"frost_troll_2": {"effect":"avalanche", "anchor":"ground", "offset":Vector2(0,-20), "scale":1.2},
	"goblin_0": {"effect":"snap_shot", "anchor":"hand"},
	"goblin_1": {"effect":"low_blow", "anchor":"weapon"},
	"goblin_2": {"effect":"powder_keg", "anchor":"front"},
	"duneborn_0": {"effect":"sirocco_thrust", "anchor":"hand"},
	"duneborn_1": {"effect":"crescent_guard", "anchor":"torso"},
	"duneborn_2": {"effect":"sand_veil", "anchor":"torso", "scale":1.25},
	"frostling_0": {"effect":"crystal_jab", "anchor":"hand"},
	"frostling_1": {"effect":"aurora_pulse", "anchor":"torso"},
	"frostling_2": {"effect":"snowdrift", "anchor":"ground", "offset":Vector2(0,-12), "scale":1.15},
}
const DETACHED_GESTURE_EFFECT_ANCHORS := ["weapon","hand","front","ground"]
const RACE_GESTURE_FOOTWORK := {
	"bogkin_0": {"kind":"crouch", "intensity":.82},
	"bogkin_1": {"kind":"leap", "intensity":.96},
	"bogkin_2": {"kind":"cast", "intensity":.74},
	"human_0": {"kind":"slash", "intensity":.88},
	"human_1": {"kind":"lunge", "intensity":1.0},
	"human_2": {"kind":"leap", "intensity":.94},
	"centaur_0": {"kind":"gallop", "intensity":.86},
	"centaur_1": {"kind":"rear", "intensity":1.0},
	"centaur_2": {"kind":"cast", "intensity":.78},
	"fae_0": {"kind":"slash", "intensity":.72},
	"fae_1": {"kind":"dash", "intensity":.90},
	"fae_2": {"kind":"hover", "intensity":.68},
	"frost_troll_0": {"kind":"smash", "intensity":1.0},
	"frost_troll_1": {"kind":"lunge", "intensity":.92},
	"frost_troll_2": {"kind":"leap", "intensity":.98},
	"goblin_0": {"kind":"crouch", "intensity":.80},
	"goblin_1": {"kind":"lunge", "intensity":.87},
	"goblin_2": {"kind":"cast", "intensity":.76},
	"duneborn_0": {"kind":"lunge", "intensity":.93},
	"duneborn_1": {"kind":"brace", "intensity":.84},
	"duneborn_2": {"kind":"cast", "intensity":.72},
	"frostling_0": {"kind":"lunge", "intensity":.85},
	"frostling_1": {"kind":"cast", "intensity":.74},
	"frostling_2": {"kind":"leap", "intensity":.91},
}

var race_id := "human"
var loadout := {
	"weapon": "sword", "offhand": "shield", "armor": "leather",
	"pants": "cloth", "boots": "leather", "head": "none", "back": "cape", "accessory": "none",
}
var _profile: Dictionary
var _bones := {}
var _gear := {}
var _active_tween: Tween
var _rest := {}
var _idle_phase := 0.0
var _gesturing := false
var current_motion: StringName = &"idle"
var facing: StringName = &"right"
var _head_visual: PartVisual
var _head_base: BaseAnatomyVisual
var _left_hand_base: BaseAnatomyVisual
var _right_hand_base: BaseAnatomyVisual
var _left_foot_base: BaseAnatomyVisual
var _right_foot_base: BaseAnatomyVisual
var _horse_tail_base: BaseAnatomyVisual
var _horse_body_visual: PartVisual
var _horse_neck_visual: PartVisual
var _pants_parts: Array[GearVisual] = []
var _boot_parts: Array[GearVisual] = []
var _slash_trail: Node2D
var _gesture_effects: Array[Node2D] = []


func _ready() -> void:
	configure(race_id, loadout)


# This is the module's public seam. The builder/gameplay code never touches bones.
func configure(new_race_id: String, new_loadout: Dictionary = {}) -> void:
	race_id = new_race_id if CharacterCatalog.RACES.has(new_race_id) else "human"
	for slot in new_loadout:
		if loadout.has(slot): loadout[slot] = new_loadout[slot]
	if loadout.weapon in ["bow","crossbow"] or _has_two_handed_axe_loadout():
		loadout.offhand = "none"
	_rebuild()


func equip(slot: StringName, item_id: String) -> bool:
	if not slot in CharacterCatalog.SLOT_ORDER or not item_id in CharacterCatalog.items_for(slot):
		return false
	if not supports_equipment_slot(slot):
		return false
	var had_two_handed_axe := _has_two_handed_axe_loadout()
	var had_crossbow: bool = loadout.weapon == "crossbow"
	loadout[String(slot)] = item_id
	if slot == &"weapon" and (item_id in ["bow","crossbow"] or _has_two_handed_axe_loadout()) and loadout.offhand != "none":
		loadout.offhand = "none"
		var offhand_visual: GearVisual = _gear.get("offhand")
		if offhand_visual:
			offhand_visual.setup("offhand","none",_profile.accent)
			_apply_gear_presentation("offhand","none",offhand_visual)
			equipment_changed.emit(&"offhand","none")
	var has_two_handed_axe := _has_two_handed_axe_loadout()
	var has_crossbow: bool = loadout.weapon == "crossbow"
	if had_two_handed_axe != has_two_handed_axe or had_crossbow != has_crossbow:
		_rebuild()
		equipment_changed.emit(slot,item_id)
		return true
	if slot == &"pants":
		for pants_visual in _pants_parts:
			pants_visual.setup("pants",item_id,_profile.accent)
		if race_id == "human":
			_update_human_trousers()
		equipment_changed.emit(slot,item_id)
		return true
	if slot == &"boots":
		for boot_visual in _boot_parts:
			boot_visual.setup("boots",item_id,_profile.accent)
		_update_base_foot_visibility()
		equipment_changed.emit(slot,item_id)
		return true
	var visual: GearVisual = _gear.get(String(slot))
	if visual:
		visual.setup(String(slot), item_id, _profile.accent)
		_apply_gear_presentation(String(slot), item_id, visual)
	if slot == &"weapon" or (race_id == "human" and slot == &"offhand"):
		_apply_weapon_hand_parts()
	if slot == &"armor" and race_id == "human":
		_update_human_sleeves()
	equipment_changed.emit(slot, item_id)
	return true


func supports_equipment_slot(slot: StringName) -> bool:
	if slot in [&"pants", &"boots"] and _profile.topology == "centaur":
		return false
	if slot == &"offhand" and (loadout.weapon in ["bow","crossbow"] or _has_two_handed_axe_loadout()):
		return false
	return true


func _has_two_handed_axe_loadout() -> bool:
	return race_id == "frost_troll" and loadout.weapon == "axe"


func _uses_two_handed_axe() -> bool:
	return _has_two_handed_axe_loadout() and current_motion != &"climb"


func _uses_crossbow() -> bool:
	return loadout.weapon == "crossbow" and current_motion != &"climb"


func _is_staff_weapon() -> bool:
	return loadout.weapon in STAFF_WEAPONS


func available_gestures() -> Array:
	return _profile.get("gestures", [])


func play_gesture(index: int) -> void:
	var gestures: Array = available_gestures()
	if index < 0 or index >= gestures.size(): return
	var gesture: Dictionary = gestures[index]
	_play_action(gesture.name, gesture.style, "%s_%d" % [race_id,index])


func available_weapon_attacks() -> Array[StringName]:
	if loadout.weapon == "bow":
		return BOW_ATTACKS.duplicate()
	if loadout.weapon == "crossbow":
		return CROSSBOW_ATTACKS.duplicate()
	if _is_staff_weapon():
		return STAFF_ATTACKS.duplicate()
	return WEAPON_ATTACKS.duplicate()


func available_motions() -> Array[StringName]:
	return MOTIONS.duplicate()


func set_facing(direction: StringName) -> void:
	if direction not in [&"left", &"right"]:
		return
	facing = direction
	_apply_facing()
	if not _gear.is_empty():
		for slot in ["weapon", "offhand"]:
			var visual: GearVisual = _gear.get(slot)
			if visual:
				_apply_gear_presentation(slot, loadout[slot], visual)
	facing_changed.emit(facing)


func play_motion(motion: StringName) -> void:
	if not motion in MOTIONS:
		return
	if motion == &"idle":
		stop_motion()
		return
	_stop_active_animation()
	_restore_pose()
	current_motion = motion
	if motion == &"stand":
		_gesturing = false
		_idle_phase = 0.0
		_set_back_view(false)
		_set_climbing_anatomy(false)
		_set_climbing_gear(false)
		motion_changed.emit(current_motion)
		return
	_gesturing = true
	_set_back_view(motion == &"climb")
	_set_climbing_anatomy(motion == &"climb")
	_set_climbing_gear(motion == &"climb")
	_active_tween = create_tween().set_loops()
	if motion in [&"run", &"stairs"] and _profile.topology != "centaur":
		# Eight closely spaced poses already describe the acceleration curve;
		# linear interpolation keeps velocity continuous through their joins.
		_active_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	else:
		# Two-pose centaur and climb cycles need a soft reversal at each extreme.
		_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if motion == &"run":
		_build_run_loop()
	elif motion == &"stairs":
		_build_stair_loop()
	else:
		_build_climb_loop()
	motion_changed.emit(current_motion)


func stop_motion() -> void:
	_stop_active_animation()
	_restore_pose()
	current_motion = &"idle"
	_gesturing = false
	_idle_phase = 0.0
	_set_back_view(false)
	_set_climbing_anatomy(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)


func play_weapon_attack(attack: StringName = &"forehand") -> void:
	if not attack in available_weapon_attacks():
		return
	_play_action("%s %s" % [String(loadout.weapon).capitalize(), String(attack).capitalize()], String(attack))


func _play_action(action_name: String, style: String, race_motion := "") -> void:
	_stop_active_animation()
	_restore_pose()
	current_motion = &"idle"
	_gesturing = true
	_set_back_view(false)
	_set_climbing_anatomy(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)
	gesture_started.emit(action_name)
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if RACE_GESTURE_MOTIONS.has(race_motion):
		_animate_race_gesture(RACE_GESTURE_MOTIONS[race_motion],race_motion)
	else:
		match style:
			"jab": _animate_weapon_curve("jab")
			"forehand": _animate_weapon_curve("forehand")
			"backhand": _animate_weapon_curve("backhand")
			"fire_bow": _animate_fire_bow()
			"fire_crossbow": _animate_fire_crossbow()
			"cast_spell": _animate_staff_spell()
			"slash": _animate_slash()
			"thrust": _animate_thrust()
			"cast": _animate_cast()
			"smash": _animate_smash()
			"shoot": _animate_shoot()
			_: _animate_leap()
	_active_tween.tween_callback(_finish_gesture)


func _process(delta: float) -> void:
	if not _gesturing and current_motion == &"idle" and _bones.has("rig") and not _rest.is_empty():
		var idle_profile: Dictionary = IDLE_MOTION_PROFILES.get(race_id,IDLE_MOTION_PROFILES.human)
		_idle_phase += delta*float(idle_profile.speed)
		var breath := sin(_idle_phase)
		var secondary := sin(_idle_phase*.73+.65)
		_bones.rig.position.y = _rest.rig.position.y+breath*float(idle_profile.bob)
		_bones.torso.rotation = _rest.torso.rotation+deg_to_rad(breath*float(idle_profile.torso))
		_bones.head.rotation = _rest.head.rotation+deg_to_rad(breath*float(idle_profile.head))
		_bones.left_arm.rotation = _rest.left_arm.rotation+deg_to_rad(secondary*float(idle_profile.arm))
		_bones.right_arm.rotation = _rest.right_arm.rotation-deg_to_rad(secondary*float(idle_profile.arm)*.72)
		_bones.left_forearm.rotation = _rest.left_forearm.rotation-deg_to_rad(secondary*float(idle_profile.forearm))
		_bones.right_forearm.rotation = _rest.right_forearm.rotation+deg_to_rad(secondary*float(idle_profile.forearm)*.72)
		if _profile.topology != "centaur":
			_bones.left_leg.rotation = _rest.left_leg.rotation+deg_to_rad(breath*float(idle_profile.leg))
			_bones.right_leg.rotation = _rest.right_leg.rotation-deg_to_rad(breath*float(idle_profile.leg))
		if _bones.has("horse_tail"):
			_bones.horse_tail.rotation = _rest.horse_tail.rotation+deg_to_rad(sin(_idle_phase*.58)*float(idle_profile.tail))
		if _bones.has("left_wing"):
			var flutter := sin(_idle_phase*1.85)*float(idle_profile.wing)
			_bones.left_wing.rotation = _rest.left_wing.rotation+deg_to_rad(flutter)
			_bones.right_wing.rotation = _rest.right_wing.rotation-deg_to_rad(flutter)
		var fabric_wave := sin(_idle_phase*.61-.4)
		_set_secondary_gear_rotation(fabric_wave*1.8,fabric_wave*1.1)
	if _uses_two_handed_axe():
		_update_two_handed_axe_grip()
	if _uses_crossbow():
		_update_crossbow_support_grip()
	_update_lantern_hang(delta)


func _update_lantern_hang(delta: float) -> void:
	var lantern: GearVisual = _gear.get("offhand")
	if not lantern or lantern.item != "lantern" or lantern.carried_on_back:
		return
	# The animated hand moves the suspension point, but gravity keeps the lamp
	# upright instead of inheriting the complete shoulder/elbow rotation. Idle
	# retains a tiny pendulum drift; active locomotion settles toward vertical.
	var target_rotation := 0.0
	if not _gesturing and current_motion == &"idle":
		target_rotation = deg_to_rad(sin(_idle_phase*.85)*LANTERN_IDLE_SWAY_DEGREES)
	var response := 1.0-exp(-maxf(delta,0.0)*LANTERN_HANG_RESPONSE)
	lantern.global_rotation = lerp_angle(lantern.global_rotation,target_rotation,response)


func _part(parent: Node, name_: String, kind: String, size: Vector2, color: Color, position_: Vector2, z := 0) -> PartVisual:
	var pivot := Node2D.new()
	pivot.name = name_
	pivot.position = position_
	pivot.z_index = z
	parent.add_child(pivot)
	var visual := Part.new().setup(kind, size, color, _profile.accent)
	visual.set_style(_profile.get("visual", {}))
	pivot.add_child(visual)
	var authored_part := _authored_anatomy_part(name_)
	if not authored_part.is_empty() and race_id != "human":
		visual.set_authored_skin(true)
		var anatomy_size := size
		var anatomy_center_y := size.y*.5
		if authored_part in ["upper_arm","forearm","thigh","shin","horse_upper_leg","horse_shin"]:
			# Pull each painted segment back across its parent socket while keeping
			# the wrist/ankle endpoint fixed. Broad alpha overlap hides the paired
			# generated round caps during bends so adjacent pieces read as a single
			# painted limb rather than a bead chain. The Troll needs a deeper seam
			# because its authored biceps and thighs are exceptionally wide.
			var overlap_ratio := FROST_TROLL_JOINT_OVERLAP_RATIO if race_id == "frost_troll" else ANATOMY_JOINT_OVERLAP_RATIO
			var overlap_max := FROST_TROLL_JOINT_OVERLAP_MAX if race_id == "frost_troll" else ANATOMY_JOINT_OVERLAP_MAX
			var joint_overlap := minf(size.x*overlap_ratio,overlap_max)
			anatomy_size.y += joint_overlap
			anatomy_center_y = (size.y-joint_overlap)*.5
		var sprite := BaseAnatomy.new().setup(race_id,authored_part,anatomy_size)
		sprite.name = "AuthoredAnatomy"
		sprite.position = Vector2(0,anatomy_center_y)
		# The humanoid arm sources are painted for the screen-right side. Mirror
		# the anatomical-right chain locally so both arms keep their shoulder,
		# elbow, and wrist shaping pointed outward before the full rig is faced.
		if name_ in ["right_arm","right_forearm"]:
			sprite.set_horizontal_flip(true)
		visual.add_child(sprite)
	_bones[name_] = pivot
	return visual


func _authored_anatomy_part(bone_name: String) -> String:
	# Equine anatomy has its own side/rear body contract and articulated leg
	# pieces; it never stretches the humanoid sheet across four-legged bones.
	if bone_name == "horse_body": return "horse_body"
	if bone_name == "horse_neck": return "horse_neck"
	if bone_name.begins_with("horse_shin_"): return "horse_shin"
	if bone_name.begins_with("horse_leg_"): return "horse_upper_leg"
	match bone_name:
		"torso": return "torso"
		"left_arm", "right_arm": return "upper_arm"
		"left_forearm", "right_forearm": return "forearm"
		"left_leg", "right_leg": return "thigh"
		"left_shin", "right_shin": return "shin"
	return ""


func _base_sprite(parent: Node2D, name_: String, part: String, size: Vector2, position_: Vector2, z: int, rotation_degrees_ := 0.0) -> BaseAnatomyVisual:
	var visual := BaseAnatomy.new().setup(race_id,part,size)
	visual.name = name_
	visual.position = position_
	visual.z_index = z
	visual.rotation_degrees = rotation_degrees_
	parent.add_child(visual)
	return visual


func _rebuild() -> void:
	_stop_active_animation()
	current_motion = &"idle"
	_gesturing = false
	_idle_phase = 0.0
	# Detach immediately so rebuilt sockets keep stable names in the same frame.
	# queue_free() alone leaves the old nodes present until frame end.
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_bones.clear(); _gear.clear(); _rest.clear()
	_horse_tail_base = null
	_horse_body_visual = null
	_horse_neck_visual = null
	_left_foot_base = null
	_right_foot_base = null
	_pants_parts.clear()
	_boot_parts.clear()
	_profile = CharacterCatalog.race(race_id)
	var rig := Node2D.new(); rig.name = "Rig"; add_child(rig); _bones.rig = rig
	_slash_trail = SlashTrail.new()
	_slash_trail.name = "SlashTrail"
	_slash_trail.z_index = 20
	rig.add_child(_slash_trail)
	var shadow := Part.new().setup("shadow", Vector2(118,24), Color.WHITE, Color.TRANSPARENT)
	shadow.position = Vector2(0, 8); shadow.z_index = -20; add_child(shadow)
	var scale_factor: float = _profile.scale
	rig.scale = Vector2.ONE * scale_factor
	var torso_size: Vector2 = _profile.torso
	var head_size: Vector2 = _profile.head
	var skin: Color = _profile.skin
	var limb_width := float(_profile.get("limb_width",16.0))
	var leg_width := float(_profile.get("leg_width",18.0))
	var extremity_scale := float(_profile.get("extremity_scale",1.0))
	var hip_y := -float(_profile.leg)
	var hip := Node2D.new(); hip.name = "Hip"; hip.position = Vector2(0, hip_y); rig.add_child(hip); _bones.hip = hip

	if _profile.topology == "centaur":
		_horse_body_visual = _part(hip, "horse_body", "horse", Vector2(128,62), skin.darkened(.16), Vector2(-12, 18), -1)
		_horse_neck_visual = _part(hip, "horse_neck", "horse_neck", Vector2(62,48), skin.darkened(.10), Vector2(28, -6), -1)
		var tail := Node2D.new()
		tail.name = "horse_tail"
		tail.position = Vector2(-62,24)
		tail.z_index = -4
		hip.add_child(tail)
		_bones.horse_tail = tail
		# The authored tail is rooted at its right edge and flows behind the rump.
		_horse_tail_base = _base_sprite(tail,"HorseTailSprite","horse_tail",Vector2(72,72),Vector2(-33,17),0)
		var horse_upper_length := float(_profile.leg) * .52
		var horse_lower_length := float(_profile.leg) - horse_upper_length
		for i in 4:
			var x := -52.0 + i * 34.0
			var upper_name := "horse_leg_%d" % i
			_part(hip, upper_name, "limb", Vector2(15,horse_upper_length), skin.darkened(.12), Vector2(x,38), -2 if i < 2 else 1)
			_part(_bones[upper_name], "horse_shin_%d" % i, "shin", Vector2(14,horse_lower_length), skin.darkened(.08), Vector2(0,horse_upper_length), 0)
			_base_sprite(_bones["horse_shin_%d" % i],"HoofSprite%d" % i,"hoof",Vector2(28,24),Vector2(0,horse_lower_length),3)
	else:
		var thigh_length := float(_profile.leg) * .52
		var shin_length := float(_profile.leg) - thigh_length
		_part(hip, "left_leg", "limb", Vector2(leg_width,thigh_length), skin.darkened(.08), Vector2(-torso_size.x*.23, 8), -2)
		_part(_bones.left_leg, "left_shin", "shin", Vector2(leg_width*.94,shin_length), skin.darkened(.05), Vector2(0,thigh_length), 0)
		_part(hip, "right_leg", "limb", Vector2(leg_width,thigh_length), skin, Vector2(torso_size.x*.23, 8), 1)
		_part(_bones.right_leg, "right_shin", "shin", Vector2(leg_width*.94,shin_length), skin, Vector2(0,thigh_length), 0)
		_left_foot_base = _base_sprite(_bones.left_shin,"LeftFootSprite","foot",Vector2(28,20)*extremity_scale,Vector2(0,shin_length),4)
		_right_foot_base = _base_sprite(_bones.right_shin,"RightFootSprite","foot",Vector2(28,20)*extremity_scale,Vector2(0,shin_length),4)
		_bones.left_shin.rotation_degrees = 4.0
		_bones.right_shin.rotation_degrees = -4.0

	var torso_x := 30.0 if _profile.topology == "centaur" else 0.0
	# Rotate the torso from its waist seam so leaning never pulls the body away
	# from the hips. The painted torso and all upper-body sockets are offset back
	# to their original screen positions beneath this new pivot.
	var torso_visual := _part(hip, "torso", "torso", torso_size, skin.darkened(.04), Vector2(torso_x,0), 0)
	var torso: Node2D = torso_visual.get_parent()
	var torso_top_y := -torso_size.y
	torso_visual.position.y = torso_top_y
	var head_y_adjust := float(_profile.get("head_y_adjust",0.0))
	var head_visual := _part(torso, "head", "head", head_size, skin, Vector2(0,torso_top_y-head_size.y*.25+head_y_adjust), 4)
	_head_visual = head_visual
	var head: Node2D = head_visual.get_parent()
	var head_sprite_scale := float(_profile.get("head_sprite_scale",1.45))
	_head_base = _base_sprite(head,"HeadSprite","head",head_size*head_sprite_scale,Vector2(0,3),1)
	_head_visual.visible = not _head_base.has_sprite()
	var ear_scale := 1.0 if race_id in ["goblin", "frost_troll"] else .55
	if not _head_base.has_sprite() and race_id in ["goblin", "frost_troll", "fae"]:
		var ear_l := Part.new().setup("ear", Vector2(28,30)*ear_scale, skin, _profile.accent); ear_l.position=Vector2(-head_size.x*.42,-head_size.y*.42); ear_l.z_index=-1; head.add_child(ear_l)
		var ear_r := Part.new().setup("ear", Vector2(-28,30)*ear_scale, skin, _profile.accent); ear_r.position=Vector2(head_size.x*.42,-head_size.y*.42); ear_r.z_index=-1; head.add_child(ear_r)
	if _profile.topology == "winged":
		var wl := Part.new().setup("wing",Vector2(-78,76),Color("edf3d8"),_profile.accent); wl.name="left_wing"; wl.position=Vector2(-6,torso_top_y+42); wl.rotation_degrees=-12.0; wl.self_modulate.a=.78; wl.z_index=-5; torso.add_child(wl); _bones.left_wing=wl
		var wr := Part.new().setup("wing",Vector2(78,76),Color("edf3d8"),_profile.accent); wr.name="right_wing"; wr.position=Vector2(6,torso_top_y+42); wr.rotation_degrees=12.0; wr.self_modulate.a=.78; wr.z_index=-5; torso.add_child(wr); _bones.right_wing=wr

	var upper_arm_length := float(_profile.arm) * 0.52
	var forearm_length := float(_profile.arm) - upper_arm_length
	# Three-quarter staging: anatomical right appears on screen-left while facing
	# right. The full-rig mirror naturally reverses this when facing left. Keep
	# the roots nearer the torso center so the bent weapon hand can still cross
	# into its established screen-right resting guard.
	var shoulder_spread := float(_profile.get("shoulder_spread",.28))
	_part(torso, "left_arm", "limb", Vector2(limb_width,upper_arm_length), skin.darkened(.07), Vector2(torso_size.x*shoulder_spread,torso_top_y+8), -3)
	_part(_bones.left_arm, "left_forearm", "limb", Vector2(limb_width*.94,forearm_length), skin.darkened(.04), Vector2(0,upper_arm_length), -3)
	_part(torso, "right_arm", "limb", Vector2(limb_width,upper_arm_length), skin, Vector2(-torso_size.x*shoulder_spread,torso_top_y+8), 3)
	_part(_bones.right_arm, "right_forearm", "limb", Vector2(limb_width*.94,forearm_length), skin, Vector2(0,upper_arm_length), 3)
	_left_hand_base = _base_sprite(_bones.left_forearm,"LeftHandSprite","hand_open",Vector2(25,23)*extremity_scale,Vector2(0,forearm_length),7,90.0)
	_right_hand_base = _base_sprite(_bones.right_forearm,"RightHandSprite","hand_grip_back",Vector2(24,22)*extremity_scale,Vector2(0,forearm_length),7,90.0)
	# Idle shield guard: drop the far-side elbow beside the torso, then bend the
	# forearm across it. The wrist stays at the shield boss while the rear layer
	# lets the inner half of the shield disappear behind the body.
	_bones.left_arm.rotation_degrees = -10; _bones.left_forearm.rotation_degrees = -80
	# Cross the upper arm toward the body, then finish with a vertical forearm.
	# The +60-degree relative bend preserves the requested 120-degree interior
	# elbow while leaving the grip transform free to orient each weapon class.
	_bones.right_arm.rotation_degrees = 15; _bones.right_forearm.rotation_degrees = -15
	if loadout.weapon == "bow":
		# Keep the same -90-degree combined chain/bow orientation, but move the
		# elbow outward so compact torsos do not hide most of the painted stave.
		_bones.left_arm.rotation_degrees = -24
		_bones.left_forearm.rotation_degrees = -66
	if _has_two_handed_axe_loadout():
		# Keep the anatomical-right elbow outside its shoulder while the forearm
		# returns the primary grip inward. Mirroring the whole rig preserves this
		# outward bend for the opposite facing direction.
		_bones.right_arm.rotation_degrees = 30
		_bones.right_forearm.rotation_degrees = -30

	_attach_gear("back", torso, Vector2(0,torso_top_y+5), -6)
	if race_id == "human":
		_build_human_limb_surfaces(limb_width, leg_width, skin)
		torso_visual.hide()
		var body := preload("res://src/human_torso_surface.gd").new()
		body.name = "HumanTorsoSurface"
		body.size = torso_size
		body.skin = skin
		body.hip = hip
		torso.add_child(body)
	_attach_gear("armor", torso, Vector2(0,torso_top_y), 1)
	_attach_pants(hip,torso_x)
	_attach_boots(hip,extremity_scale)
	_attach_gear("head", head, Vector2.ZERO, 2)
	_attach_gear("accessory", head, Vector2(0,4), 3)
	_attach_gear("weapon", _bones.right_forearm, Vector2(0,forearm_length), 6)
	_attach_gear("offhand", _bones.left_forearm, Vector2(0,forearm_length), 5)
	if loadout.weapon == "bow":
		_place_gear_in_hand("weapon","bow",_gear.weapon)
	_apply_weapon_hand_parts()
	if _uses_two_handed_axe():
		_update_two_handed_axe_grip()
	if _uses_crossbow():
		_update_crossbow_support_grip()
	_capture_pose()
	_apply_facing()


func _build_human_limb_surfaces(arm_width: float, leg_width: float, skin: Color) -> void:
	for side in ["left", "right"]:
		for limb in ["arm", "leg"]:
			var upper: Node2D = _bones[side + "_" + limb]
			var lower: Node2D = _bones[side + ("_forearm" if limb == "arm" else "_shin")]
			# Hide only the old art, never the pivots or their equipment children.
			upper.get_child(0).hide()
			lower.get_child(0).hide()
			var surface := preload("res://src/human_limb_surface.gd").new()
			surface.name = "HumanLimbSurface"
			upper.add_child(surface)
			var lower_length := float(_profile.arm if limb == "arm" else _profile.leg) * .48
			surface.setup(lower, lower_length, arm_width if limb == "arm" else leg_width, skin.darkened(.06) if side == "left" else skin, limb == "leg")
	_update_human_sleeves()


func _update_human_sleeves() -> void:
	for side in ["left", "right"]:
		var surface = _bones[side + "_arm"].get_node("HumanLimbSurface")
		surface.armor = loadout.armor
		surface.accent = _profile.accent
		surface.queue_redraw()


func _update_human_trousers() -> void:
	for side in ["left", "right"]:
		var surface = _bones[side + "_leg"].get_node("HumanLimbSurface")
		surface.pants = loadout.pants
		surface.accent = _profile.accent
		surface.queue_redraw()


func _attach_gear(slot: String, parent: Node2D, at: Vector2, z: int) -> void:
	var visual := Gear.new().setup(slot, loadout[slot], _profile.accent)
	visual.name = slot.capitalize(); visual.position = at; visual.z_index = z
	if slot == "armor":
		visual.scale.x = float(_profile.get("armor_width_scale",1.0))
	elif slot == "offhand" and loadout[slot] == "lantern":
		visual.scale = Vector2.ONE*Gear.LANTERN_DISPLAY_SCALE
	parent.add_child(visual); _gear[slot] = visual
	if race_id == "human" and slot == "armor":
		visual.bind_garment(_bones.hip, _bones.left_leg, _bones.right_leg, _bones.left_arm, _bones.right_arm)
	if race_id == "human" and slot in ["back", "accessory"]:
		visual.fitted_cloth = true
	_apply_gear_presentation(slot, loadout[slot], visual)


func _attach_pants(hip: Node2D, torso_x: float) -> void:
	var waist := Gear.new().setup("pants",loadout.pants,_profile.accent)
	waist.name = "Pants"
	waist.position = Vector2(torso_x,2)
	waist.z_index = 2
	waist.scale.x = float(_profile.get("pants_width_scale",1.0))
	hip.add_child(waist)
	_gear.pants = waist
	_pants_parts.append(waist)
	if _profile.topology == "centaur":
		waist.visible = false
		return
	waist.set_pants_piece("waist")
	if race_id == "human":
		waist.fitted_waist = true
		waist.material = null
		waist.z_index = 0
		_update_human_trousers()
		return
	var thigh_length := float(_profile.leg)*.52
	var shin_length := float(_profile.leg)-thigh_length
	_attach_pants_piece(_bones.left_leg,"LeftPantsThigh","thigh",thigh_length,3)
	_attach_pants_piece(_bones.right_leg,"RightPantsThigh","thigh",thigh_length,3)
	_attach_pants_piece(_bones.left_shin,"LeftPantsShin","shin",shin_length,3)
	_attach_pants_piece(_bones.right_shin,"RightPantsShin","shin",shin_length,3)


func _attach_pants_piece(parent: Node2D, name_: String, piece: String, length: float, z: int) -> void:
	var visual := Gear.new().setup("pants",loadout.pants,_profile.accent)
	visual.name = name_
	visual.set_pants_piece(piece,length)
	visual.z_index = z
	parent.add_child(visual)
	_pants_parts.append(visual)


func _attach_boots(hip: Node2D, extremity_scale: float) -> void:
	if _profile.topology == "centaur":
		# Retain a stable slot node for save/load and UI inspection without
		# covering the lineage's four authored hooves.
		var hidden := Gear.new().setup("boots","none",_profile.accent)
		hidden.name = "Boots"
		hidden.visible = false
		hip.add_child(hidden)
		_gear.boots = hidden
		return
	var shin_length := float(_profile.leg)-float(_profile.leg)*.52
	for side in ["left", "right"]:
		var visual := Gear.new().setup("boots",loadout.boots,_profile.accent)
		visual.name = "%sBoot" % side.capitalize()
		visual.position = Vector2(0,shin_length)
		visual.z_index = 5
		visual.scale = Vector2.ONE*extremity_scale
		_bones["%s_shin" % side].add_child(visual)
		_boot_parts.append(visual)
	_gear.boots = _boot_parts[0]
	_update_base_foot_visibility()


func _update_base_foot_visibility() -> void:
	var show_bare_feet: bool = loadout.boots == "none"
	if _left_foot_base:
		_left_foot_base.visible = show_bare_feet
	if _right_foot_base:
		_right_foot_base.visible = show_bare_feet


func _apply_gear_presentation(slot: String, item_id: String, visual: GearVisual) -> void:
	if slot not in ["weapon", "offhand"]:
		return
	if slot == "weapon":
		visual.set_two_handed(_has_two_handed_axe_loadout() and item_id == "axe")
	# Ladder motion needs both hands. Stow every weapon and non-empty offhand,
	# including lanterns and spellbooks, rather than leaving a utility item
	# embedded in a hand that has switched to the authored ladder grip.
	var should_carry := current_motion == &"climb" and item_id != "none" and slot in ["weapon","offhand"]
	if should_carry:
		_place_gear_on_back(slot, visual)
		return
	_place_gear_in_hand(slot, item_id, visual)


func _place_gear_on_back(slot: String, visual: GearVisual) -> void:
	if visual.get_parent() != _bones.torso:
		visual.reparent(_bones.torso, false)
	visual.set_carried_on_back(true)
	if slot == "weapon":
		visual.set_two_handed(_has_two_handed_axe_loadout() and visual.item == "axe")
	visual.set_shield_exterior(slot == "offhand")
	if slot == "weapon":
		visual.position = Vector2(18.0, -float(_profile.torso.y) * .28)
		visual.rotation_degrees = 135.0
		visual.z_index = 3
	else:
		if visual.item == "lantern":
			visual.position = Vector2(-27.0,-float(_profile.torso.y)*.22)
			visual.z_index = 4
		elif visual.item == "spellbook":
			visual.position = Vector2(-25.0,-float(_profile.torso.y)*.30)
			visual.z_index = 4
		else:
			visual.position = Vector2(0.0, -float(_profile.torso.y) * .42)
			visual.z_index = 4 if race_id == "human" else 2
		visual.rotation = 0.0


func _place_gear_in_hand(slot: String, item_id: String, visual: GearVisual) -> void:
	var forearm_length := float(_profile.arm) * .48
	visual.set_carried_on_back(false)
	# The concept sheets consistently present the decorated shield face toward
	# the viewer. Mirroring changes its screen side, not which painted face is
	# shown; the interior remains available for future explicit flip poses.
	visual.set_shield_exterior(slot == "offhand" and CharacterCatalog.is_shield(item_id))
	if slot == "weapon":
		var weapon_forearm: Node2D = _bones.left_forearm if item_id == "bow" else _weapon_forearm()
		if visual.get_parent() != weapon_forearm:
			visual.reparent(weapon_forearm, false)
		visual.position = Vector2(0.0, forearm_length)
		visual.rotation_degrees = WEAPON_GRIP_ROTATIONS.get(item_id,0.0)
		# The bow lives on the far-side arm, whose relative negative layers would
		# otherwise place the entire weapon behind the torso and armor.
		visual.z_index = 12 if item_id == "bow" else 6
		return
	visual.rotation = 0.0
	var offhand_forearm := _offhand_forearm()
	if visual.get_parent() != offhand_forearm:
		visual.reparent(offhand_forearm, false)
	if item_id == "lantern":
		# A lantern is suspended from its top loop rather than gripped like a
		# shield or book. Establish an upright world hang at rest; later arm motion
		# still contributes relative swing through the animated forearm parent.
		visual.global_rotation = 0.0
	if CharacterCatalog.is_shield(item_id):
		# Offset the visual origin by the inverse of its painted center so the
		# offhand wrist/grip lands exactly on the shield boss.
		visual.position = Vector2(0.0,forearm_length)-Gear.SHIELD_CENTER
		visual.z_index = 4 if race_id == "human" else -1
	else:
		visual.position.x = 0.0
		visual.position.y = forearm_length
		visual.z_index = 5


func _set_climbing_gear(enabled: bool) -> void:
	if _gear.is_empty():
		return
	# `_apply_gear_presentation` uses current_motion as the source of truth;
	# `enabled` documents the transition at each call site.
	var expected_motion := &"climb" if enabled else &"idle"
	if enabled != (current_motion == &"climb"):
		current_motion = expected_motion
	for slot in ["weapon", "offhand"]:
		var visual: GearVisual = _gear.get(slot)
		if visual:
			_apply_gear_presentation(slot, loadout[slot], visual)


func _weapon_arm() -> Node2D:
	return _bones.right_arm


func _weapon_forearm() -> Node2D:
	return _bones.right_forearm


func _offhand_forearm() -> Node2D:
	return _bones.left_forearm


func _update_two_handed_axe_grip() -> void:
	if not _uses_two_handed_axe() or not _gear.has("weapon") or not _bones.has("torso"):
		return
	var weapon: GearVisual = _gear.weapon
	var upper_arm: Node2D = _bones.left_arm
	var forearm: Node2D = _bones.left_forearm
	var target: Vector2 = _bones.torso.to_local(weapon.to_global(Gear.TWO_HANDED_AXE_SECOND_GRIP))
	var delta: Vector2 = target-upper_arm.position
	var upper_length := float(_profile.arm)*.52
	var lower_length := float(_profile.arm)-upper_length
	var distance := clampf(delta.length(),absf(upper_length-lower_length)+.01,upper_length+lower_length-.01)
	var elbow_cosine := clampf((distance*distance-upper_length*upper_length-lower_length*lower_length)/(2.0*upper_length*lower_length),-1.0,1.0)
	# Two-bone IK has two equally valid solutions. The support arm must use the
	# negative/outward branch so its elbow cannot flip across the axe shaft.
	var elbow_angle := -acos(elbow_cosine)
	var target_angle := atan2(delta.y,delta.x)
	var shoulder_offset := atan2(lower_length*sin(elbow_angle),upper_length+lower_length*cos(elbow_angle))
	# Part limbs point down their local +Y axis, hence the quarter-turn from
	# the conventional +X-axis two-bone solution.
	upper_arm.rotation = target_angle-shoulder_offset-PI*.5
	forearm.rotation = elbow_angle


func _update_crossbow_support_grip() -> void:
	if not _uses_crossbow() or not _gear.has("weapon") or not _bones.has("torso"):
		return
	var weapon: GearVisual = _gear.weapon
	var upper_arm: Node2D = _bones.left_arm
	var forearm: Node2D = _bones.left_forearm
	var target: Vector2 = _bones.torso.to_local(weapon.to_global(Gear.CROSSBOW_SECOND_GRIP))
	var delta: Vector2 = target-upper_arm.position
	var upper_length := float(_profile.arm)*.52
	var lower_length := float(_profile.arm)-upper_length
	var distance := clampf(delta.length(),absf(upper_length-lower_length)+.01,upper_length+lower_length-.01)
	var elbow_cosine := clampf((distance*distance-upper_length*upper_length-lower_length*lower_length)/(2.0*upper_length*lower_length),-1.0,1.0)
	var elbow_angle := -acos(elbow_cosine)
	var target_angle := atan2(delta.y,delta.x)
	var shoulder_offset := atan2(lower_length*sin(elbow_angle),upper_length+lower_length*cos(elbow_angle))
	upper_arm.rotation = target_angle-shoulder_offset-PI*.5
	forearm.rotation = elbow_angle


func _capture_pose() -> void:
	for key in _bones:
		var node: Node2D = _bones[key]
		_rest[key] = {"position": node.position, "rotation": node.rotation, "scale": node.scale}


func _restore_pose() -> void:
	for key in _rest:
		var node: Node2D = _bones.get(key)
		if node:
			node.position = _rest[key].position; node.rotation = _rest[key].rotation; node.scale = _rest[key].scale
	_set_secondary_gear_rotation(0.0,0.0)
	var weapon_visual: GearVisual = _gear.get("weapon")
	if weapon_visual:
		if loadout.weapon == "crossbow":
			weapon_visual.set_crossbow_loaded(true)
		elif loadout.weapon == "bow":
			weapon_visual.set_bow_draw(0.0)
	_apply_facing()


func _finish_gesture() -> void:
	_restore_pose(); _gesturing = false; current_motion = &"idle"; _idle_phase = 0.0; motion_changed.emit(current_motion)


func _apply_facing() -> void:
	if not _bones.has("rig"):
		return
	var rig: Node2D = _bones.rig
	var magnitude := absf(rig.scale.x)
	if magnitude == 0.0:
		magnitude = float(_profile.get("scale", 1.0))
	rig.scale.x = -magnitude if facing == &"left" else magnitude
	if current_motion == &"climb" and _profile.topology == "centaur" and _bones.has("torso"):
		_center_centaur_climb()
	if _rest.has("rig"):
		_rest.rig.scale = rig.scale


func _set_back_view(enabled: bool) -> void:
	if race_id == "human" and _bones.has("torso") and _bones.torso.has_node("HumanTorsoSurface"):
		_bones.torso.get_node("HumanTorsoSurface").back_view = enabled
		var back: GearVisual = _gear.get("back")
		if back:
			# Rear-facing equipment is between the torso and stowed weapons.
			back.z_index = 3 if enabled else -6
		var waist: GearVisual = _gear.get("pants")
		if waist:
			waist.set_back_view(enabled)
	if _head_visual:
		_head_visual.set_back_view(enabled)
	if _head_base:
		_head_base.set_back_view(enabled)
	var armor: GearVisual = _gear.get("armor")
	if armor:
		armor.set_back_view(enabled)
	var headgear: GearVisual = _gear.get("head")
	if headgear:
		headgear.set_back_view(enabled)
	var accessory: GearVisual = _gear.get("accessory")
	if accessory:
		accessory.set_back_view(enabled)
	if enabled:
		if _left_hand_base:
			_left_hand_base.set_part("hand_grip")
			if race_id == "human":
				_left_hand_base.z_index = 7
		if _right_hand_base:
			_right_hand_base.set_part("hand_grip")
	else:
		_apply_weapon_hand_parts()
	if _horse_tail_base:
		_horse_tail_base.set_back_view(enabled)
	if _horse_body_visual:
		_horse_body_visual.set_back_view(enabled)
	if _horse_neck_visual:
		_horse_neck_visual.set_back_view(enabled)


func _set_climbing_anatomy(enabled: bool) -> void:
	if _profile.topology != "centaur" or not _bones.has("horse_tail"):
		return
	for leg_index in 4:
		_bones["horse_leg_%d" % leg_index].visible = not enabled
	if enabled:
		_center_centaur_climb()
	else:
		_bones.rig.position.x = _rest.rig.position.x
	# The climbing silhouette looks down over the horse's back: recenter the
	# foreshortened barrel under the humanoid torso and root the tail at the
	# lower middle of its rump.
	_bones.horse_body.position = Vector2(_bones.torso.position.x,12) if enabled else _rest.horse_body.position
	_bones.horse_tail.position = Vector2(_bones.torso.position.x,58) if enabled else _rest.horse_tail.position
	_bones.horse_tail.rotation = 0.0 if enabled else _rest.horse_tail.rotation
	_bones.horse_tail.z_index = 1 if enabled else -4


func _center_centaur_climb() -> void:
	# The ladder is centered on the avatar origin. Counter the centaur torso's
	# side-view front offset after facing scale so its rear-view spine sits on it.
	_bones.rig.position.x = -_bones.rig.scale.x * _bones.torso.position.x


func _stop_active_animation() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	if _slash_trail:
		_slash_trail.cancel()
	for effect in _gesture_effects:
		if is_instance_valid(effect):
			var parent := effect.get_parent()
			if parent:
				parent.remove_child(effect)
			effect.queue_free()
	_gesture_effects.clear()
	var weapon_visual: GearVisual = _gear.get("weapon")
	if weapon_visual and weapon_visual.item == "bow":
		weapon_visual.set_bow_draw(0.0)
	_set_bow_drawing_hand(false)


func _queue_motion_pose(rotations: Dictionary, rig_y: float, duration: float) -> void:
	_active_tween.tween_property(_bones.rig, "position:y", rig_y, duration)
	for bone_name in rotations:
		if _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name], "rotation_degrees", rotations[bone_name], duration)
	if current_motion in [&"run", &"stairs"]:
		var parent_rotation: float = rotations.get("torso",0.0)+rotations.get("right_arm",0.0)+rotations.get("right_forearm",0.0)
		if loadout.weapon == "spear" or _is_staff_weapon():
			# Pole weapons stay upright in world space while their complete parent
			# chain continues through the run or stair cycle.
			_active_tween.parallel().tween_property(_gear.weapon,"rotation_degrees",180.0-parent_rotation,duration)
		elif loadout.weapon == "crossbow":
			# Keep the guide rail level and forward instead of allowing the run arm
			# swing to rotate the broad limbs across the face.
			_active_tween.parallel().tween_property(_gear.weapon,"rotation_degrees",-90.0-parent_rotation,duration)


func _build_run_loop() -> void:
	if _profile.topology == "centaur":
		for pose_index in CENTAUR_RUN_CYCLE.size():
			var pose: Dictionary = CENTAUR_RUN_CYCLE[pose_index]
			var rotations: Dictionary = pose.rotations.duplicate()
			_stage_outboard_weapon_carry(rotations,pose_index)
			_queue_motion_pose(rotations,pose.y,RUN_FRAME_DURATION)
			_queue_secondary_gear_pose(float(CAPE_RUN_SWAY_CYCLE[pose_index]),float(SCARF_RUN_SWAY_CYCLE[pose_index]),RUN_FRAME_DURATION)
	else:
		for pose_index in BIPED_RUN_CYCLE.size():
			var pose: Dictionary = BIPED_RUN_CYCLE[pose_index]
			var rotations: Dictionary = pose.rotations.duplicate()
			_stage_outboard_weapon_carry(rotations,pose_index)
			_add_fae_wing_pose(rotations,float(FAE_RUN_WING_CYCLE[pose_index]))
			_queue_motion_pose(rotations,pose.y,RUN_FRAME_DURATION)
			_queue_secondary_gear_pose(float(CAPE_RUN_SWAY_CYCLE[pose_index]),float(SCARF_RUN_SWAY_CYCLE[pose_index]),RUN_FRAME_DURATION)


func _build_stair_loop() -> void:
	var cycle: Array = CENTAUR_STAIR_CYCLE if _profile.topology == "centaur" else BIPED_STAIR_CYCLE
	for pose_index in cycle.size():
		var pose: Dictionary = cycle[pose_index]
		var rotations: Dictionary = pose.rotations.duplicate()
		_stage_outboard_weapon_carry(rotations,pose_index*2 if _profile.topology == "centaur" else pose_index)
		if _profile.topology != "centaur":
			_add_fae_wing_pose(rotations,float(FAE_STAIR_WING_CYCLE[pose_index]))
		_queue_motion_pose(rotations,pose.y,STAIR_FRAME_DURATION)
		_queue_secondary_gear_pose(float(CAPE_STAIR_SWAY_CYCLE[pose_index]),float(SCARF_STAIR_SWAY_CYCLE[pose_index]),STAIR_FRAME_DURATION)


func _stage_outboard_weapon_carry(rotations: Dictionary,pose_index: int) -> void:
	if not (loadout.weapon in ["sword","axe","spear"] or _is_staff_weapon()):
		return
	# Keep the primary grip beyond the near edge of the face while long weapon
	# silhouettes remain stable and short blades stay in a low forward guard.
	# Small opposing shoulder/elbow changes preserve gait life without letting a
	# point, crystal, blade, or axe head sweep over the eyes.
	var cycle_index := posmod(pose_index,OUTBOARD_CARRY_ARM_CYCLE.size())
	rotations.right_arm = OUTBOARD_CARRY_ARM_CYCLE[cycle_index]
	rotations.right_forearm = OUTBOARD_CARRY_FOREARM_CYCLE[cycle_index]


func _build_climb_loop() -> void:
	# Rear-view mirrored reaches: each hand stays near its own ladder rail while
	# alternating which arm is extended to the higher rung.
	var reach_a := {
		"torso": -3.0,
		"left_arm": -145.0, "left_forearm": -20.0,
		"right_arm": 108.0, "right_forearm": 59.0,
	}
	var reach_b := {
		"torso": 3.0,
		"left_arm": -108.0, "left_forearm": -59.0,
		"right_arm": 145.0, "right_forearm": 20.0,
	}
	if _profile.topology == "centaur":
		reach_a.merge({"horse_leg_0": -18.0, "horse_shin_0": 34.0, "horse_leg_1": 18.0, "horse_shin_1": -8.0, "horse_leg_2": 12.0, "horse_shin_2": -8.0, "horse_leg_3": -12.0, "horse_shin_3": 34.0})
		reach_b.merge({"horse_leg_0": 18.0, "horse_shin_0": -8.0, "horse_leg_1": -18.0, "horse_shin_1": 34.0, "horse_leg_2": -12.0, "horse_shin_2": 34.0, "horse_leg_3": 12.0, "horse_shin_3": -8.0})
	else:
		reach_a.merge({"left_leg": -24.0, "left_shin": 48.0, "right_leg": 18.0, "right_shin": -8.0})
		reach_b.merge({"left_leg": 18.0, "left_shin": -8.0, "right_leg": -24.0, "right_shin": 48.0})
		_add_fae_wing_pose(reach_a,22.0)
		_add_fae_wing_pose(reach_b,8.0)
	_queue_motion_pose(reach_a, -6.0, .28)
	_queue_secondary_gear_pose(4.0,2.0,.28)
	_queue_motion_pose(reach_b, 4.0, .28)
	_queue_secondary_gear_pose(7.0,4.0,.28)


func _add_fae_wing_pose(rotations: Dictionary,delta_degrees: float) -> void:
	if not _bones.has("left_wing") or not _rest.has("left_wing"):
		return
	rotations.left_wing = rad_to_deg(_rest.left_wing.rotation)+delta_degrees
	rotations.right_wing = rad_to_deg(_rest.right_wing.rotation)-delta_degrees


func _set_secondary_gear_rotation(cape_degrees: float,scarf_degrees: float) -> void:
	var back_visual: GearVisual = _gear.get("back")
	if back_visual and back_visual.item in ["cape","long_cape"]:
		back_visual.rotation_degrees = cape_degrees
	var accessory_visual: GearVisual = _gear.get("accessory")
	if accessory_visual and accessory_visual.item == "scarf":
		accessory_visual.rotation_degrees = scarf_degrees


func _queue_secondary_gear_pose(cape_degrees: float,scarf_degrees: float,duration: float) -> void:
	var back_visual: GearVisual = _gear.get("back")
	if back_visual and back_visual.item in ["cape","long_cape"]:
		_active_tween.parallel().tween_property(back_visual,"rotation_degrees",cape_degrees,duration)
	var accessory_visual: GearVisual = _gear.get("accessory")
	if accessory_visual and accessory_visual.item == "scarf":
		_active_tween.parallel().tween_property(accessory_visual,"rotation_degrees",scarf_degrees,duration)


func _swing(node: Node2D, windup: float, strike: float) -> void:
	_active_tween.tween_property(node,"rotation_degrees",windup,.13)
	_active_tween.tween_property(node,"rotation_degrees",strike,.18).set_trans(Tween.TRANS_BACK)
	_active_tween.tween_property(node,"rotation_degrees",rad_to_deg(_rest[node.name].rotation),.24)


func _animate_race_gesture(profile: Dictionary, motion_id: String) -> void:
	var times: Array = profile.times
	_tween_race_pose(profile.windup,float(times[0]))
	_queue_gesture_footwork(motion_id,false,float(times[0]))
	if motion_id == "centaur_0" and loadout.weapon == "bow":
		# Gallop Shot visibly loads the same authored nocked arrow as Fire Bow
		# during anticipation, while the equine gait drives underneath it.
		var bow: GearVisual = _gear.weapon
		bow.set_bow_draw(0.0)
		_active_tween.parallel().tween_method(bow.set_bow_draw,0.0,20.0,float(times[0]))
	_tween_race_pose(profile.impact,float(times[1]),Tween.TRANS_BACK)
	_queue_gesture_footwork(motion_id,true,float(times[1]))
	# The semantic effect belongs to the completed contact pose. Spawning it
	# before this tween left weapon, mouth, and hand effects at their anticipation
	# coordinates while the body finished the strike; projectile gestures also
	# released before reaching their final aim.
	_active_tween.tween_callback(_spawn_race_gesture_effect.bind(motion_id))
	_active_tween.tween_interval(float(times[2]))
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.torso,"rotation",_rest.torso.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation",_rest.left_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation",_rest.left_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation",_rest.right_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation",_rest.right_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.rig,"position",_rest.rig.position,.24)
	_queue_lower_body_recovery(.24)
	_queue_wing_recovery(.24)


func _queue_gesture_footwork(motion_id: String,impact: bool,duration: float) -> void:
	var profile: Dictionary = RACE_GESTURE_FOOTWORK.get(motion_id,{})
	if profile.is_empty():
		return
	var pose := _gesture_footwork_pose(String(profile.kind),impact)
	var intensity := float(profile.intensity)
	for bone_name in pose:
		if _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name],"rotation_degrees",float(pose[bone_name])*intensity,duration)
	_queue_fae_gesture_wings(String(profile.kind),impact,intensity,duration)
	_queue_secondary_gear_pose(13.0*intensity if impact else 5.0*intensity,8.0*intensity if impact else 3.0*intensity,duration)


func _queue_fae_gesture_wings(kind: String,impact: bool,intensity: float,duration: float) -> void:
	if not _bones.has("left_wing"):
		return
	var wing_delta := 0.0
	match kind:
		"hover": wing_delta = 34.0 if impact else -8.0
		"leap", "dash": wing_delta = 28.0 if impact else -18.0
		"cast": wing_delta = 22.0 if impact else -12.0
		"slash": wing_delta = -24.0 if impact else 16.0
		_: wing_delta = -12.0 if impact else 10.0
	wing_delta *= intensity
	_active_tween.parallel().tween_property(_bones.left_wing,"rotation_degrees",rad_to_deg(_rest.left_wing.rotation)+wing_delta,duration)
	_active_tween.parallel().tween_property(_bones.right_wing,"rotation_degrees",rad_to_deg(_rest.right_wing.rotation)-wing_delta,duration)


func _queue_wing_recovery(duration: float) -> void:
	if not _bones.has("left_wing"):
		return
	_active_tween.parallel().tween_property(_bones.left_wing,"rotation",_rest.left_wing.rotation,duration)
	_active_tween.parallel().tween_property(_bones.right_wing,"rotation",_rest.right_wing.rotation,duration)


func _gesture_footwork_pose(kind: String,impact: bool) -> Dictionary:
	if _profile.topology == "centaur":
		match kind:
			"gallop", "dash", "lunge":
				return {"horse_tail":10.0,"horse_leg_0":-28.0,"horse_shin_0":48.0,"horse_leg_1":22.0,"horse_shin_1":-9.0,"horse_leg_2":24.0,"horse_shin_2":-10.0,"horse_leg_3":-30.0,"horse_shin_3":52.0} if impact else {"horse_tail":-8.0,"horse_leg_0":18.0,"horse_shin_0":-7.0,"horse_leg_1":-20.0,"horse_shin_1":32.0,"horse_leg_2":-18.0,"horse_shin_2":30.0,"horse_leg_3":16.0,"horse_shin_3":-6.0}
			"rear", "leap":
				return {"horse_tail":-18.0,"horse_leg_0":20.0,"horse_shin_0":-8.0,"horse_leg_1":16.0,"horse_shin_1":-7.0,"horse_leg_2":-55.0,"horse_shin_2":75.0,"horse_leg_3":-48.0,"horse_shin_3":68.0} if impact else {"horse_tail":12.0,"horse_leg_0":-18.0,"horse_shin_0":34.0,"horse_leg_1":15.0,"horse_shin_1":-6.0,"horse_leg_2":12.0,"horse_shin_2":-5.0,"horse_leg_3":-20.0,"horse_shin_3":36.0}
			"cast", "hover":
				return {"horse_tail":14.0,"horse_leg_0":-22.0,"horse_shin_0":36.0,"horse_leg_1":18.0,"horse_shin_1":-8.0,"horse_leg_2":20.0,"horse_shin_2":-8.0,"horse_leg_3":-24.0,"horse_shin_3":38.0} if impact else {"horse_tail":-10.0,"horse_leg_0":16.0,"horse_shin_0":-6.0,"horse_leg_1":-18.0,"horse_shin_1":30.0,"horse_leg_2":-16.0,"horse_shin_2":28.0,"horse_leg_3":14.0,"horse_shin_3":-6.0}
			_:
				return {"horse_tail":-8.0,"horse_leg_0":-18.0,"horse_shin_0":30.0,"horse_leg_1":15.0,"horse_shin_1":-6.0,"horse_leg_2":17.0,"horse_shin_2":-7.0,"horse_leg_3":-20.0,"horse_shin_3":32.0}
	match kind:
		"crouch":
			return {"left_leg":-16.0,"left_shin":58.0,"right_leg":16.0,"right_shin":58.0} if impact else {"left_leg":-8.0,"left_shin":42.0,"right_leg":8.0,"right_shin":42.0}
		"leap", "rear":
			return {"left_leg":-42.0,"left_shin":76.0,"right_leg":35.0,"right_shin":64.0} if impact else {"left_leg":-12.0,"left_shin":48.0,"right_leg":12.0,"right_shin":48.0}
		"cast":
			return {"left_leg":24.0,"left_shin":-8.0,"right_leg":-26.0,"right_shin":38.0} if impact else {"left_leg":18.0,"left_shin":-6.0,"right_leg":-20.0,"right_shin":32.0}
		"hover":
			return {"left_leg":-18.0,"left_shin":55.0,"right_leg":18.0,"right_shin":55.0} if impact else {"left_leg":-6.0,"left_shin":30.0,"right_leg":6.0,"right_shin":30.0}
		"slash":
			return {"left_leg":-24.0,"left_shin":30.0,"right_leg":20.0,"right_shin":-8.0} if impact else {"left_leg":16.0,"left_shin":-6.0,"right_leg":-20.0,"right_shin":30.0}
		"lunge":
			return {"left_leg":28.0,"left_shin":-12.0,"right_leg":-36.0,"right_shin":22.0} if impact else {"left_leg":18.0,"left_shin":-6.0,"right_leg":-20.0,"right_shin":30.0}
		"dash", "gallop":
			return {"left_leg":-58.0,"left_shin":18.0,"right_leg":48.0,"right_shin":-8.0} if impact else {"left_leg":-14.0,"left_shin":46.0,"right_leg":14.0,"right_shin":42.0}
		"smash":
			return {"left_leg":-30.0,"left_shin":52.0,"right_leg":28.0,"right_shin":48.0} if impact else {"left_leg":-18.0,"left_shin":42.0,"right_leg":18.0,"right_shin":42.0}
		_:
			return {"left_leg":20.0,"left_shin":-7.0,"right_leg":-22.0,"right_shin":32.0} if impact else {"left_leg":14.0,"left_shin":-5.0,"right_leg":-16.0,"right_shin":26.0}


func _spawn_race_gesture_effect(motion_id: String) -> void:
	var effect_profile: Dictionary = RACE_GESTURE_EFFECTS.get(motion_id,{})
	if effect_profile.is_empty() or not _bones.has("rig"):
		return
	if motion_id == "goblin_0" and _uses_crossbow():
		# Snap Shot's effect is the fired projectile, so unload the rail on the
		# same impact callback instead of rendering a duplicate seated bolt.
		(_gear.weapon as GearVisual).set_crossbow_loaded(false)
	elif motion_id == "centaur_0" and loadout.weapon == "bow":
		# The string and seated arrow snap home on the exact callback that
		# creates Gallop Shot's flying authored arrow effect.
		(_gear.weapon as GearVisual).set_bow_draw(0.0)
	var effect := GestureEffect.new().setup(effect_profile.effect,_profile.accent)
	effect.name = "GestureEffect"
	var effect_offset: Vector2 = effect_profile.get("offset",Vector2.ZERO)
	effect.position = _gesture_effect_anchor(effect_profile.anchor)+effect_offset
	effect.scale = Vector2.ONE*float(effect_profile.get("scale",1.0))
	effect.z_index = 28
	_bones.rig.add_child(effect)
	# Projectiles and contact/ground impacts belong to the release point after
	# they spawn. Preserve their exact global transform while detaching them from
	# rig recoil and recovery; head and torso auras intentionally remain bound to
	# the character's body space.
	if effect_profile.anchor in DETACHED_GESTURE_EFFECT_ANCHORS:
		effect.reparent(self,true)
	_gesture_effects.append(effect)
	effect.play()


func _gesture_effect_anchor(anchor: String) -> Vector2:
	var rig: Node2D = _bones.rig
	match anchor:
		"head":
			return rig.to_local(_bones.head.global_position)+Vector2(float(_profile.head.x)*.36,5.0)
		"torso":
			return rig.to_local(_bones.torso.global_position)+Vector2(0,-float(_profile.torso.y)*.48)
		"weapon":
			var weapon: GearVisual = _gear.get("weapon")
			if weapon and weapon.item != "none":
				return rig.to_local(weapon.to_global(weapon.reach_endpoint()))
			return _gesture_effect_anchor("hand")
		"hand":
			return rig.to_local(_bones.right_forearm.to_global(Vector2(0,float(_profile.arm)*.48)))
		"front":
			return Vector2(float(_profile.torso.x)*.65,-float(_profile.leg)-float(_profile.torso.y)*.45)
	return Vector2.ZERO


func _tween_race_pose(pose: Array, duration: float, transition := Tween.TRANS_QUAD) -> void:
	_active_tween.tween_property(_bones.torso,"rotation_degrees",float(pose[0]),duration).set_trans(transition).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation_degrees",float(pose[1]),duration)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",float(pose[2]),duration)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",float(pose[3]),duration)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",float(pose[4]),duration)
	_active_tween.parallel().tween_property(_bones.rig,"position",Vector2(float(pose[5]),float(pose[6])),duration)


func _animate_weapon_curve(curve_id: String) -> void:
	var weapon_arm := _weapon_arm()
	var weapon_forearm := _weapon_forearm()
	var weapon_visual: GearVisual = _gear.get("weapon")
	var curve_family: String = "two_handed_axe" if _has_two_handed_axe_loadout() else loadout.weapon
	var weapon_curves: Dictionary = WEAPON_ATTACK_CURVES.get(curve_family,{})
	var curve: Array = weapon_curves.get(curve_id,ATTACK_CURVES[curve_id])
	var uses_slash_trail: bool = curve_id in ["jab","forehand","backhand"] and (loadout.weapon in ["sword","axe","spear"] or _is_staff_weapon())
	# Thrusts trail as soon as they leave the chamber. Both cuts wait until
	# their loaded guard has settled, keeping anticipation free of hit-read VFX.
	var slash_start_index := 1 if curve_id == "jab" else 2
	var slash_stop_index := curve.size()
	if curve_id == "jab":
		# Keep the straight trail active through the decelerating contact carry,
		# but stop before any explicit or implicit withdrawal begins.
		for pose_index in curve.size():
			if String(curve[pose_index].get("phase","")) == "recover":
				slash_stop_index = pose_index
				break
	for pose_index in curve.size():
		var pose: Dictionary = curve[pose_index]
		var easing: Dictionary = ATTACK_PHASE_EASING.get(pose.get("phase","guard"),ATTACK_PHASE_EASING.guard)
		if uses_slash_trail and pose_index == slash_stop_index:
			_active_tween.tween_callback(_slash_trail.stop)
		if uses_slash_trail and pose_index == slash_start_index:
			_active_tween.tween_callback(_start_slash_trail.bind(curve_id == "jab"))
		_active_tween.set_trans(easing.trans).set_ease(easing.ease)
		_active_tween.tween_property(weapon_arm, "rotation_degrees", pose.upper, pose.duration)
		_active_tween.parallel().tween_property(weapon_forearm, "rotation_degrees", pose.forearm, pose.duration)
		_active_tween.parallel().tween_property(_bones.torso, "rotation_degrees", pose.torso, pose.duration)
		_active_tween.parallel().tween_property(_bones.rig, "position:x", pose.x, pose.duration)
		_queue_attack_footwork(curve_id,String(pose.get("phase","guard")),float(pose.duration))
		if weapon_visual and pose.has("weapon_rotation"):
			_active_tween.parallel().tween_property(weapon_visual, "rotation_degrees", pose.weapon_rotation, pose.duration)
	if uses_slash_trail and slash_stop_index == curve.size():
		_active_tween.tween_callback(_slash_trail.stop)
	var recovery_easing: Dictionary = ATTACK_PHASE_EASING.recover
	_active_tween.set_trans(recovery_easing.trans).set_ease(recovery_easing.ease)
	_active_tween.tween_property(weapon_arm, "rotation", _rest[weapon_arm.name].rotation, .24)
	_active_tween.parallel().tween_property(weapon_forearm, "rotation", _rest[weapon_forearm.name].rotation, .24)
	_active_tween.parallel().tween_property(_bones.torso, "rotation", _rest.torso.rotation, .24)
	_active_tween.parallel().tween_property(_bones.rig, "position:x", _rest.rig.position.x, .24)
	_queue_lower_body_recovery(.24)
	if weapon_visual:
		_active_tween.parallel().tween_property(weapon_visual, "rotation_degrees", WEAPON_GRIP_ROTATIONS.get(loadout.weapon,0.0), .24)


func _queue_attack_footwork(curve_id: String,phase: String,duration: float) -> void:
	var topology_footwork: Dictionary = CENTAUR_ATTACK_FOOTWORK if _profile.topology == "centaur" else BIPED_ATTACK_FOOTWORK
	var action_footwork: Dictionary = topology_footwork.get(curve_id,{})
	var pose: Dictionary = action_footwork.get(phase,{})
	if pose.is_empty():
		return
	if pose.has("y"):
		_active_tween.parallel().tween_property(_bones.rig,"position:y",float(pose.y),duration)
	for bone_name in pose:
		if bone_name != "y" and _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name],"rotation_degrees",float(pose[bone_name]),duration)
	var cape_sway: float = {"chamber":4.0,"guard":6.0,"strike":15.0,"follow":11.0,"recover":2.0}.get(phase,5.0)
	var scarf_sway: float = {"chamber":2.0,"guard":3.0,"strike":9.0,"follow":6.0,"recover":1.0}.get(phase,3.0)
	_queue_secondary_gear_pose(cape_sway,scarf_sway,duration)


func _queue_ranged_footwork(action_id: String,phase: String,duration: float) -> void:
	var topology_footwork: Dictionary = CENTAUR_RANGED_FOOTWORK if _profile.topology == "centaur" else BIPED_RANGED_FOOTWORK
	var action_footwork: Dictionary = topology_footwork.get(action_id,{})
	var pose: Dictionary = action_footwork.get(phase,{})
	if pose.is_empty():
		return
	if pose.has("y"):
		_active_tween.parallel().tween_property(_bones.rig,"position:y",float(pose.y),duration)
	for bone_name in pose:
		if bone_name != "y" and _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name],"rotation_degrees",float(pose[bone_name]),duration)
	var cape_sway: float = {"ready":4.0,"draw":8.0,"recoil":14.0,"gather":5.0,"release":13.0}.get(phase,4.0)
	var scarf_sway: float = {"ready":2.0,"draw":4.0,"recoil":8.0,"gather":3.0,"release":8.0}.get(phase,2.0)
	_queue_secondary_gear_pose(cape_sway,scarf_sway,duration)


func _queue_lower_body_recovery(duration: float) -> void:
	_active_tween.parallel().tween_property(_bones.rig,"position:y",_rest.rig.position.y,duration)
	var recovery_bones: Array = ["horse_tail","horse_leg_0","horse_shin_0","horse_leg_1","horse_shin_1","horse_leg_2","horse_shin_2","horse_leg_3","horse_shin_3"] if _profile.topology == "centaur" else ["left_leg","left_shin","right_leg","right_shin"]
	for bone_name in recovery_bones:
		if _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name],"rotation",_rest[bone_name].rotation,duration)
	_queue_secondary_gear_pose(0.0,0.0,duration)


func _start_slash_trail(thrust_mode := false) -> void:
	var weapon_visual: GearVisual = _gear.get("weapon")
	if weapon_visual:
		_slash_trail.start(weapon_visual,Color("8edfff"),16.0 if loadout.weapon == "spear" or _is_staff_weapon() else 14.0,thrust_mode)


func _animate_slash() -> void: _animate_weapon_curve("forehand")
func _animate_thrust() -> void:
	_active_tween.tween_property(_bones.torso,"rotation_degrees",-12,.12)
	_active_tween.parallel().tween_property(_weapon_arm(),"rotation_degrees",-88,.12)
	_active_tween.parallel().tween_property(_weapon_forearm(),"rotation_degrees",-4,.12)
	_active_tween.tween_property(_bones.rig,"position:x",24.0,.12)
	_active_tween.tween_property(_bones.rig,"position:x",0.0,.22)
func _animate_cast() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-145,.22)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",145,.22)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",18,.22)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-18,.22)
	_active_tween.tween_property(_bones.torso,"scale",Vector2(1.08,.94),.16)
	_active_tween.tween_interval(.14)
func _animate_smash() -> void:
	_active_tween.tween_property(_weapon_arm(),"rotation_degrees",-175,.25)
	_active_tween.parallel().tween_property(_weapon_forearm(),"rotation_degrees",15,.25)
	_active_tween.tween_property(_weapon_arm(),"rotation_degrees",12,.12).set_trans(Tween.TRANS_EXPO)
	_active_tween.parallel().tween_property(_bones.rig,"position:y",7.0,.12)
	_active_tween.tween_interval(.12)
func _animate_shoot() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-88,.18)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-78,.18)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",-8,.18)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-12,.18)
	_active_tween.tween_interval(.2)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-25,.08)


func _animate_fire_bow() -> void:
	var bow: GearVisual = _gear.get("weapon")
	if not bow or loadout.weapon != "bow":
		return
	bow.set_bow_draw(0.0)
	_set_bow_drawing_hand(true)
	# Present the centered grip and bring the free hand toward the string.
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-90.0,.16)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",0.0,.16)
	_active_tween.parallel().tween_property(bow,"rotation_degrees",90.0,.16)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",15.0,.16)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-15.0,.16)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",-2.0,.16)
	_queue_ranged_footwork("bow","ready",.16)
	# Pull the nock back toward the face while the bow hand stays locked.
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_method(bow.set_bow_draw,0.0,24.0,.24)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-25.0,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-130.0,.24)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",-7.0,.24)
	_queue_ranged_footwork("bow","draw",.24)
	_active_tween.tween_interval(.08)
	_active_tween.tween_callback(_fire_arrow)
	# The string snaps away fastest at release; the drawing arm follows with a
	# small overshooting recoil before both arms settle smoothly.
	_active_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_active_tween.tween_method(bow.set_bow_draw,24.0,0.0,.05)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",45.0,.08).set_trans(Tween.TRANS_BACK)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-45.0,.08)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",3.0,.08)
	_queue_ranged_footwork("bow","recoil",.08)
	# Release the invisible string grip as soon as recoil finishes so the hand
	# relaxes throughout recovery instead of clutching empty air until cleanup.
	_active_tween.tween_callback(_set_bow_drawing_hand.bind(false))
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation",_rest.right_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation",_rest.right_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation",_rest.left_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation",_rest.left_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.torso,"rotation",_rest.torso.rotation,.24)
	_active_tween.parallel().tween_property(bow,"rotation_degrees",WEAPON_GRIP_ROTATIONS.bow,.24)
	_queue_lower_body_recovery(.24)


func _animate_fire_crossbow() -> void:
	var crossbow: GearVisual = _gear.get("weapon")
	if not crossbow or loadout.weapon != "crossbow":
		return
	# Raise the compact stock from its two-handed rest into a level firing line.
	# The support hand is solved continuously against the forward stock socket.
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-48.0,.18)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",48.0,.18)
	_active_tween.parallel().tween_property(crossbow,"rotation_degrees",-90.0,.18)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",-4.0,.18)
	_queue_ranged_footwork("bow","ready",.18)
	# A short sighting beat replaces the long elastic draw used by a hand bow.
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-54.0,.14)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",54.0,.14)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",-7.0,.14)
	_queue_ranged_footwork("bow","draw",.14)
	_active_tween.tween_interval(.06)
	_active_tween.tween_callback(_fire_crossbow_bolt)
	# Compact recoil is sharp at the shoulder but remains grounded through both
	# legs before returning to the captured two-handed rest pose.
	_active_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-40.0,.08)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",40.0,.08)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",3.0,.08)
	_active_tween.parallel().tween_property(_bones.rig,"position:x",-6.0,.08)
	_queue_ranged_footwork("bow","recoil",.08)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation",_rest.right_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation",_rest.right_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation",_rest.left_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation",_rest.left_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.torso,"rotation",_rest.torso.rotation,.24)
	_active_tween.parallel().tween_property(_bones.rig,"position:x",_rest.rig.position.x,.24)
	_active_tween.parallel().tween_property(crossbow,"rotation_degrees",WEAPON_GRIP_ROTATIONS.crossbow,.24)
	_queue_lower_body_recovery(.24)


func _animate_staff_spell() -> void:
	var staff: GearVisual = _gear.get("weapon")
	if not staff or not _is_staff_weapon():
		return
	# Plant the staff forward, gather magic at its crystal, and release only
	# after a readable anticipation beat. The free hand frames the spell.
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-72.0,.18)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",24.0,.18)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation_degrees",-112.0,.18)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",42.0,.18)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",-8.0,.18)
	_active_tween.parallel().tween_property(staff,"rotation_degrees",180.0,.18)
	_queue_ranged_footwork("staff","gather",.18)
	_active_tween.tween_interval(.12)
	_active_tween.tween_callback(_release_staff_spell)
	# Hold the exact emission socket for two frames so the projectile visibly
	# separates from the crystal, then drive the staff arm, framing hand, torso,
	# and planted stance through one coherent follow-through instead of leaving
	# the upper body frozen in its gather pose until recovery.
	_active_tween.tween_interval(.04)
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-84.0,.10)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",12.0,.10)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation_degrees",-76.0,.10)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",18.0,.10)
	_active_tween.parallel().tween_property(_bones.torso,"rotation_degrees",4.0,.10)
	_active_tween.parallel().tween_property(_bones.rig,"position:x",12.0,.10)
	_queue_ranged_footwork("staff","release",.10)
	_active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(_bones.right_arm,"rotation",_rest.right_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation",_rest.right_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation",_rest.left_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation",_rest.left_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.torso,"rotation",_rest.torso.rotation,.24)
	_active_tween.parallel().tween_property(_bones.rig,"position:x",_rest.rig.position.x,.24)
	_queue_lower_body_recovery(.24)


func _release_staff_spell() -> void:
	var staff: GearVisual = _gear.get("weapon")
	if not staff:
		return
	var spell := Sprite2D.new()
	spell.name = "StaffSpell"
	spell.texture = STORYBOOK_SPELL_PROJECTILE
	var projectile_scale := absf(_bones.rig.scale.x)
	var flight_direction := -1.0 if facing == &"left" else 1.0
	spell.position = to_local(staff.to_global(staff.reach_endpoint()))
	spell.scale = Vector2.ONE*projectile_scale
	spell.z_index = 24
	# Projectiles live outside the animated rig after release, otherwise torso
	# recoil and footwork drag the supposedly detached spell through world space.
	add_child(spell)
	var flight := spell.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	flight.tween_property(spell,"position:x",spell.position.x+320.0*projectile_scale*flight_direction,.38)
	flight.parallel().tween_property(spell,"rotation",TAU,.38)
	flight.parallel().tween_property(spell,"scale",Vector2.ONE*projectile_scale*.68,.38)
	flight.parallel().tween_property(spell,"modulate:a",0.0,.38).set_delay(.22)
	flight.tween_callback(spell.queue_free)


func _set_bow_drawing_hand(enabled: bool) -> void:
	if not _right_hand_base:
		return
	_right_hand_base.set_part("hand_grip_back" if enabled or loadout.weapon != "bow" else "hand_open")
	_right_hand_base.z_index = 20 if enabled else 7


func _apply_weapon_hand_parts() -> void:
	if _left_hand_base:
		var left_hand_grips: bool = loadout.weapon in ["bow","crossbow"] or _has_two_handed_axe_loadout()
		_left_hand_base.set_part("hand_grip_back" if left_hand_grips else "hand_open")
		_left_hand_base.z_index = 18 if _has_two_handed_axe_loadout() or loadout.weapon == "crossbow" else (14 if loadout.weapon == "bow" else 7)
		if race_id == "human" and CharacterCatalog.is_shield(loadout.offhand):
			_left_hand_base.set_part("hand_grip_back")
			if current_motion != &"climb":
				_left_hand_base.z_index = -2
	if _right_hand_base:
		_right_hand_base.set_part("hand_open" if loadout.weapon == "bow" else "hand_grip_back")


func _fire_arrow() -> void:
	var bow: GearVisual = _gear.get("weapon")
	if not bow:
		return
	var arrow := Sprite2D.new()
	arrow.name = "FiredArrow"
	arrow.texture = STORYBOOK_ARROW_PROJECTILE
	var projectile_scale := absf(_bones.rig.scale.x)
	var flight_direction := -1.0 if facing == &"left" else 1.0
	var release_bow_tip := bow.to_global(Vector2(58,0))
	# Place the authored arrow by its forward edge, not an approximate center,
	# so the final drawn tip and first detached tip are the same pixel in either
	# facing direction before ballistic flight begins.
	arrow.position = to_local(release_bow_tip)-Vector2(flight_direction*arrow.texture.get_width()*.5*projectile_scale,0)
	arrow.scale = Vector2.ONE*projectile_scale
	arrow.flip_h = facing == &"left"
	arrow.set_meta("release_bow_tip",release_bow_tip)
	arrow.z_index = 22
	add_child(arrow)
	# The bow already supplied the acceleration before release; once detached,
	# an arrow reads best at constant ballistic speed rather than lingering at
	# the bow under an ease-in curve while the string recoils.
	var flight := arrow.create_tween().set_trans(BALLISTIC_PROJECTILE_TRANSITION)
	flight.tween_property(arrow,"position:x",arrow.position.x+300.0*projectile_scale*flight_direction,.28)
	flight.parallel().tween_property(arrow,"modulate:a",0.0,.28).set_delay(.18)
	flight.tween_callback(arrow.queue_free)


func _fire_crossbow_bolt() -> void:
	var crossbow: GearVisual = _gear.get("weapon")
	if not crossbow:
		return
	crossbow.set_crossbow_loaded(false)
	var bolt := Sprite2D.new()
	bolt.name = "FiredBolt"
	bolt.texture = STORYBOOK_CROSSBOW_BOLT
	var projectile_scale := absf(_bones.rig.scale.x)
	var flight_direction := -1.0 if facing == &"left" else 1.0
	bolt.position = to_local(crossbow.to_global(crossbow.reach_endpoint()))
	bolt.scale = Vector2.ONE*projectile_scale
	bolt.flip_h = facing == &"left"
	bolt.z_index = 22
	add_child(bolt)
	var flight := bolt.create_tween().set_trans(BALLISTIC_PROJECTILE_TRANSITION)
	flight.tween_property(bolt,"position:x",bolt.position.x+330.0*projectile_scale*flight_direction,.24)
	flight.parallel().tween_property(bolt,"modulate:a",0.0,.24).set_delay(.15)
	flight.tween_callback(bolt.queue_free)


func _animate_leap() -> void:
	_active_tween.tween_property(_bones.rig,"position:y",12.0,.1)
	_active_tween.tween_property(_bones.rig,"position:y",-62.0,.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(_weapon_arm(),"rotation_degrees",-130,.22)
	_active_tween.tween_property(_bones.rig,"position:y",0.0,.28).set_ease(Tween.EASE_IN)
