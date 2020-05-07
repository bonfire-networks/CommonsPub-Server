
DROP TABLE IF EXISTS "taxonomy_tags" CASCADE;
CREATE TABLE "taxonomy_tags" (
    "id" integer NOT NULL,
    "label" character varying,
    "parent_tag_id" integer,
    "description" text,
    CONSTRAINT "tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "tag_5e6faac5245d8" ON "taxonomy_tags" USING btree ("parent_tag_id");


DROP TABLE IF EXISTS "taxonomy_tags_related" CASCADE;
CREATE TABLE "taxonomy_tags_related" (
    "tag_id" integer,
    "related_tag_id" integer,
    CONSTRAINT "tags_related_related_tag_id_fkey" FOREIGN KEY (related_tag_id) REFERENCES taxonomy_tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "tags_related_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES taxonomy_tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "tags_related_5e6fac453a415" ON "taxonomy_tags_related" USING btree ("tag_id");

CREATE INDEX "tags_related_5e6fac4f713dc" ON "taxonomy_tags_related" USING btree ("related_tag_id");
