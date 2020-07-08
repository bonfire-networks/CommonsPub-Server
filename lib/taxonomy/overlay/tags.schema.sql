
DROP TABLE IF EXISTS "taxonomy_tag" CASCADE;
CREATE TABLE "taxonomy_tag" (
    "id" integer NOT NULL,
    "name" character varying,
    "parent_tag_id" integer,
    "summary" text,
    CONSTRAINT "tag_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "tag_parent" FOREIGN KEY (parent_tag_id) REFERENCES taxonomy_tag(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "taxonomy_tag_parent_tag_id_index" ON "taxonomy_tag" USING btree ("parent_tag_id");


DROP TABLE IF EXISTS "taxonomy_tag_related" CASCADE;
CREATE TABLE "taxonomy_tag_related" (
    "tag_id" integer,
    "related_tag_id" integer,
    CONSTRAINT "tags_related_related_tag_id_fkey" FOREIGN KEY (related_tag_id) REFERENCES taxonomy_tag(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "tags_related_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES taxonomy_tag(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);

CREATE INDEX "taxonomy_tag_related_tag_id_index" ON "taxonomy_tag_related" USING btree ("tag_id");

CREATE INDEX "taxonomy_tag_related_related_tag_id_index" ON "taxonomy_tag_related" USING btree ("related_tag_id");
