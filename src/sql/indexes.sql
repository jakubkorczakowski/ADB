CREATE INDEX name_surname_idx ON admin.user (name, surname);

CREATE INDEX start_time_idx ON analytics.work_time (start_time);
CREATE INDEX finish_time_idx ON analytics.work_time (finish_time);

CREATE INDEX report_idx ON core.evaluation (report);

CREATE INDEX lang_idx ON admin.lang USING hash (code);

CREATE INDEX comment_idx ON core.comment (comment);

CREATE INDEX text_idx ON core.hypothesis (text);
CREATE INDEX score_idx ON core.hypothesis (score);

CREATE INDEX order_idx ON core.model_component (order_number);

CREATE INDEX reference_idx ON core.row (reference);

CREATE INDEX component_name_idx ON core.component USING hash (name);

CREATE INDEX product_name_idx ON core.product USING hash (name);

CREATE INDEX model_type_idx ON core.model_type USING hash (type);

CREATE INDEX domain_name_idx ON core.domain USING hash (name);

CREATE INDEX model_name_idx ON core.model (name);
CREATE INDEX model_created_at_idx ON core.model (created_at);
CREATE INDEX model_versions_idx ON core.model (major_version, minor_version, bugfix_version);

CREATE INDEX corpus_name_idx ON core.corpus (name);
CREATE INDEX corpus_created_at_idx ON core.corpus (created_at);
CREATE INDEX corpus_versions_idx ON core.corpus (major_version, minor_version, bugfix_version);

select * from core.row r where r.reference like '%fox%';

select * from admin.lang l where l.code = 'de-DE';

select * from core.model m where m.major_version = 1 and m.minor_version = 2 and m.bugfix_version < 100;









