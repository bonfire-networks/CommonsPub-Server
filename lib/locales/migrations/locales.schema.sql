DROP TABLE IF EXISTS "countries";
CREATE TABLE "countries" (
    "id" character(2) DEFAULT '' NOT NULL,
    "name_eng" character varying(100),
    "name_local" character varying(250),
    "name_eng_formal" character varying(100),
    "language_main" character(3),
    "capital" character varying(100),
    "continent_id" character(2),
    "currency_id" character varying(3),
    "main_tz" character varying(50),
    "tel_prefix" character varying(20),
    "id_3letter" character varying(3),
    "id_iso" integer,
    "tld" character varying(11),
    "population" bigint,
    CONSTRAINT "idx_17472_primary" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "countries_name_eng" ON "countries" USING btree ("name_eng");

CREATE INDEX "countries_name_local" ON "countries" USING btree ("name_local");

CREATE INDEX "idx_17472_continent_id" ON "countries" USING btree ("continent_id");

CREATE INDEX "idx_17472_currency_id" ON "countries" USING btree ("currency_id");

CREATE INDEX "idx_17472_language_main" ON "countries" USING btree ("language_main");

CREATE INDEX "idx_17472_main_tz" ON "countries" USING btree ("main_tz");

COMMENT ON TABLE "countries" IS 'Countries';



DROP TABLE IF EXISTS "languages";
CREATE TABLE "languages" (
    "id" character(3) NOT NULL,
    "main_name" character varying(150) NOT NULL,
    "sub_name" character varying(150) NOT NULL,
    "native_name" character varying(150) NOT NULL,
    "language_type" character varying(50) NOT NULL,
    "parent_language_id" character(3),
    "main_country_id" character(2),
    "speakers_mil" double precision,
    "speakers_native" bigint,
    "speakers_native_total" bigint,
    "iso639_2b" character(3),
    "iso639_2t" character(3),
    "iso639_1" character(2),
    "rtl" boolean,
    "comment" character varying(150),
    CONSTRAINT "idx_17520_primary" PRIMARY KEY ("id"),
    CONSTRAINT "languages_main_country_id_fkey" FOREIGN KEY (main_country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE,
    CONSTRAINT "languages_parent_language_id_fkey" FOREIGN KEY (parent_language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17520_country_main" ON "languages" USING btree ("main_country_id");

CREATE INDEX "idx_17520_parent_language" ON "languages" USING btree ("parent_language_id");

CREATE INDEX "languages_main_name" ON "languages" USING btree ("main_name");

CREATE INDEX "languages_native_name" ON "languages" USING btree ("native_name");

CREATE INDEX "languages_sub_name" ON "languages" USING btree ("sub_name");

COMMENT ON TABLE "languages" IS 'Languages';


DROP TABLE IF EXISTS "continents";
CREATE TABLE "continents" (
    "id" character(2) DEFAULT '' NOT NULL,
    CONSTRAINT "idx_17457_primary" PRIMARY KEY ("id")
) WITH (oids = false);

COMMENT ON TABLE "continents" IS 'Continents';




DROP TABLE IF EXISTS "timezones";
CREATE TABLE "timezones" (
    "id" character varying(50) DEFAULT '' NOT NULL,
    "utc_offset" character varying(10),
    "utc_offset_dst" character varying(14),
    "alias_of_tz" character varying(50),
    "lat" character varying(8),
    "long" character varying(8),
    "region" character varying(100),
    "continent_id" character(2),
    "country_id" character(2),
    "location" character varying(40),
    "notes" character varying(250),
    "supported" boolean,
    CONSTRAINT "idx_17558_primary" PRIMARY KEY ("id"),
    CONSTRAINT "timezones_continent_id_fkey" FOREIGN KEY (continent_id) REFERENCES continents(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE,
    CONSTRAINT "timezones_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17558_alias_of_tz" ON "timezones" USING btree ("alias_of_tz");

CREATE INDEX "idx_17558_continent_id" ON "timezones" USING btree ("continent_id");

CREATE INDEX "idx_17558_country_id" ON "timezones" USING btree ("country_id");

COMMENT ON TABLE "timezones" IS 'Timezones';



DROP TABLE IF EXISTS "currencies";
CREATE TABLE "currencies" (
    "id" character varying(3) NOT NULL,
    "currency_name" character varying(150),
    "currency_symbol" character varying(5),
    "subdivision" bigint,
    "subdivision_name" character varying(150),
    CONSTRAINT "idx_17509_primary" PRIMARY KEY ("id")
) WITH (oids = false);

COMMENT ON TABLE "currencies" IS 'Currencies';



DROP TABLE IF EXISTS "continent_names";
CREATE TABLE "continent_names" (
    "continent_id" character(2),
    "continent_name" character varying(20),
    "locale" character(3) DEFAULT 'eng',
    CONSTRAINT "idx_17466_continent_code_language_id" UNIQUE ("continent_id", "locale"),
    CONSTRAINT "continent_names_continent_id_fkey" FOREIGN KEY (continent_id) REFERENCES continents(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "continent_names_locale_fkey" FOREIGN KEY (locale) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17466_locale" ON "continent_names" USING btree ("locale");

COMMENT ON TABLE "continent_names" IS 'Continents - Names';


DROP TABLE IF EXISTS "continents_countries";
CREATE TABLE "continents_countries" (
    "continent_id" character(2),
    "country_id" character(2),
    CONSTRAINT "idx_17461_continent_code_country_id" UNIQUE ("continent_id", "country_id"),
    CONSTRAINT "continents_countries_continent_id_fkey" FOREIGN KEY (continent_id) REFERENCES continents(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "continents_countries_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17461_country_id" ON "continents_countries" USING btree ("country_id");

COMMENT ON TABLE "continents_countries" IS 'Continents - Countries';




DROP TABLE IF EXISTS "country_areas";
CREATE TABLE "country_areas" (
    "id" character varying(7) DEFAULT '' NOT NULL,
    "country_id" character(2),
    "country_name" character varying(44),
    "area_name" character varying(78),
    "level" character varying(40),
    "alt_names" character varying(186),
    "subdivision_cdh_id" integer,
    "country_cdh_id" integer,
    "country_id_3letter" character varying(3),
    CONSTRAINT "idx_17493_primary" PRIMARY KEY ("id"),
    CONSTRAINT "country_areas_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17493_country_id" ON "country_areas" USING btree ("country_id");

CREATE INDEX "idx_17493_country_id_3letter" ON "country_areas" USING btree ("country_id_3letter");

COMMENT ON TABLE "country_areas" IS 'Countries - Areas';


DROP TABLE IF EXISTS "country_names";
CREATE TABLE "country_names" (
    "country_id" character(2) DEFAULT '',
    "name_alt" character varying(250),
    "locale" character varying(3) DEFAULT '',
    CONSTRAINT "idx_17503_primary" UNIQUE ("country_id", "locale"),
    CONSTRAINT "country_names_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "country_names_locale_fkey" FOREIGN KEY (locale) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "country_names_country_id" ON "country_names" USING btree ("country_id");

CREATE INDEX "country_names_name_alt" ON "country_names" USING btree ("name_alt");

CREATE INDEX "idx_17503_locale" ON "country_names" USING btree ("locale");



DROP TABLE IF EXISTS "currencies_countries";
CREATE TABLE "currencies_countries" (
    "currency_id" character varying(3),
    "country_id" character(2),
    CONSTRAINT "idx_17515_currency_id" UNIQUE ("currency_id", "country_id"),
    CONSTRAINT "currencies_countries_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "currencies_countries_currency_id_fkey" FOREIGN KEY (currency_id) REFERENCES currencies(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17515_country_id" ON "currencies_countries" USING btree ("country_id");

COMMENT ON TABLE "currencies_countries" IS 'Currencies - Countries';


DROP TABLE IF EXISTS "language_accents";
DROP SEQUENCE IF EXISTS language_accents_id_seq;
CREATE SEQUENCE language_accents_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;

CREATE TABLE "language_accents" (
    "id" bigint DEFAULT nextval('language_accents_id_seq') NOT NULL,
    "accent_name" character varying(255),
    "language_id" character varying(3),
    "valid" boolean,
    "added_by" character varying(100),
    "num_users" bigint,
    CONSTRAINT "idx_17537_la" UNIQUE ("accent_name", "language_id"),
    CONSTRAINT "idx_17537_primary" PRIMARY KEY ("id"),
    CONSTRAINT "language_accents_language_id_fkey" FOREIGN KEY (language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17537_language_id" ON "language_accents" USING btree ("language_id");

COMMENT ON TABLE "language_accents" IS 'Languages - Accents';


DROP TABLE IF EXISTS "language_dialects";
DROP SEQUENCE IF EXISTS language_dialects_id_seq;
CREATE SEQUENCE language_dialects_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;

CREATE TABLE "language_dialects" (
    "id" bigint DEFAULT nextval('language_dialects_id_seq') NOT NULL,
    "language_id" character(3),
    "dialect_name" character varying(75) NOT NULL,
    "main" boolean,
    "pejorative" boolean,
    "valid" boolean,
    "added_by" character varying(100),
    "num_users" bigint,
    CONSTRAINT "idx_17546_ld" UNIQUE ("language_id", "dialect_name"),
    CONSTRAINT "idx_17546_primary" PRIMARY KEY ("id"),
    CONSTRAINT "language_dialects_language_id_fkey" FOREIGN KEY (language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17546_name_alt" ON "language_dialects" USING btree ("dialect_name");

COMMENT ON TABLE "language_dialects" IS 'Languages - Dialects';


DROP TABLE IF EXISTS "language_names";
CREATE TABLE "language_names" (
    "language_id" character varying(3) NOT NULL,
    "name_alt" character varying(75) NOT NULL,
    "main" boolean DEFAULT false NOT NULL,
    "pejorative" boolean DEFAULT false NOT NULL,
    "locale" character(3),
    CONSTRAINT "idx_17552_ln" UNIQUE ("language_id", "name_alt"),
    CONSTRAINT "language_names_language_id_fkey" FOREIGN KEY (language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "language_names_locale_fkey" FOREIGN KEY (locale) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17552_locale" ON "language_names" USING btree ("locale");

CREATE INDEX "idx_17552_name_alt" ON "language_names" USING btree ("name_alt");

COMMENT ON TABLE "language_names" IS 'Languages - Names';


DROP TABLE IF EXISTS "languages_countries";
CREATE TABLE "languages_countries" (
    "language_id" character(3) NOT NULL,
    "country_id" character(2) NOT NULL,
    "speakers_native" bigint,
    CONSTRAINT "idx_17532_language_country" UNIQUE ("language_id", "country_id"),
    CONSTRAINT "languages_countries_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "languages_countries_language_id_fkey" FOREIGN KEY (language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17532_country_id" ON "languages_countries" USING btree ("country_id");

COMMENT ON TABLE "languages_countries" IS 'Languages - Countries';



DROP TABLE IF EXISTS "countries_dialects";
CREATE TABLE "countries_dialects" (
    "country_id" character(2) NOT NULL,
    "language_id" character(3) NOT NULL,
    "dialect_id" bigint NOT NULL,
    "priority" integer,
    CONSTRAINT "idx_17490_country_id_dialect_id" UNIQUE ("country_id", "dialect_id"),
    CONSTRAINT "countries_dialects_country_id_fkey" FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "countries_dialects_dialect_id_fkey" FOREIGN KEY (dialect_id) REFERENCES language_dialects(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "countries_dialects_language_id_fkey" FOREIGN KEY (language_id) REFERENCES languages(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "idx_17490_dialect_id" ON "countries_dialects" USING btree ("dialect_id");

CREATE INDEX "idx_17490_language_id" ON "countries_dialects" USING btree ("language_id");

COMMENT ON TABLE "countries_dialects" IS 'Countries - Dialects';
