-- 장비 예약 캘린더용 Supabase SQL
-- SQL Editor에서 이 파일 전체를 한 번 실행하세요.

create table if not exists public.equipment (
  id uuid primary key,
  name text not null unique check (char_length(name) between 1 and 30),
  icon text not null default '🔧',
  created_at timestamptz not null default now()
);
create table if not exists public.reservations (
  id uuid primary key,
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  reservation_date date not null,
  user_name text not null check (char_length(user_name) between 1 and 30),
  start_time time not null,
  end_time time not null,
  created_at timestamptz not null default now(),
  check (start_time < end_time)
);

alter table public.equipment enable row level security;
alter table public.reservations enable row level security;
drop policy if exists "Allowed users manage equipment" on public.equipment;
drop policy if exists "Shared equipment access" on public.equipment;
create policy "Shared equipment access" on public.equipment for all to anon using (true) with check (true);
drop policy if exists "Allowed users manage reservations" on public.reservations;
drop policy if exists "Shared reservation access" on public.reservations;
create policy "Shared reservation access" on public.reservations for all to anon using (true) with check (true);
grant select, insert, update, delete on public.equipment, public.reservations to anon;

create or replace function public.save_reservation(p_id uuid,p_equipment_id uuid,p_date date,p_name text,p_start time,p_end time)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_start >= p_end then raise exception '종료 시간은 시작 시간보다 늦어야 합니다.'; end if;
  perform pg_advisory_xact_lock(hashtext(p_equipment_id::text || p_date::text));
  if exists (select 1 from reservations where equipment_id=p_equipment_id and reservation_date=p_date and id<>p_id and p_start<end_time and p_end>start_time) then raise exception '같은 장비에 겹치는 시간의 예약이 이미 있습니다.'; end if;
  insert into reservations (id,equipment_id,reservation_date,user_name,start_time,end_time) values (p_id,p_equipment_id,p_date,p_name,p_start,p_end)
  on conflict (id) do update set equipment_id=excluded.equipment_id,reservation_date=excluded.reservation_date,user_name=excluded.user_name,start_time=excluded.start_time,end_time=excluded.end_time;
end; $$;
grant execute on function public.save_reservation(uuid,uuid,date,text,time,time) to anon;

do $$ begin alter publication supabase_realtime add table public.equipment; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.reservations; exception when duplicate_object then null; end $$;
