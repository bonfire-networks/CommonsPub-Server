
DROP TABLE IF EXISTS "taxonomy_tags" CASCADE;
CREATE TABLE "taxonomy_tags" (
    "id" integer NOT NULL,
    "label" character varying,
    "parent_tag_id" integer,
    "description" text,
    CONSTRAINT "tag_pkey" PRIMARY KEY ("id")
    CONSTRAINT "tag_parent" FOREIGN KEY (parent_tag_id) REFERENCES taxonomy_tags(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE,
) WITH (oids = false);

CREATE INDEX "taxonomy_tags_parent_tag_id_index" ON "taxonomy_tags" USING btree ("parent_tag_id");


DROP TABLE IF EXISTS "taxonomy_tags_related" CASCADE;
CREATE TABLE "taxonomy_tags_related" (
    "tag_id" integer,
    "related_tag_id" integer,
    CONSTRAINT "tags_related_related_tag_id_fkey" FOREIGN KEY (related_tag_id) REFERENCES taxonomy_tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "tags_related_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES taxonomy_tags(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "taxonomy_tags_related_tag_id_index" ON "taxonomy_tags_related" USING btree ("tag_id");

CREATE INDEX "taxonomy_tags_related_related_tag_id_index" ON "taxonomy_tags_related" USING btree ("related_tag_id");
