-- CREATE DATABASE ML_TESTING;



-- DROP SCHEMA CORE CASCADE;
-- DROP SCHEMA ADMIN CASCADE;
-- DROP SCHEMA ANALYTICS CASCADE;

CREATE SCHEMA CORE;

CREATE SCHEMA ADMIN;

CREATE SCHEMA ANALYTICS;

CREATE TABLE ADMIN.LANG (
    id serial primary key,
    code varchar(5) not null,
    name varchar(20),
    is_essential_flag bit not null
);

CREATE TABLE ADMIN.ROLE (
    id serial primary key,
    name varchar(20) not null,
    can_view_analytics_flag bit not null
);

CREATE TABLE ADMIN.USER (
    id serial primary key,
    role_id smallint references ADMIN.ROLE(id),
    name varchar(20),
    surname varchar(80) not null,
    hourly_rate money
);

CREATE TABLE ADMIN.USER_LANG (
    user_id smallint references ADMIN.USER(id),
    lang_id smallint references ADMIN.LANG(id),
    proficiency_level smallint,

    primary key (user_id, lang_id)
);

CREATE TABLE CORE.PRODUCT (
    id serial primary key,
    name varchar(20) not null
);

CREATE TABLE CORE.DOMAIN (
    id serial primary key,
    name varchar(20) not null
);

CREATE TABLE CORE.MODEL_TYPE (
    id serial primary key,
    type varchar(30) not null
);

CREATE TABLE CORE.MODEL (
    id serial primary key,
    product_id smallint references CORE.PRODUCT(id),
    type_id smallint references CORE.MODEL_TYPE(id),
    name varchar(100) not null,
    major_version smallint not null,
    minor_version smallint not null,
    bugfix_version smallint not null,
    created_at date
);

CREATE TABLE CORE.COMPONENT (
    id serial primary key,
    name varchar(100) not null,
    details json
);

CREATE TABLE CORE.MODEL_COMPONENT (
    id serial primary key,
    model_id smallint references CORE.MODEL(id),
    component_id smallint references CORE.COMPONENT(id),
    order_number smallint not null
);

CREATE TABLE CORE.EVALUATION (
    id serial primary key,
    model_id smallint references CORE.MODEL(id),
    user_id smallint references ADMIN.USER(id),
    report varchar(500),
    is_completed_flag bit not null
);

CREATE TABLE CORE.CORPUS (
    id serial primary key,
    domain_id smallint references CORE.DOMAIN(id),
    lang_id smallint references ADMIN.LANG(id),
    name varchar(100),
    major_version smallint,
    minor_version smallint,
    bugfix_version smallint,
    created_at date
);

CREATE TABLE CORE.ROW (
    id serial primary key,
    reference varchar(200) not null,
    speaker_age smallint
);

CREATE TABLE CORE.CORPUS_ROW (
    corpus_id smallint references CORE.CORPUS(id),
    row_id smallint references CORE.ROW(id),
    primary key (corpus_id, row_id)
);

CREATE TABLE CORE.HYPOTHESIS (
    id serial primary key,
    row_id smallint references CORE.ROW(id),
    model_component_id smallint references CORE.MODEL_COMPONENT(id),
    text varchar(200) not null,
    score real not null
);

CREATE TABLE CORE.COMMENT (
    id serial primary key,
    hypothesis_id smallint references core.hypothesis(id),
    evaluation_id smallint references core.evaluation(id),
    comment varchar(200)
);

CREATE TABLE ANALYTICS.WORK_TIME (
    id serial primary key,
    user_id smallint references ADMIN.USER(id),
    start_time timestamp not null,
    finish_time timestamp
);
--
-- CREATE USER ml_db_admin;
--
-- GRANT pg_read_all_data TO ml_db_admin;
-- GRANT pg_write_all_data TO ml_db_admin;
--
-- CREATE USER linguist;
--
-- GRANT USAGE ON SCHEMA core TO linguist;


