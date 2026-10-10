class_name GenreData
extends RefCounted
## Music genres. "family" drives how badly a genre switch upsets fans:
## moving within a family is a shrug, moving across families is a betrayal.

const LIST := [
	{"id": "rock", "name": "Rock", "color": "#e63946", "family": "heavy",
		"blurb": "Big riffs, bigger choruses. Never goes out of style."},
	{"id": "indie", "name": "Indie", "color": "#4cc9f0", "family": "alt",
		"blurb": "Jangly guitars, skinny jeans and songs about bus stops."},
	{"id": "grunge", "name": "Grunge", "color": "#9aa63a", "family": "heavy",
		"blurb": "Loud-quiet-loud. Flannel compulsory. Washing optional."},
	{"id": "metal", "name": "Heavy Metal", "color": "#b8b8c0", "family": "heavy",
		"blurb": "Double kick drums, devil horns, and a lot of leather."},
	{"id": "punk", "name": "Punk", "color": "#ff2e88", "family": "loud",
		"blurb": "Three chords and the truth. Mostly the three chords."},
	{"id": "poppunk", "name": "Pop Punk", "color": "#ff9f1c", "family": "loud",
		"blurb": "Skateparks, heartbreak and jumping off drum risers."},
	{"id": "britpop", "name": "Britpop", "color": "#3a86ff", "family": "alt",
		"blurb": "Parkas, swagger and chip-shop anthems."},
	{"id": "altrock", "name": "Alt Rock", "color": "#9d4edd", "family": "alt",
		"blurb": "Fuzz pedals and lyrics nobody fully understands."},
	{"id": "shoegaze", "name": "Shoegaze", "color": "#f4a6c1", "family": "dream",
		"blurb": "A wall of reverb. Eye contact is strictly forbidden."},
	{"id": "bluesrock", "name": "Blues Rock", "color": "#2a9d8f", "family": "heavy",
		"blurb": "Bent strings, sweaty bars and a bottleneck slide."},
	{"id": "edm", "name": "EDM", "color": "#00f5d4", "family": "electronic",
		"blurb": "Wait for it... wait for it... DROP."},
]
