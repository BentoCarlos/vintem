CREATE TABLE if not exists payment_types (
	id BIGSERIAL NOT NULL,
	name character varying NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id)
);