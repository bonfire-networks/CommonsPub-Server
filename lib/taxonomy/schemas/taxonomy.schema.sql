CREATE TABLE IF NOT EXISTS "tags" (
    "id" integer NOT NULL,
    "label" character varying,
    "parent_id" integer,
    CONSTRAINT "tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX IF NOT EXISTS "tag_5e6faac5245d8" ON "tags" USING btree ("parent_id");


CREATE TABLE IF NOT EXISTS "tags_related" (
    "tag_id" integer,
    "related_tag_id" integer,
    CONSTRAINT "tags_related_related_tag_id_fkey" FOREIGN KEY (related_tag_id) REFERENCES tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "tags_related_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX IF NOT EXISTS "tags_related_5e6fac453a415" ON "tags_related" USING btree ("tag_id");

CREATE INDEX IF NOT EXISTS "tags_related_5e6fac4f713dc" ON "tags_related" USING btree ("related_tag_id");
