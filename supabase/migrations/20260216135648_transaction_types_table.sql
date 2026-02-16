CREATE TABLE if not exists transaction_types (
	id bigserial NOT NULL,
	name character varying NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id)
);