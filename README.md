# Vintem

Aplicativo de controle de gastos simples, construído com SwiftUI para macOS e integrado ao Supabase. O app exibe um resumo do total gasto, lista de transações com busca e um gráfico de pizza por tipo de pagamento. Também permite criar novas transações com parcelamento e data de vencimento.

## Screenshots

![Tela Principal](docs/screenshots/main.png)
![Nova Transação](docs/screenshots/new-transaction.png)
![Detalhe da Transação](docs/screenshots/detail.png)

## Visão geral
- **Plataforma:** macOS (SwiftUI)
- **Persistência/Backend:** Supabase (Postgres + APIs)
- **Gráficos:** Swift Charts
- **Concurrency:** async/await
- **Estado:** ObservableObject + EnvironmentObject
- **Design:** componentes com efeito "glass" (`.glass`, `.glassProminent`, `.glassEffect`)

## Funcionalidades
- Listagem de transações com busca por texto
- Cartão de resumo com o total gasto (BRL)
- Gráfico de pizza por tipo de pagamento (Crédito, Débito, Pix, Dinheiro, Outro)
- Criação de transações com:
  - Título, valor e tipo de pagamento
  - Parcelamento (1x até 24x) com cálculo automático do valor por parcela
  - Data de vencimento inicial das parcelas
- Exclusão de transações (remove parcelas associadas antes)
- Estados de carregamento e erro com ação de "Tentar novamente"

## Pré-requisitos
- macOS 14+
- Xcode 15+
- Uma conta e projeto no Supabase

## Configuração do Supabase

1. Crie um projeto no Supabase e obtenha:
   - `SUPABASE_DB_URL` (ex.: `https://<sua-instancia>.supabase.co`)
   - `SUPABASE_DB_KEY` (chave anon ou service role para desenvolvimento local)

2. Crie as tabelas com o schema abaixo:
```sql
create table public.transactions (
  id bigserial not null,
  created_at timestamp without time zone not null default now(),
  updated_at timestamp without time zone not null default now(),
  amount_cents integer null,
  transaction_type_id bigint null,
  payment_type_id bigint null,
  name character varying null,
  constraint transactions_pkey primary key (id),
  constraint fk_rails_369c4e188e foreign key (payment_type_id) references payment_types (id),
  constraint fk_rails_63d2d7b1f8 foreign key (transaction_type_id) references transaction_types (id)
);

create table public.transaction_types (
  id bigserial not null,
  name character varying null,
  created_at timestamp without time zone not null,
  updated_at timestamp without time zone not null,
  constraint transaction_types_pkey primary key (id)
);

create table public.payment_types (
  id bigserial not null,
  name character varying null,
  created_at timestamp without time zone not null default now(),
  updated_at timestamp without time zone not null default now(),
  constraint payment_types_pkey primary key (id),
  constraint payment_types_name_key unique (name)
);

create table public.installments (
  id bigserial not null,
  transaction_id bigint not null,
  portion integer not null,
  total_portions integer not null,
  payment_date date not null,
  created_at timestamp without time zone not null default now(),
  updated_at timestamp without time zone not null default now(),
  constraint installments_pkey primary key (id),
  constraint fk_installments_transaction foreign key (transaction_id) references transactions (id) on delete cascade
);
```

3. No Xcode, configure as credenciais em `SupabaseManager.swift`:
```swift
let client = SupabaseClient(
    supabaseURL: URL(string: "SUPABASE_DB_URL")!,
    supabaseKey: "SUPABASE_DB_KEY"
)
```
