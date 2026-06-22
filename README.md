# ARAf-wereldkaart — gedeelde web-app

Een interactieve wereldkaart van azoolresistente *Aspergillus fumigatus* (ARAf),
gevoed door één **centrale database**. Iedereen die de link opent ziet dezelfde
79 literatuurstudies én alle nieuwe vondsten die collega's toevoegen.

De kaart is een statische website (één HTML-bestand). De data leeft in
**Supabase** (een gratis Postgres-database met automatische REST-API). Er is dus
geen eigen server die je draaiend moet houden.

```
app/
├─ index.html     ← de kaart (frontend)
├─ config.js      ← hier vul je je Supabase-sleutels in
├─ schema.sql     ← databasetabel + beveiligingsregels
├─ seed.sql       ← de 79 studies uit de extractietabel
└─ README.md      ← dit bestand
```

---

## Wat je nodig hebt
- Een gratis Supabase-account (https://supabase.com) — voor de database.
- Een gratis Netlify- of GitHub-account — voor het hosten van de kaart.
- ± 15 minuten.

---

## Stap 1 — Database aanmaken (Supabase)

1. Ga naar https://supabase.com → **New project**. Kies een naam en een
   databasewachtwoord (bewaar dat ergens). Wacht tot het project klaar is.
2. Open in het linkermenu **SQL Editor** → **New query**.
3. Plak de volledige inhoud van **`schema.sql`** en klik **Run**.
4. Maak opnieuw een **New query**, plak de inhoud van **`seed.sql`** en klik
   **Run**. (Dit laadt de 79 literatuurstudies. `seed.sql` begint met
   `truncate`, dus je kunt het veilig opnieuw draaien om te resetten.)
5. Controleer via **Table Editor → araf_studies** dat er 79 rijen staan.

## Stap 2 — Sleutels invullen

1. In Supabase: **Project Settings → API**.
2. Kopieer **Project URL** en de **anon public** key.
3. Open **`config.js`** en vul ze in:

   ```js
   window.ARAF_CONFIG = {
     SUPABASE_URL: "https://abcd1234.supabase.co",
     SUPABASE_ANON_KEY: "eyJhbGciOi...lange-sleutel..."
   };
   ```

   > De anon-sleutel mág publiek zijn. De database is beveiligd met Row Level
   > Security (zie `schema.sql`): iedereen mag lezen en nieuwe vondsten
   > toevoegen, maar de geseedede literatuur kan niet worden gewijzigd of
   > verwijderd.

## Stap 3 — Kaart online zetten

**Optie A — Netlify Drop (snelst, geen account-config):**
1. Ga naar https://app.netlify.com/drop
2. Sleep de **hele `app`-map** (met je ingevulde `config.js`) in het venster.
3. Je krijgt direct een openbare link — die deel je met anderen.

**Optie B — GitHub Pages:**
1. Maak een repository en upload de inhoud van `app/`.
2. **Settings → Pages → Deploy from branch** → kies `main` / root.
3. De kaart staat op `https://<gebruiker>.github.io/<repo>/`.

Klaar. Iedereen met de link ziet de gedeelde kaart en kan vondsten toevoegen.

---

## Lokaal testen (optioneel)
Open `index.html` niet rechtstreeks via dubbelklik (sommige browsers blokkeren
dan de API-aanroep). Draai een mini-server in de `app`-map:

```bash
python3 -m http.server 8000
# open daarna http://localhost:8000
```

---

## Hoe het werkt
- **Lezen:** bij het openen haalt `index.html` alle rijen op uit de tabel
  `araf_studies` via de Supabase REST-API.
- **Toevoegen:** "+ Nieuwe vondst" schrijft een rij met `source = 'gebruiker'`
  naar dezelfde tabel. Na opslaan herlaadt de kaart, dus de stip verschijnt voor
  iedereen.
- **Eén stip per studie.** Klikken toont alle isolaat-regels (mechanisme,
  N resistent/getest, MIC ITZ/VCZ/PCZ/ISA, pagina) — exact de kolommen uit
  `EXTRACTIETABEL_DEFINITIEF.csv`.
- **Export CSV** downloadt de volledige database in hetzelfde kolomformaat als
  de mastertabel.

## Datamodel (tabel `araf_studies`)
| kolom | betekenis |
|-------|-----------|
| study | Auteur & jaar |
| land | Land/regio |
| lat, lon | coördinaten van de stip |
| label | korte locatieomschrijving |
| setting | Klinisch / Omgeving / Klinisch + Omgeving / Veterinair |
| design | studiedesign |
| mechs | hoofdmechanismen (JSON-lijst) |
| isolates | alle extractietabel-regels van de studie (JSON) |
| source | `literatuur` (seed) of `gebruiker` (toegevoegd) |
| added_by | optionele naam van de inzender |

## Toegang beperken (optioneel, geavanceerder)
Standaard mag iedereen met de link toevoegen. Wil je dat alleen ingelogde
mensen kunnen bijdragen, zet dan in Supabase **Authentication** aan en pas de
`insert`-policy in `schema.sql` aan naar `with check (auth.role() =
'authenticated')`. Lezen kan dan publiek blijven.

## Nieuwe coördinaten
Bij het toevoegen kun je in het formulier op de kaart klikken om lat/lon
automatisch in te vullen, of ze handmatig intypen.
