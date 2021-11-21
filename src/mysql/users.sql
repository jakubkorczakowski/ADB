CREATE USER ml_db_admin;

GRANT ALL PRIVILEGES ON * TO ml_db_admin;

CREATE USER linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.comment
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.product
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.domain
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.model
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.model_type
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.component
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.model_component
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.evaluation
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.corpus
    TO linguist;

GRANT SELECT, UPDATE, DELETE ON
    ml_testing.row
    TO linguist;