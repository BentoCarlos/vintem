CREATE TABLE if not exists transactions(
	id bigserial NOT NULL,
	name character varying NOT NULL,
	amount_cents integer,
	transaction_type_id bigint,
	payment_type_id bigint,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id),
	CONSTRAINT FK_TRANSACTIONS_TRANSACTION_TYPE FOREIGN KEY(transaction_type_id) REFERENCES transaction_types(id),
	CONSTRAINT FK_TRANSACTIONS_PAYMENT_TYPE FOREIGN KEY(payment_type_id) REFERENCES payment_types(id)
);