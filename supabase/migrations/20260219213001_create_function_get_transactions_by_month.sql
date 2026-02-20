create or replace function get_transactions_by_month(par_month int, par_year int)
returns table(
  id bigint,
  name varchar,
  amount_cents int,
  transaction_type_id bigint,
  payment_type_id bigint,
  payment_type jsonb, 
  created_at timestamptz,
  updated_at timestamptz,
  installment_id bigint,
  portion int,
  total_portions int,
  payment_date date
)
language sql
as $$
  select
    transactions.id,
    transactions.name,
    transactions.amount_cents,
    transactions.transaction_type_id,
    transactions.payment_type_id,
    jsonb_build_object('name', payment_types.name) as payment_type,
    transactions.created_at,
    transactions.updated_at,
    installments.id as installment_id,
    installments.portion,
    installments.total_portions,
    installments.payment_date
  from transactions
  join installments on installments.transaction_id = transactions.id
  join payment_types on transactions.payment_type_id = payment_types.id
  where extract(month from installments.payment_date) = par_month
    and extract(year from installments.payment_date) = par_year;
$$;