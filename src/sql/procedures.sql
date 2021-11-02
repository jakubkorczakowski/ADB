CREATE PROCEDURE insert_model(
    arg_product_name varchar(20),
    arg_model_type varchar(30),
    arg_name varchar(100),
    arg_major_version smallint,
    arg_minor_version smallint,
    arg_bugfix_version smallint,
    arg_created_at date
) AS $$
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
$$ LANGUAGE plpgsql;

CALL insert_model(
    'my voice assistant 3'::varchar,
    'ASR'::varchar,
    'General ASR model - test'::varchar,
    1::smallint, 2::smallint, 12::smallint,
    '2021-01-20'::date);

select * from core.model;

CREATE PROCEDURE insert_user(
    arg_role_name varchar(20),
    arg_name varchar(20),
    arg_surname varchar(80),
    arg_hourly_rate money
) AS $$
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
$$ LANGUAGE plpgsql;

CALL insert_user(
    'admin'::varchar,
    'nowy'::varchar,
    'użytkownik'::varchar,
    123.0::money
);

select * from admin."user";