--
-- PostgreSQL database dump
--

-- Dumped from database version 14.0 (Debian 14.0-1.pgdg110+1)
-- Dumped by pg_dump version 14.0 (Debian 14.0-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO postgres;

--
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- Name: check_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        tmp integer;
    BEGIN
        IF NEW.start_time IS NULL THEN
            RAISE EXCEPTION 'start_time cannot be null';
        END IF;
        IF NEW.finish_time IS NOT NULL AND NEW.start_time > NEW.finish_time THEN
            RAISE EXCEPTION 'finish_time cannot be an earlier date than start_time';
        END IF;

        IF date_part('month', NEW.start_time) <> date_part('month', NEW.finish_time) THEN
            RAISE EXCEPTION 'finish_time and start_time cannot be in another month';
        END IF;

        SELECT 1 into tmp FROM analytics.work_time wt
            WHERE EXISTS(
                SELECT "overlaps"(wt.start_time, wt.finish_time, NEW.start_time, NEW.finish_time)
                    WHERE "overlaps"(wt.start_time, wt.finish_time, NEW.start_time, NEW.finish_time) = True
            );
        IF FOUND THEN
            RAISE EXCEPTION 'Given date overlaps existing date';
        END IF;

        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.check_date() OWNER TO postgres;

--
-- Name: count_salary(smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_salary(smallint) RETURNS money
    LANGUAGE sql
    AS $_$
    SELECT (get_working_time_in_given_month(u.id) * u.hourly_rate / 60)::money
        FROM admin.user u
        WHERE u.id = $1;
$_$;


ALTER FUNCTION public.count_salary(smallint) OWNER TO postgres;

--
-- Name: count_salary(integer, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_salary(integer, double precision) RETURNS money
    LANGUAGE sql
    AS $_$
    SELECT (get_working_time_in_given_month(u.id, $2) * u.hourly_rate / 60)::money
        FROM admin.user u
        WHERE u.id = $1;
$_$;


ALTER FUNCTION public.count_salary(integer, double precision) OWNER TO postgres;

--
-- Name: count_salary_2(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_salary_2(integer) RETURNS money
    LANGUAGE sql
    AS $_$
    SELECT get_working_time_in_given_month(u.id) * u.hourly_rate
        FROM admin.user u
        WHERE u.id = $1;
$_$;


ALTER FUNCTION public.count_salary_2(integer) OWNER TO postgres;

--
-- Name: count_salary_3(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_salary_3(integer) RETURNS money
    LANGUAGE sql
    AS $_$
    SELECT get_working_time_in_given_month(u.id) * u.hourly_rate / 60
        FROM admin.user u
        WHERE u.id = $1;
$_$;


ALTER FUNCTION public.count_salary_3(integer) OWNER TO postgres;

--
-- Name: get_monthly_salary(double precision); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.get_monthly_salary(IN month double precision)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        csv_data record;
BEGIN
        select count_salary(u.id, month) as salary,
               u.name || ' '::varchar || u.surname as user_name
                into csv_data
            from admin.user u;
    Copy (
        select * from csv_data
    ) To '/tmp/test.csv' With CSV DELIMITER ',' HEADER;
END;
$$;


ALTER PROCEDURE public.get_monthly_salary(IN month double precision) OWNER TO postgres;

--
-- Name: get_monthly_salary(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_monthly_salary(user_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    Copy (
        select count_salary(u.id, 10.0::double precision) as salary,
               u.name || ' '::varchar || u.surname as user_name
            from admin.user u
            where u.id = user_id
    ) To '/tmp/test.csv' With CSV DELIMITER ',' HEADER;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION public.get_monthly_salary(user_id integer) OWNER TO postgres;

--
-- Name: get_working_time_in_given_month(smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_working_time_in_given_month(smallint) RETURNS smallint
    LANGUAGE sql
    AS $_$
    WITH user_hours as (
        SELECT sum(a.finish_time - a.start_time) as working_hours, a.user_id
            FROM analytics.work_time a
            WHERE a.user_id = $1
            GROUP BY a.user_id
    )
    SELECT EXTRACT(EPOCH FROM uh.working_hours) / 60
        FROM user_hours uh
$_$;


ALTER FUNCTION public.get_working_time_in_given_month(smallint) OWNER TO postgres;

--
-- Name: get_working_time_in_given_month(integer, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_working_time_in_given_month(integer, double precision) RETURNS smallint
    LANGUAGE sql
    AS $_$
    WITH user_hours as (
        SELECT sum(a.finish_time - a.start_time) as working_time, a.user_id
            FROM analytics.work_time a
            WHERE a.user_id = $1
              AND date_part('month', a.start_time) = $2
              AND date_part('month', a.finish_time) = $2
            GROUP BY a.user_id
    )
    SELECT EXTRACT(EPOCH FROM uh.working_time) / 60
        FROM user_hours uh;
    $_$;


ALTER FUNCTION public.get_working_time_in_given_month(integer, double precision) OWNER TO postgres;

--
-- Name: insert_model(character varying, character varying, character varying, smallint, smallint, smallint, date); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_model(IN arg_product_name character varying, IN arg_model_type character varying, IN arg_name character varying, IN arg_major_version smallint, IN arg_minor_version smallint, IN arg_bugfix_version smallint, IN arg_created_at date)
    LANGUAGE plpgsql
    AS $$
DECLARE
    arg_product_id integer;
    arg_type_id integer;
BEGIN
    SELECT p.id INTO arg_product_id FROM core.product p WHERE p.name = arg_product_name;
    IF NOT FOUND THEN
        INSERT INTO core.product (name)
            VALUES (arg_product_name);
        SELECT p.id INTO arg_product_id FROM core.product p WHERE p.name = arg_product_name;
    END IF;
    SELECT t.id INTO arg_type_id FROM core.model_type t WHERE t.type = arg_model_type;
    IF NOT FOUND THEN
        INSERT INTO core.model_type (type)
            VALUES (arg_model_type);
        SELECT t.id INTO arg_type_id FROM core.model_type t WHERE t.type = arg_model_type;
    END IF;
    IF arg_created_at > current_date THEN
        ROLLBACK;
        RAISE EXCEPTION 'Given date % is from future', arg_created_at;
    END IF;
    INSERT INTO core.model (product_id, type_id, name, major_version, minor_version, bugfix_version, created_at)
        VALUES (arg_product_id, arg_type_id, arg_name, arg_major_version, arg_minor_version, arg_bugfix_version, arg_created_at);
END;
$$;


ALTER PROCEDURE public.insert_model(IN arg_product_name character varying, IN arg_model_type character varying, IN arg_name character varying, IN arg_major_version smallint, IN arg_minor_version smallint, IN arg_bugfix_version smallint, IN arg_created_at date) OWNER TO postgres;

--
-- Name: insert_user(character varying, character varying, character varying, money); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_user(IN arg_role_name character varying, IN arg_name character varying, IN arg_surname character varying, IN arg_hourly_rate money)
    LANGUAGE plpgsql
    AS $$
DECLARE
    arg_role_id integer;
BEGIN
    SELECT r.id INTO arg_role_id FROM admin.role r WHERE r.name = arg_role_name;
    IF NOT FOUND THEN
        INSERT INTO admin.role (name, can_view_analytics_flag)
            VALUES (arg_role_name, FALSE);
        SELECT r.id INTO arg_role_id FROM admin.role r WHERE r.name = arg_role_name;
    END IF;
    INSERT INTO admin."user" (role_id, name, surname, hourly_rate)
        VALUES (arg_role_id, arg_name, arg_surname, arg_hourly_rate);
END;
$$;


ALTER PROCEDURE public.insert_user(IN arg_role_name character varying, IN arg_name character varying, IN arg_surname character varying, IN arg_hourly_rate money) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: lang; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.lang (
    id integer NOT NULL,
    code character varying(5) NOT NULL,
    name character varying(20),
    is_essential_flag bit(1) NOT NULL
);


ALTER TABLE admin.lang OWNER TO postgres;

--
-- Name: lang_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.lang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.lang_id_seq OWNER TO postgres;

--
-- Name: lang_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.lang_id_seq OWNED BY admin.lang.id;


--
-- Name: role; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.role (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    can_view_analytics_flag bit(1) NOT NULL
);


ALTER TABLE admin.role OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.role_id_seq OWNED BY admin.role.id;


--
-- Name: user; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin."user" (
    id integer NOT NULL,
    role_id integer NOT NULL,
    name character varying(20),
    surname character varying(80) NOT NULL,
    hourly_rate money
);


ALTER TABLE admin."user" OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.user_id_seq OWNED BY admin."user".id;


--
-- Name: user_lang; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.user_lang (
    user_id integer NOT NULL,
    lang_id integer NOT NULL,
    proficiency_level smallint
);


ALTER TABLE admin.user_lang OWNER TO postgres;

--
-- Name: user_lang_lang_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.user_lang_lang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.user_lang_lang_id_seq OWNER TO postgres;

--
-- Name: user_lang_lang_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.user_lang_lang_id_seq OWNED BY admin.user_lang.lang_id;


--
-- Name: user_lang_user_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.user_lang_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.user_lang_user_id_seq OWNER TO postgres;

--
-- Name: user_lang_user_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.user_lang_user_id_seq OWNED BY admin.user_lang.user_id;


--
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admin.user_role_id_seq OWNER TO postgres;

--
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.user_role_id_seq OWNED BY admin."user".role_id;


--
-- Name: work_time; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.work_time (
    id integer NOT NULL,
    user_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    finish_time timestamp without time zone
);


ALTER TABLE analytics.work_time OWNER TO postgres;

--
-- Name: work_time_id_seq; Type: SEQUENCE; Schema: analytics; Owner: postgres
--

CREATE SEQUENCE analytics.work_time_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE analytics.work_time_id_seq OWNER TO postgres;

--
-- Name: work_time_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: postgres
--

ALTER SEQUENCE analytics.work_time_id_seq OWNED BY analytics.work_time.id;


--
-- Name: work_time_user_id_seq; Type: SEQUENCE; Schema: analytics; Owner: postgres
--

CREATE SEQUENCE analytics.work_time_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE analytics.work_time_user_id_seq OWNER TO postgres;

--
-- Name: work_time_user_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: postgres
--

ALTER SEQUENCE analytics.work_time_user_id_seq OWNED BY analytics.work_time.user_id;


--
-- Name: comment; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.comment (
    id integer NOT NULL,
    hypothesis_id integer,
    evaluation_id integer,
    comment character varying(200)
);


ALTER TABLE core.comment OWNER TO postgres;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.comment_id_seq OWNER TO postgres;

--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.comment_id_seq OWNED BY core.comment.id;


--
-- Name: component; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.component (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    details json
);


ALTER TABLE core.component OWNER TO postgres;

--
-- Name: component_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.component_id_seq OWNER TO postgres;

--
-- Name: component_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.component_id_seq OWNED BY core.component.id;


--
-- Name: corpus; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.corpus (
    id integer NOT NULL,
    domain_id integer NOT NULL,
    lang_id integer NOT NULL,
    name character varying(100),
    major_version smallint,
    minor_version smallint,
    bugfix_version smallint,
    created_at date
);


ALTER TABLE core.corpus OWNER TO postgres;

--
-- Name: corpus_domain_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.corpus_domain_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.corpus_domain_id_seq OWNER TO postgres;

--
-- Name: corpus_domain_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.corpus_domain_id_seq OWNED BY core.corpus.domain_id;


--
-- Name: corpus_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.corpus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.corpus_id_seq OWNER TO postgres;

--
-- Name: corpus_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.corpus_id_seq OWNED BY core.corpus.id;


--
-- Name: corpus_lang_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.corpus_lang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.corpus_lang_id_seq OWNER TO postgres;

--
-- Name: corpus_lang_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.corpus_lang_id_seq OWNED BY core.corpus.lang_id;


--
-- Name: corpus_row; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.corpus_row (
    corpus_id integer NOT NULL,
    row_id integer NOT NULL
);


ALTER TABLE core.corpus_row OWNER TO postgres;

--
-- Name: corpus_row_corpus_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.corpus_row_corpus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.corpus_row_corpus_id_seq OWNER TO postgres;

--
-- Name: corpus_row_corpus_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.corpus_row_corpus_id_seq OWNED BY core.corpus_row.corpus_id;


--
-- Name: corpus_row_row_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.corpus_row_row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.corpus_row_row_id_seq OWNER TO postgres;

--
-- Name: corpus_row_row_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.corpus_row_row_id_seq OWNED BY core.corpus_row.row_id;


--
-- Name: domain; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.domain (
    id integer NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE core.domain OWNER TO postgres;

--
-- Name: domain_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.domain_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.domain_id_seq OWNER TO postgres;

--
-- Name: domain_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.domain_id_seq OWNED BY core.domain.id;


--
-- Name: evaluation; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.evaluation (
    id integer NOT NULL,
    model_id integer NOT NULL,
    user_id integer NOT NULL,
    report character varying(500),
    is_completed_flag bit(1) NOT NULL
);


ALTER TABLE core.evaluation OWNER TO postgres;

--
-- Name: evaluation_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.evaluation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.evaluation_id_seq OWNER TO postgres;

--
-- Name: evaluation_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.evaluation_id_seq OWNED BY core.evaluation.id;


--
-- Name: evaluation_model_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.evaluation_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.evaluation_model_id_seq OWNER TO postgres;

--
-- Name: evaluation_model_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.evaluation_model_id_seq OWNED BY core.evaluation.model_id;


--
-- Name: evaluation_user_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.evaluation_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.evaluation_user_id_seq OWNER TO postgres;

--
-- Name: evaluation_user_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.evaluation_user_id_seq OWNED BY core.evaluation.user_id;


--
-- Name: hypothesis; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.hypothesis (
    id integer NOT NULL,
    row_id integer NOT NULL,
    model_component_id integer NOT NULL,
    text character varying(200) NOT NULL,
    score real NOT NULL
);


ALTER TABLE core.hypothesis OWNER TO postgres;

--
-- Name: hypothesis_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hypothesis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.hypothesis_id_seq OWNER TO postgres;

--
-- Name: hypothesis_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hypothesis_id_seq OWNED BY core.hypothesis.id;


--
-- Name: hypothesis_model_component_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hypothesis_model_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.hypothesis_model_component_id_seq OWNER TO postgres;

--
-- Name: hypothesis_model_component_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hypothesis_model_component_id_seq OWNED BY core.hypothesis.model_component_id;


--
-- Name: hypothesis_row_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hypothesis_row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.hypothesis_row_id_seq OWNER TO postgres;

--
-- Name: hypothesis_row_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hypothesis_row_id_seq OWNED BY core.hypothesis.row_id;


--
-- Name: model; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.model (
    id integer NOT NULL,
    product_id integer NOT NULL,
    type_id integer NOT NULL,
    name character varying(100) NOT NULL,
    major_version smallint NOT NULL,
    minor_version smallint NOT NULL,
    bugfix_version smallint NOT NULL,
    created_at date
);


ALTER TABLE core.model OWNER TO postgres;

--
-- Name: model_component; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.model_component (
    id integer NOT NULL,
    model_id integer NOT NULL,
    component_id integer NOT NULL,
    order_number smallint NOT NULL
);


ALTER TABLE core.model_component OWNER TO postgres;

--
-- Name: model_component_component_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_component_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_component_component_id_seq OWNER TO postgres;

--
-- Name: model_component_component_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_component_component_id_seq OWNED BY core.model_component.component_id;


--
-- Name: model_component_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_component_id_seq OWNER TO postgres;

--
-- Name: model_component_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_component_id_seq OWNED BY core.model_component.id;


--
-- Name: model_component_model_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_component_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_component_model_id_seq OWNER TO postgres;

--
-- Name: model_component_model_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_component_model_id_seq OWNED BY core.model_component.model_id;


--
-- Name: model_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_id_seq OWNER TO postgres;

--
-- Name: model_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_id_seq OWNED BY core.model.id;


--
-- Name: model_product_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_product_id_seq OWNER TO postgres;

--
-- Name: model_product_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_product_id_seq OWNED BY core.model.product_id;


--
-- Name: model_type; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.model_type (
    id integer NOT NULL,
    type character varying(30) NOT NULL
);


ALTER TABLE core.model_type OWNER TO postgres;

--
-- Name: model_type_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_type_id_seq OWNER TO postgres;

--
-- Name: model_type_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_type_id_seq OWNED BY core.model_type.id;


--
-- Name: model_type_id_seq1; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.model_type_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.model_type_id_seq1 OWNER TO postgres;

--
-- Name: model_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.model_type_id_seq1 OWNED BY core.model.type_id;


--
-- Name: product; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.product (
    id integer NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE core.product OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.product_id_seq OWNED BY core.product.id;


--
-- Name: row; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core."row" (
    id integer NOT NULL,
    reference character varying(200) NOT NULL,
    speaker_age smallint
);


ALTER TABLE core."row" OWNER TO postgres;

--
-- Name: row_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE core.row_id_seq OWNER TO postgres;

--
-- Name: row_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.row_id_seq OWNED BY core."row".id;


--
-- Name: corpus_rows; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.corpus_rows AS
 SELECT r.id,
    r.reference,
    h.text,
    h.score,
    cp.name AS corpus_name,
    mc.order_number,
    m.name AS model_name,
    c.id AS corpus_id,
    m.id AS model_id
   FROM ((((((core."row" r
     JOIN core.hypothesis h ON ((r.id = h.row_id)))
     JOIN core.corpus_row cr ON ((r.id = cr.row_id)))
     JOIN core.corpus c ON ((c.id = cr.corpus_id)))
     JOIN core.model_component mc ON ((mc.id = h.model_component_id)))
     JOIN core.component cp ON ((mc.component_id = cp.id)))
     JOIN core.model m ON ((m.id = mc.model_id)))
  ORDER BY r.id, mc.order_number;


ALTER TABLE public.corpus_rows OWNER TO postgres;

--
-- Name: model_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.model_performance AS
 SELECT avg(h.score) AS avg,
    mc.order_number,
    p.name AS product_name,
    p.id AS product_id
   FROM ((((core.hypothesis h
     JOIN core.model_component mc ON ((mc.id = h.model_component_id)))
     JOIN core.component c ON ((c.id = mc.component_id)))
     JOIN core.model m ON ((m.id = mc.model_id)))
     JOIN core.product p ON ((p.id = m.product_id)))
  GROUP BY mc.order_number, p.name, h.score, p.id
  ORDER BY p.name, mc.order_number;


ALTER TABLE public.model_performance OWNER TO postgres;

--
-- Name: lang id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.lang ALTER COLUMN id SET DEFAULT nextval('admin.lang_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.role ALTER COLUMN id SET DEFAULT nextval('admin.role_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin."user" ALTER COLUMN id SET DEFAULT nextval('admin.user_id_seq'::regclass);


--
-- Name: user role_id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin."user" ALTER COLUMN role_id SET DEFAULT nextval('admin.user_role_id_seq'::regclass);


--
-- Name: user_lang user_id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.user_lang ALTER COLUMN user_id SET DEFAULT nextval('admin.user_lang_user_id_seq'::regclass);


--
-- Name: user_lang lang_id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.user_lang ALTER COLUMN lang_id SET DEFAULT nextval('admin.user_lang_lang_id_seq'::regclass);


--
-- Name: work_time id; Type: DEFAULT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.work_time ALTER COLUMN id SET DEFAULT nextval('analytics.work_time_id_seq'::regclass);


--
-- Name: work_time user_id; Type: DEFAULT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.work_time ALTER COLUMN user_id SET DEFAULT nextval('analytics.work_time_user_id_seq'::regclass);


--
-- Name: comment id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comment ALTER COLUMN id SET DEFAULT nextval('core.comment_id_seq'::regclass);


--
-- Name: component id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.component ALTER COLUMN id SET DEFAULT nextval('core.component_id_seq'::regclass);


--
-- Name: corpus id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus ALTER COLUMN id SET DEFAULT nextval('core.corpus_id_seq'::regclass);


--
-- Name: corpus domain_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus ALTER COLUMN domain_id SET DEFAULT nextval('core.corpus_domain_id_seq'::regclass);


--
-- Name: corpus lang_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus ALTER COLUMN lang_id SET DEFAULT nextval('core.corpus_lang_id_seq'::regclass);


--
-- Name: corpus_row corpus_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus_row ALTER COLUMN corpus_id SET DEFAULT nextval('core.corpus_row_corpus_id_seq'::regclass);


--
-- Name: corpus_row row_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus_row ALTER COLUMN row_id SET DEFAULT nextval('core.corpus_row_row_id_seq'::regclass);


--
-- Name: domain id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.domain ALTER COLUMN id SET DEFAULT nextval('core.domain_id_seq'::regclass);


--
-- Name: evaluation id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation ALTER COLUMN id SET DEFAULT nextval('core.evaluation_id_seq'::regclass);


--
-- Name: evaluation model_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation ALTER COLUMN model_id SET DEFAULT nextval('core.evaluation_model_id_seq'::regclass);


--
-- Name: evaluation user_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation ALTER COLUMN user_id SET DEFAULT nextval('core.evaluation_user_id_seq'::regclass);


--
-- Name: hypothesis id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis ALTER COLUMN id SET DEFAULT nextval('core.hypothesis_id_seq'::regclass);


--
-- Name: hypothesis row_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis ALTER COLUMN row_id SET DEFAULT nextval('core.hypothesis_row_id_seq'::regclass);


--
-- Name: hypothesis model_component_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis ALTER COLUMN model_component_id SET DEFAULT nextval('core.hypothesis_model_component_id_seq'::regclass);


--
-- Name: model id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model ALTER COLUMN id SET DEFAULT nextval('core.model_id_seq'::regclass);


--
-- Name: model product_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model ALTER COLUMN product_id SET DEFAULT nextval('core.model_product_id_seq'::regclass);


--
-- Name: model type_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model ALTER COLUMN type_id SET DEFAULT nextval('core.model_type_id_seq1'::regclass);


--
-- Name: model_component id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component ALTER COLUMN id SET DEFAULT nextval('core.model_component_id_seq'::regclass);


--
-- Name: model_component model_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component ALTER COLUMN model_id SET DEFAULT nextval('core.model_component_model_id_seq'::regclass);


--
-- Name: model_component component_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component ALTER COLUMN component_id SET DEFAULT nextval('core.model_component_component_id_seq'::regclass);


--
-- Name: model_type id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_type ALTER COLUMN id SET DEFAULT nextval('core.model_type_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.product ALTER COLUMN id SET DEFAULT nextval('core.product_id_seq'::regclass);


--
-- Name: row id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core."row" ALTER COLUMN id SET DEFAULT nextval('core.row_id_seq'::regclass);


--
-- Data for Name: lang; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin.lang (id, code, name, is_essential_flag) FROM stdin;
1	de-DE	german	1
2	es-ES	spanish	1
3	en-GB	english	1
4	pt-PT	portuguese	0
5	pl-PL	polish	0
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin.role (id, name, can_view_analytics_flag) FROM stdin;
1	admin	1
2	developer	1
3	linguist	0
4	manager	1
5	data manager	0
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin."user" (id, role_id, name, surname, hourly_rate) FROM stdin;
1	2	jakub	korczakowski	$100.00
2	1	jan	korczakowski	$50.00
3	3	maciej	ciepelko	$10.00
4	3	kacper	branicki	$25.00
5	3	rafał	korsarz	$45.00
6	1	mieszko	pierwszy	$12.00
7	1	mieszko	pierwszy	$12.00
8	1	nowy	użytkownik	$123.00
\.


--
-- Data for Name: user_lang; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin.user_lang (user_id, lang_id, proficiency_level) FROM stdin;
1	2	3
1	3	1
3	1	3
3	2	1
4	4	3
4	2	3
5	5	3
\.


--
-- Data for Name: work_time; Type: TABLE DATA; Schema: analytics; Owner: postgres
--

COPY analytics.work_time (id, user_id, start_time, finish_time) FROM stdin;
1	1	2021-10-08 04:05:07	2021-10-08 05:05:07
2	1	2021-10-09 04:05:07	2021-10-09 04:56:07
3	1	2021-10-09 10:20:05	2021-10-09 12:20:05
4	2	2021-10-10 12:45:56	2021-10-10 14:45:56
5	3	2021-10-09 08:13:03	\N
6	2	2021-10-08 09:56:05	2021-10-08 10:15:05
7	5	2021-10-08 15:44:57	\N
11	1	2021-10-11 04:05:07	2021-10-13 05:05:07
12	1	2021-10-11 04:05:07	2021-10-13 05:05:07
13	1	2021-10-11 04:05:07	2021-10-13 05:05:07
14	1	2021-10-11 04:05:07	2021-10-13 05:05:07
15	1	2021-10-15 04:05:07	2021-10-13 05:05:07
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.comment (id, hypothesis_id, evaluation_id, comment) FROM stdin;
1	1	1	Invalid jump word handling
2	2	1	No errors
3	3	1	Invalid jump word handling
4	4	1	Invalid jump word handling
\.


--
-- Data for Name: component; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.component (id, name, details) FROM stdin;
1	fixer	{"input": "standard"}
2	normalizer	{"input": "standard"}
3	acoustic model	{"input": "standard"}
4	neural net	{"input": "normalized"}
\.


--
-- Data for Name: corpus; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.corpus (id, domain_id, lang_id, name, major_version, minor_version, bugfix_version, created_at) FROM stdin;
1	1	2	mozilla-voice-general-corpora-en-gb	1	3	34	2021-01-20
2	1	2	voice-institute-am34-corpora-en-gb	21	4	0	2021-08-21
3	3	4	twitter-dev-corpora-pt-pt	123	6	1	2021-05-06
4	3	1	twitter-dev-corpora-de-de	125	6	1	2021-05-06
5	2	1	android-wakeup-corpora-de-de	125	6	1	2020-11-12
\.


--
-- Data for Name: corpus_row; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.corpus_row (corpus_id, row_id) FROM stdin;
1	1
1	2
2	3
3	4
3	5
3	6
5	7
5	8
4	9
4	10
\.


--
-- Data for Name: domain; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.domain (id, name) FROM stdin;
1	GENERAL
2	GREETING
3	APP
4	PHONE
\.


--
-- Data for Name: evaluation; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.evaluation (id, model_id, user_id, report, is_completed_flag) FROM stdin;
1	1	1	Model seems to do a bad job regarding number handling	1
2	1	2	\N	0
3	1	3	\N	0
4	1	4	\N	0
\.


--
-- Data for Name: hypothesis; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.hypothesis (id, row_id, model_component_id, text, score) FROM stdin;
1	1	4	quick brown fox jump over that lazy dog	0.9
2	1	1	quick brown fox jumps over the lazy dog	1
3	1	2	quick brown fox jumper over that lazy dog	0.8
4	1	3	quicker browner fox jump over that lazy dog	0.7
\.


--
-- Data for Name: model; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.model (id, product_id, type_id, name, major_version, minor_version, bugfix_version, created_at) FROM stdin;
1	1	1	General ASR model	1	0	12	2021-01-20
2	1	1	General ASR model	2	0	12	2021-11-20
3	1	2	Lite ASR model	1	0	52	2021-01-20
4	1	2	Lite ASR model	4	0	67	2021-09-24
5	5	1	General ASR model	1	2	12	2021-01-20
6	5	1	General ASR model	1	2	12	2021-01-20
7	5	1	General ASR model	1	2	12	2021-01-20
8	10	1	General ASR model - test	1	2	12	2021-01-20
\.


--
-- Data for Name: model_component; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.model_component (id, model_id, component_id, order_number) FROM stdin;
1	1	1	4
2	1	2	2
3	1	3	1
4	1	4	3
\.


--
-- Data for Name: model_type; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.model_type (id, type) FROM stdin;
1	ASR
2	ASR-lite
3	MT
4	TTS
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.product (id, name) FROM stdin;
1	voice assistant
2	lite voice assistant
3	twitter app
4	android system
5	my voice assistant
10	my voice assistant 3
\.


--
-- Data for Name: row; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core."row" (id, reference, speaker_age) FROM stdin;
1	quick brown fox jumps over the lazy dog	40
2	slow white fox jumps over the crazy dog	40
3	lion is a king of the animal kingdom	40
4	Es freut mich, dich kennenzulernen.	23
5	Wie geht's?	23
6	Ich möchte ein Bier.	40
7	Guten Morgen. 	16
8	Guten Tag.	56
9	Elas comem batatas. 	22
10	Eu saí do parque.	23
\.


--
-- Name: lang_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.lang_id_seq', 5, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.role_id_seq', 5, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.user_id_seq', 8, true);


--
-- Name: user_lang_lang_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.user_lang_lang_id_seq', 1, false);


--
-- Name: user_lang_user_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.user_lang_user_id_seq', 1, false);


--
-- Name: user_role_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.user_role_id_seq', 1, false);


--
-- Name: work_time_id_seq; Type: SEQUENCE SET; Schema: analytics; Owner: postgres
--

SELECT pg_catalog.setval('analytics.work_time_id_seq', 20, true);


--
-- Name: work_time_user_id_seq; Type: SEQUENCE SET; Schema: analytics; Owner: postgres
--

SELECT pg_catalog.setval('analytics.work_time_user_id_seq', 1, false);


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.comment_id_seq', 4, true);


--
-- Name: component_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.component_id_seq', 4, true);


--
-- Name: corpus_domain_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.corpus_domain_id_seq', 1, false);


--
-- Name: corpus_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.corpus_id_seq', 5, true);


--
-- Name: corpus_lang_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.corpus_lang_id_seq', 1, false);


--
-- Name: corpus_row_corpus_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.corpus_row_corpus_id_seq', 1, false);


--
-- Name: corpus_row_row_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.corpus_row_row_id_seq', 1, false);


--
-- Name: domain_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.domain_id_seq', 4, true);


--
-- Name: evaluation_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.evaluation_id_seq', 4, true);


--
-- Name: evaluation_model_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.evaluation_model_id_seq', 1, false);


--
-- Name: evaluation_user_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.evaluation_user_id_seq', 1, false);


--
-- Name: hypothesis_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hypothesis_id_seq', 4, true);


--
-- Name: hypothesis_model_component_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hypothesis_model_component_id_seq', 1, false);


--
-- Name: hypothesis_row_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hypothesis_row_id_seq', 1, false);


--
-- Name: model_component_component_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_component_component_id_seq', 1, false);


--
-- Name: model_component_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_component_id_seq', 4, true);


--
-- Name: model_component_model_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_component_model_id_seq', 1, false);


--
-- Name: model_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_id_seq', 8, true);


--
-- Name: model_product_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_product_id_seq', 1, false);


--
-- Name: model_type_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_type_id_seq', 4, true);


--
-- Name: model_type_id_seq1; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.model_type_id_seq1', 1, false);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.product_id_seq', 10, true);


--
-- Name: row_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.row_id_seq', 10, true);


--
-- Name: lang lang_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.lang
    ADD CONSTRAINT lang_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: user_lang user_lang_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.user_lang
    ADD CONSTRAINT user_lang_pkey PRIMARY KEY (user_id, lang_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: work_time work_time_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.work_time
    ADD CONSTRAINT work_time_pkey PRIMARY KEY (id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: component component_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.component
    ADD CONSTRAINT component_pkey PRIMARY KEY (id);


--
-- Name: corpus corpus_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus
    ADD CONSTRAINT corpus_pkey PRIMARY KEY (id);


--
-- Name: corpus_row corpus_row_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus_row
    ADD CONSTRAINT corpus_row_pkey PRIMARY KEY (corpus_id, row_id);


--
-- Name: domain domain_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.domain
    ADD CONSTRAINT domain_pkey PRIMARY KEY (id);


--
-- Name: evaluation evaluation_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation
    ADD CONSTRAINT evaluation_pkey PRIMARY KEY (id);


--
-- Name: hypothesis hypothesis_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis
    ADD CONSTRAINT hypothesis_pkey PRIMARY KEY (id);


--
-- Name: model_component model_component_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component
    ADD CONSTRAINT model_component_pkey PRIMARY KEY (id);


--
-- Name: model model_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model
    ADD CONSTRAINT model_pkey PRIMARY KEY (id);


--
-- Name: model_type model_type_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_type
    ADD CONSTRAINT model_type_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: row row_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core."row"
    ADD CONSTRAINT row_pkey PRIMARY KEY (id);


--
-- Name: lang_idx; Type: INDEX; Schema: admin; Owner: postgres
--

CREATE INDEX lang_idx ON admin.lang USING hash (code);


--
-- Name: name_surname_idx; Type: INDEX; Schema: admin; Owner: postgres
--

CREATE INDEX name_surname_idx ON admin."user" USING btree (name, surname);


--
-- Name: finish_time_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX finish_time_idx ON analytics.work_time USING btree (finish_time);


--
-- Name: start_time_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX start_time_idx ON analytics.work_time USING btree (start_time);


--
-- Name: comment_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX comment_idx ON core.comment USING btree (comment);


--
-- Name: component_name_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX component_name_idx ON core.component USING hash (name);


--
-- Name: corpus_created_at_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX corpus_created_at_idx ON core.corpus USING btree (created_at);


--
-- Name: corpus_name_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX corpus_name_idx ON core.corpus USING btree (name);


--
-- Name: corpus_versions_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX corpus_versions_idx ON core.corpus USING btree (major_version, minor_version, bugfix_version);


--
-- Name: domain_name_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX domain_name_idx ON core.domain USING hash (name);


--
-- Name: model_created_at_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX model_created_at_idx ON core.model USING btree (created_at);


--
-- Name: model_name_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX model_name_idx ON core.model USING btree (name);


--
-- Name: model_type_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX model_type_idx ON core.model_type USING hash (type);


--
-- Name: model_versions_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX model_versions_idx ON core.model USING btree (major_version, minor_version, bugfix_version);


--
-- Name: order_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX order_idx ON core.model_component USING btree (order_number);


--
-- Name: reference_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX reference_idx ON core."row" USING btree (reference);


--
-- Name: report_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX report_idx ON core.evaluation USING btree (report);


--
-- Name: score_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX score_idx ON core.hypothesis USING btree (score);


--
-- Name: text_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX text_idx ON core.hypothesis USING btree (text);


--
-- Name: work_time check_date; Type: TRIGGER; Schema: analytics; Owner: postgres
--

CREATE TRIGGER check_date BEFORE INSERT OR UPDATE ON analytics.work_time FOR EACH ROW EXECUTE FUNCTION public.check_date();


--
-- Name: user_lang user_lang_lang_id_fkey; Type: FK CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.user_lang
    ADD CONSTRAINT user_lang_lang_id_fkey FOREIGN KEY (lang_id) REFERENCES admin.lang(id);


--
-- Name: user_lang user_lang_user_id_fkey; Type: FK CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.user_lang
    ADD CONSTRAINT user_lang_user_id_fkey FOREIGN KEY (user_id) REFERENCES admin."user"(id);


--
-- Name: user user_role_id_fkey; Type: FK CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin."user"
    ADD CONSTRAINT user_role_id_fkey FOREIGN KEY (role_id) REFERENCES admin.role(id);


--
-- Name: work_time work_time_user_id_fkey; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.work_time
    ADD CONSTRAINT work_time_user_id_fkey FOREIGN KEY (user_id) REFERENCES admin."user"(id);


--
-- Name: comment comment_evaluation_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comment
    ADD CONSTRAINT comment_evaluation_id_fkey FOREIGN KEY (evaluation_id) REFERENCES core.evaluation(id);


--
-- Name: comment comment_hypothesis_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comment
    ADD CONSTRAINT comment_hypothesis_id_fkey FOREIGN KEY (hypothesis_id) REFERENCES core.hypothesis(id);


--
-- Name: corpus corpus_domain_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus
    ADD CONSTRAINT corpus_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES core.domain(id);


--
-- Name: corpus corpus_lang_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus
    ADD CONSTRAINT corpus_lang_id_fkey FOREIGN KEY (lang_id) REFERENCES admin.lang(id);


--
-- Name: corpus_row corpus_row_corpus_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus_row
    ADD CONSTRAINT corpus_row_corpus_id_fkey FOREIGN KEY (corpus_id) REFERENCES core.corpus(id);


--
-- Name: corpus_row corpus_row_row_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.corpus_row
    ADD CONSTRAINT corpus_row_row_id_fkey FOREIGN KEY (row_id) REFERENCES core."row"(id);


--
-- Name: evaluation evaluation_model_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation
    ADD CONSTRAINT evaluation_model_id_fkey FOREIGN KEY (model_id) REFERENCES core.model(id);


--
-- Name: evaluation evaluation_user_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.evaluation
    ADD CONSTRAINT evaluation_user_id_fkey FOREIGN KEY (user_id) REFERENCES admin."user"(id);


--
-- Name: hypothesis hypothesis_model_component_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis
    ADD CONSTRAINT hypothesis_model_component_id_fkey FOREIGN KEY (model_component_id) REFERENCES core.model_component(id);


--
-- Name: hypothesis hypothesis_row_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hypothesis
    ADD CONSTRAINT hypothesis_row_id_fkey FOREIGN KEY (row_id) REFERENCES core."row"(id);


--
-- Name: model_component model_component_component_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component
    ADD CONSTRAINT model_component_component_id_fkey FOREIGN KEY (component_id) REFERENCES core.component(id);


--
-- Name: model_component model_component_model_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model_component
    ADD CONSTRAINT model_component_model_id_fkey FOREIGN KEY (model_id) REFERENCES core.model(id);


--
-- Name: model model_product_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model
    ADD CONSTRAINT model_product_id_fkey FOREIGN KEY (product_id) REFERENCES core.product(id);


--
-- Name: model model_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.model
    ADD CONSTRAINT model_type_id_fkey FOREIGN KEY (type_id) REFERENCES core.model_type(id);


--
-- Name: SCHEMA core; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA core TO linguist;


--
-- PostgreSQL database dump complete
--

