CREATE TABLE if not exists installments(
	id bigserial NOT NULL,
	transaction_id bigint NOT NULL,
	portion SMALLINT NOT NULL,
	total_portions SMALLINT NOT NULL,
	payment_date timestamptz,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id, transaction_id),
	CONSTRAINT FK_INSTALLMENT_TRANSACTION_ID FOREIGN KEY(transaction_id) REFERENCES transactions(id)
);