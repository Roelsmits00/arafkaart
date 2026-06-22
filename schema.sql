-- ============================================================
--  ARAf-wereldkaart  ·  databaseschema voor Supabase (Postgres)
--  Voer dit ALS EERSTE uit in de Supabase SQL Editor,
--  daarna seed.sql om de 79 literatuurstudies te laden.
-- ============================================================

create table if not exists araf_studies (
  id          bigint generated always as identity primary key,
  study       text not null,              -- Auteur & jaar
  land        text,                       -- Land/regio
  lat         double precision not null,  -- latitude
  lon         double precision not null,  -- longitude
  label       text,                       -- korte locatielabel
  design      text,                       -- studiedesign
  setting     text,                       -- Klinisch / Omgeving / Klinisch + Omgeving / Veterinair
  mechs       jsonb default '[]'::jsonb,  -- hoofdmechanismen (TR34/L98H, TR46/...)
  isolates    jsonb default '[]'::jsonb,  -- alle extractietabel-regels van deze studie
  source      text default 'gebruiker',   -- 'literatuur' (seed) of 'gebruiker' (toegevoegd)
  added_by    text,                       -- optioneel: naam/initialen van inzender
  created_at  timestamptz default now()
);

-- Row Level Security: publiek lezen + toevoegen, alleen eigen toevoegingen verwijderen.
alter table araf_studies enable row level security;

-- Iedereen mag de kaart lezen.
drop policy if exists "araf read" on araf_studies;
create policy "araf read"
  on araf_studies for select
  using (true);

-- Iedereen mag nieuwe vondsten toevoegen (source moet 'gebruiker' zijn,
-- zodat de geseedede literatuur niet kan worden nagebootst als 'literatuur').
drop policy if exists "araf insert" on araf_studies;
create policy "araf insert"
  on araf_studies for insert
  with check (source = 'gebruiker');

-- Alleen door gebruikers toegevoegde records mogen verwijderd worden;
-- de literatuur-seed blijft beschermd.
drop policy if exists "araf delete user" on araf_studies;
create policy "araf delete user"
  on araf_studies for delete
  using (source = 'gebruiker');

-- index voor sneller filteren
create index if not exists araf_setting_idx on araf_studies (setting);
create index if not exists araf_source_idx  on araf_studies (source);
