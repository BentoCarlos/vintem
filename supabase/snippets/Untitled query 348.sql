select *
from transactions
join installments on installments.transaction_id = transactions.id
where extract(month from installments.payment_date) = :par_Month and
      extract(year from installments.payment_date) = :par_Year