-- Furacão ES | Supabase
-- Execute no SQL Editor do projeto Supabase antes de liberar os acessos.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  codigo_vendedor text unique,
  perfil text not null check (perfil in ('gestor','vendedor')),
  ativo boolean not null default true,
  created_at timestamptz not null default now(),
  constraint profile_role_code check (
    (perfil = 'gestor') or (perfil = 'vendedor' and codigo_vendedor is not null)
  )
);

create table if not exists public.lancamentos (
  id uuid primary key default gen_random_uuid(),
  vendedor_id uuid not null references public.profiles(id) on delete restrict,
  data date not null,
  meta_mensal numeric(14,2) not null default 0,
  meta_dia_inicial numeric(14,2) not null default 0,
  meta_dia_desafio numeric(14,2) not null default 0,
  dias_uteis_mes integer not null default 0,
  dias_trabalhados integer not null default 0,
  faturamento_dia numeric(14,2) not null default 0,
  carteira_ativa integer not null default 0,
  contatos_ativos integer not null default 0,
  contatos_inativos integer not null default 0,
  positivados_mes integer not null default 0,
  reativados_mes integer not null default 0,
  observacoes text,
  atualizado_em timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (vendedor_id, data)
);

create or replace function public.current_user_is_manager()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.perfil = 'gestor' and p.ativo = true
  );
$$;

alter table public.profiles enable row level security;
alter table public.lancamentos enable row level security;

drop policy if exists "profile self or manager read" on public.profiles;
create policy "profile self or manager read" on public.profiles
for select to authenticated
using (id = auth.uid() or public.current_user_is_manager());

drop policy if exists "manager manages profiles" on public.profiles;
create policy "manager manages profiles" on public.profiles
for all to authenticated
using (public.current_user_is_manager())
with check (public.current_user_is_manager());

drop policy if exists "seller reads own or manager reads all" on public.lancamentos;
create policy "seller reads own or manager reads all" on public.lancamentos
for select to authenticated
using (
  public.current_user_is_manager()
  or exists (
    select 1 from public.profiles p
    where p.id = lancamentos.vendedor_id
      and p.id = auth.uid()
      and p.perfil = 'vendedor'
      and p.ativo = true
  )
);

drop policy if exists "manager inserts or updates snapshots" on public.lancamentos;
create policy "manager inserts or updates snapshots" on public.lancamentos
for all to authenticated
using (public.current_user_is_manager())
with check (public.current_user_is_manager());

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.lancamentos to authenticated;

-- Cadastro de usuários:
-- 1) Crie primeiro os 7 usuários em Authentication > Users (e-mail corporativo + convite/reset de senha).
-- 2) Copie cada UUID e insira abaixo em profiles.
-- 3) Para os seis vendedores use os códigos: 1183, 2613, 2638, 2721, 2987, 2999.
-- 4) Cadastre o usuário gerencial com perfil='gestor' e codigo_vendedor=NULL.
-- Nunca coloque senha, service_role key ou segredo administrativo neste arquivo/frontend.
