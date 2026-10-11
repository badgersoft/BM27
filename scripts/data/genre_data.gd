class_name GenreData
extends RefCounted
## Music genres. "family" drives how badly a genre switch upsets fans:
## moving within a family is a shrug, moving across families is a betrayal.

const LIST := [
	{"id": "rock", "name": "Rock", "color": "#e63946", "family": "heavy",
		"blurb": "Big riffs, bigger choruses, a bit of blues. Never goes out of style."},
	{"id": "metal", "name": "Heavy Metal", "color": "#b8b8c0", "family": "heavy",
		"blurb": "Double kick drums, devil horns, and a lot of leather."},
	{"id": "grunge", "name": "Grunge", "color": "#9aa63a", "family": "heavy",
		"blurb": "Loud-quiet-loud. Flannel compulsory. Washing optional."},
	{"id": "punk", "name": "Punk", "color": "#ff2e88", "family": "alt",
		"blurb": "Three chords and the truth, from snarling '77 to skatepark pop punk."},
	{"id": "britpop", "name": "Britpop", "color": "#3a86ff", "family": "alt",
		"blurb": "Parkas, swagger and chip-shop anthems."},
	{"id": "indie", "name": "Indie", "color": "#4cc9f0", "family": "alt",
		"blurb": "Jangly guitars, skinny jeans, the odd synth and songs about bus stops."},
	{"id": "altrock", "name": "Alt Rock", "color": "#9d4edd", "family": "alt",
		"blurb": "Fuzz pedals, walls of reverb and lyrics nobody fully understands."},
]
