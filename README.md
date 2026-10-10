# Band Manager 27

*A rock band management simulation by **Badger-soft**.*

From Nan's garden shed to Wombley Stadium. Pick a manager, scrape together four
musicians, book grotty gigs, survive the egos, climb the charts, and either
retire as legends on a Final Tour or watch it all fall apart.

Built with **Godot 4.7** (2D, GL Compatibility renderer) for **PC and mobile**.

---

## Running it

1. Install [Godot 4.7](https://godotengine.org/download) (standard build, no .NET needed).
2. Open Godot → **Import** → select this folder's `project.godot`.
3. Press **F5** (Run Project).

The game is landscape-only. The UI scales with the window (`canvas_items` stretch,
`expand` aspect), so it works from 16:9 monitors to 20:9 phones and 4:3 tablets.
There's also an Interface Size setting (S/M/L/XL); phones default to L.

## Exporting

`export_presets.cfg` contains presets for **Windows, macOS, Linux, Android, iOS and Web**.
Install the export templates first (*Editor → Manage Export Templates*), then use
*Project → Export*. Builds go to `builds/` (git-ignored).

| Platform | What you still need to supply |
|---|---|
| Windows / Linux | Nothing. |
| macOS | Signing/notarisation if you want to distribute outside your own machine. |
| Android | A keystore (*Editor Settings → Export → Android*) and the Android SDK. Package: `com.badgersoft.bandmanager27`, arm64. |
| iOS | Your Apple Team ID in the iOS preset, then build the exported Xcode project. |
| Web | Nothing (single-threaded build, so no special server headers needed). |

Saves live in `user://` (`bm27_save.json`, `bm27_halloffame.json`, `settings.cfg`).
The game autosaves every week and when a phone sends the app to the background.

---

## How it plays

| Brief item | Where it lives |
|---|---|
| Main menu: Information, Settings, *Let's Get Famous* | `scripts/screens/main_menu.gd` (+ Continue, Hall of Fame) |
| 4 managers offered from 12 (4 female, 8 male, data-driven) | `scripts/data/manager_data.gd`. Add/remove freely, nothing depends on the count. |
| Cartoon portraits | `scripts/ui/portrait.gd`: vector SVG faces built from a "look" (hair, beard, glasses, clothes, age lines...), rasterised at runtime so they're crisp at any resolution |
| Bio, tastes, favourite genre, spoof favourite album, £500–£5,000 funds | Manager data |
| 12 rehearsal spaces (Nan's Shed → The Townhouse, London) | `scripts/data/venue_data.gd` (`PRACTICE`) |
| 15 gig venues, Village Hall (25 people, £100, £2.50 a head + half the bar) → Wombley (100,000, £100 a head + merch) | `scripts/data/venue_data.gd` (`GIGS`) |
| 50 musicians per role, freelancers to superstars, skill + potential | `scripts/autoload/data.gd` builds a fixed seeded database. Stars/Superstars are spoofs in `musician_data.gd` (Freddie Mercurial, Dave Grohlnut, Flea Market, Jimi Hendrinks...) |
| Instruments per member, upgradeable | `scripts/data/instrument_data.gd`, 8 tiers per role (Biscuit-Tin Kit → The Grohlnut Signature Kit) |
| Contentment, "how easy to please" (temperament), complaints, gifts and bonuses | `WeekSim._happiness`, complaint events, Band page *Treat* |
| Weekly updates | HQ *Weekly Update* card (optional pop-up in Settings) |
| Interviews scaling from the school paper to global TV | `MediaData.OUTLETS`, with a choice of tone: Humble / Cocky / Mysterious / Controversial |
| Rehearsing, potential caps, rare breakthroughs | `WeekSim._train` |
| Funds, Fans, Listeners, Genre, Fame, Lifespan (per member, ★ for originals) | HQ top bar, Fans page and Band page |
| Monthly gig: book 1 of 2–3 offers, or skip (costs fans); sometimes no venue will have you | Gigs page, `WeekSim.generate_gig_offers` |
| Gig-night splash: crowd breakdown, crowd and critic ratings, conversions | `EventView._gig` + `StageArt` (generated stage scene; crowd density matches attendance) |
| Signing at or below asking price depending on contentment | Negotiation dialog (`MusicianView.open_offer`) |
| Famous enough: stars approach you at up to 50% off | `Events._star_offer` |
| Fortnightly newspaper; you start in the small print and work up to the headline | `Events.queue_news`, `EventView._news` |
| Rival bands (spoofs and locals) in your genre and fame range | `scripts/data/band_data.gd`, Scene page |
| Producers (rubbish to genius), the It Factor, local and national charts, a weekly position with movement, dropped singles shown for one more week, archive | `Charts`, producer/name events, Charts and Releases pages |
| Two Top-20 singles → album deal, album sales worth 5× | `Events` label offer, Album Top 20 |
| Documentary and concert film deals | `Events.roll_weekly` |
| Fans collapsing → members leave (with 2–3 replacements offered) or the band splits (game over) | `WeekSim._check_endings`, `Events.queue_member_left` |
| Final Tour (6 months, bigger crowds and merch) → retirement | Home page once eligible (2 years together, fame 35+) |
| Name the band: 4 genre-appropriate suggestions or your own | `scripts/screens/band_name_screen.gd`, `NameData` |

### The public base

The audience is **~29,000 named people** across 9 regions, simulated individually
(`scripts/sim/public.gd`, data in `scripts/data/region_data.gd`).

| Region | Cities (people) |
|---|---|
| Northwest England | Manchester (~1,400), Liverpool (~1,400), Preston (~1,000) |
| Northeast England | Newcastle (~1,200), Sunderland, Middlesbrough |
| Midlands | Birmingham (~1,400), Nottingham, Leicester |
| Southeast England | Brighton, Southampton, Portsmouth |
| Southwest England | Bristol, Plymouth, Bournemouth |
| Wales | Cardiff (~1,200), Swansea, Newport |
| Ireland | Dublin (~1,200), Belfast, Cork |
| Scotland | Glasgow (~1,200), Edinburgh, Aberdeen |
| London | City of London (3,000) |

Each person has a first name, gender, age, favourite and second-favourite genre,
gig likelihood, **variance** (appetite for new music; younger people run higher),
**loyalty** (how much bad stuff they'll put up with; older people run higher) and a
**fanatic** score (0–100) for your band. Each city has its own scene flavour
(Birmingham loves metal, Manchester Britpop, Bristol EDM…).

- **Fan ladder:** Not a fan → Listener → Regular listener → Fan → Super fan (needs
  six months as a fan). Real fans track how many months they've been a fan.
- **Home city:** chosen at setup. Bigger cities have more potential fans but
  rehearsal rent and ordinary venues cost more (×1.0 to ×1.83).
- **Spreading:** Local → Regional (25 real fans at home) → National (a regional
  following, or a national chart hit). Gig offers start coming from other cities.
- **Gigs:** every fan and listener decides whether to come, based on tier, gig
  likelihood and distance (super fans travel; listeners rarely do). The crowd's
  verdict changes how each attendee feels; good walk-ins become listeners.
- **Fans page:** the ladder, your reach, a **Top Fans** table (name, how long
  they've been a fan, home city) once you have more than 25 real fans, fan
  demographics, and a city-by-city breakdown.
- **Scale:** while you're local, every person is one real person. As you spread,
  each person comes to stand for more real people (up to ~60×), so 29,000 people
  can still fill Wombley. The Fans page shows the current figure.
- **Saving:** traits are regenerated from a seed; only feelings are saved
  (compressed), adding ~10–50 KB.

### Extras I added

- **Weekly focus**: Rehearse / Write Songs / Busk / Promote / Chill Out. This gives every week a meaningful choice, and a way to earn your first few quid.
- **Song bank**: writing builds it, gigs and singles use it, and recording uses it up.
- **Fatigue**: grinding without rest wears the band down. Chill weeks matter.
- **Manager perks**: each manager has one trick (Barry's *Silver Tongue*, Zed's *Gone Viral*, Bernie's *Gear Head*...). Poorer managers get stronger perks.
- **Venue expectations**: crowds at bigger venues expect more, so booking above your level is a gamble.
- **Gig clashes**: a rival in your genre playing across town can pinch your crowd.
- **Genre trends** that shift monthly (Scene page).
- **Random events**: dead vans, flooded rehearsal rooms, viral clips, advert offers, dodgy kebabs.
- **Hidden potential**: you see a range until someone joins (Jam the *Talent Spotter* sees it exactly).
- **Hall of Fame** with a legacy score, plus three difficulty levels.

---

## Project layout

```
project.godot            Godot 4.7 project (autoloads: Settings, Data, Game)
export_presets.cfg       PC + mobile + web export presets
scenes/main.tscn         The only scene; everything else is built in code
assets/fonts/            Bebas Neue, Barlow, Barlow Condensed, Playfair Display (OFL)
scripts/
  autoload/              settings.gd, data.gd (databases + generators), game.gd (state, actions, save/load)
  data/                  All static content: managers, venues, instruments, musicians, bands, names, media
  sim/                   week_sim.gd (weekly tick), charts.gd, events.gd
  ui/                    Theme, icons, portraits, stage art, widgets, modals (event_view.gd)
  screens/               Menu, info, settings, hall of fame, setup steps, HQ, end
  pages/                 HQ pages: home, band, talent, gigs, rehearsal, charts, releases, scene, inbox
  dev/auto_player.gd     A bot manager used by the tests
tests/                   Headless balance test + portrait sheet (excluded from exports)
```

### Design and performance notes

- **No image assets**: icons, portraits, the logo, the stage and the newspaper are vector
  SVG generated in code and rasterised once (cached), so they're sharp on any screen
  and the exported game is under 1 MB.
- **Low-processor mode** is on: the game only redraws when something changes, which
  is kind to phone batteries.
- UI is plain Godot `Control` containers with one code-built `Theme` (`ui_theme.gd`),
  so restyling is done in one place.

## Testing

```bash
# Balance: a bot plays whole careers headless and prints progress
godot --headless --path . res://tests/sim_test.tscn -- --weeks=400 --runs=4
#   --neglect      a lazy manager (exercises complaints, quitting, break-ups)
#   --tour=250     announce the Final Tour at week 250 (exercises retirement)

# Screenshot tour of every screen and modal (needs a display, or xvfb-run)
godot --path . -- --autotest --out=res://tests/shots
#   --uiscale=3    test the XL interface size (narrow phone layouts)
#   --monkey --steps=3000   press random buttons to smoke-test every UI callback

# Public base performance and save size
godot --headless --path . res://tests/perf_check.tscn
```

## Credits

Game design and code by Badger-soft. Fonts: Bebas Neue, Barlow, Barlow Condensed and
Playfair Display, all under the SIL Open Font License (see `assets/fonts/`).
All bands, musicians, venues, albums and publications are fictional parodies.
No badgers were harmed.
