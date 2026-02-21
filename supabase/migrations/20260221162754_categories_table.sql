CREATE TABLE IF NOT EXISTS categories (
	id serial NOT NULL,
	name CHARACTER varying NOT null,
	icon character varying,
	primary key (id)
)