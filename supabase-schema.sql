-- Word Chain Multiplayer - Supabase schema
-- Run this script in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[A-Z0-9]{6}$'),
  host_id uuid not null,
  status text not null default 'lobby' check (status in ('lobby','playing','finished')),
  game_mode text not null default 'domino' check (game_mode in ('domino','contains')),
  created_at timestamptz not null default now()
);

create table if not exists public.room_players (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  player_id uuid not null,
  name text not null check (char_length(name) between 1 and 18),
  ready boolean not null default false,
  score integer not null default 0,
  is_host boolean not null default false,
  connected boolean not null default true,
  joined_at timestamptz not null default now(),
  unique(room_id, player_id)
);

create index if not exists room_players_room_id_idx on public.room_players(room_id);
create index if not exists rooms_code_idx on public.rooms(code);

alter table public.rooms enable row level security;
alter table public.room_players enable row level security;

-- Rooms: players can find a room by its 6-character code.
drop policy if exists "rooms_select" on public.rooms;
create policy "rooms_select" on public.rooms for select to authenticated using (true);

drop policy if exists "rooms_insert_host" on public.rooms;
create policy "rooms_insert_host" on public.rooms for insert to authenticated
with check (host_id = auth.uid());

drop policy if exists "rooms_update_host" on public.rooms;
create policy "rooms_update_host" on public.rooms for update to authenticated
using (host_id = auth.uid()) with check (host_id = auth.uid());

drop policy if exists "rooms_delete_host" on public.rooms;
create policy "rooms_delete_host" on public.rooms for delete to authenticated
using (host_id = auth.uid());

-- Room players: all members of a room can see the lobby.
drop policy if exists "room_players_select" on public.room_players;
create policy "room_players_select" on public.room_players for select to authenticated using (true);

drop policy if exists "room_players_insert_self" on public.room_players;
create policy "room_players_insert_self" on public.room_players for insert to authenticated
with check (player_id = auth.uid());

drop policy if exists "room_players_update_self" on public.room_players;
create policy "room_players_update_self" on public.room_players for update to authenticated
using (player_id = auth.uid()) with check (player_id = auth.uid());

drop policy if exists "room_players_delete_self" on public.room_players;
create policy "room_players_delete_self" on public.room_players for delete to authenticated
using (player_id = auth.uid());

-- Enable Realtime for lobby updates.
do $$
begin
  alter publication supabase_realtime add table public.rooms;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.room_players;
exception when duplicate_object then null;
end $$;


-- Multiplayer shared gameplay state (run this migration after the lobby schema above)
create table if not exists public.room_game_state (
  room_id uuid primary key references public.rooms(id) on delete cascade,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.room_game_state enable row level security;

drop policy if exists "room_game_state_select" on public.room_game_state;
create policy "room_game_state_select" on public.room_game_state for select to authenticated
using (exists (select 1 from public.room_players rp where rp.room_id = room_game_state.room_id and rp.player_id = auth.uid()));

drop policy if exists "room_game_state_insert_host" on public.room_game_state;
create policy "room_game_state_insert_host" on public.room_game_state for insert to authenticated
with check (exists (select 1 from public.rooms r where r.id = room_game_state.room_id and r.host_id = auth.uid()));

drop policy if exists "room_game_state_update_member" on public.room_game_state;
create policy "room_game_state_update_member" on public.room_game_state for update to authenticated
using (exists (select 1 from public.room_players rp where rp.room_id = room_game_state.room_id and rp.player_id = auth.uid()))
with check (exists (select 1 from public.room_players rp where rp.room_id = room_game_state.room_id and rp.player_id = auth.uid()));

do $$
begin
  alter publication supabase_realtime add table public.room_game_state;
exception when duplicate_object then null;
end $$;
