create or replace function get_due_months()
returns table(due_month double precision, due_year double precision) 
language sql
as $$
  select distinct 
    extract(month from installments.payment_date) as due_month,
    extract(year from installments.payment_date) as due_year
  from transactions
  join installments on installments.transaction_id = transactions.id
  order by due_year, due_month;
$$;