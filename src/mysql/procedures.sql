CREATE PROCEDURE insert_model(
    arg_product_name varchar(20),
    arg_model_type varchar(30),
    arg_name varchar(100),
    arg_major_version smallint,
    arg_minor_version smallint,
    arg_bugfix_version smallint,
    arg_created_at date
)
BEGIN
    DECLARE arg_product_id int;
    DECLARE arg_type_id int;

    START TRANSACTION;
    SELECT p.id INTO arg_product_id FROM ml_testing.product p WHERE p.name = arg_product_name;
    IF ISNULL(arg_product_id) THEN
        INSERT INTO ml_testing.product (name)
            VALUES (arg_product_name);
        COMMIT;
        SELECT p.id INTO arg_product_id FROM ml_testing.product p WHERE p.name = arg_product_name;
    END IF;

    SELECT t.id INTO arg_type_id FROM ml_testing.model_type t WHERE t.type = arg_model_type;
    IF ISNULL(arg_type_id) THEN
        INSERT INTO ml_testing.model_type (type)
            VALUES (arg_model_type);
        COMMIT;
        SELECT t.id INTO arg_type_id FROM ml_testing.model_type t WHERE t.type = arg_model_type;
    END IF;

    IF arg_created_at > current_date THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given date is from future';
    END IF;

    INSERT INTO ml_testing.model (product_id, type_id, name, major_version, minor_version, bugfix_version, created_at)
        VALUES (arg_product_id, arg_type_id, arg_name, arg_major_version, arg_minor_version, arg_bugfix_version, arg_created_at);
    COMMIT;
END;

# drop procedure insert_model;

CALL insert_model(
    'my voice assistant 3',
    'ASR',
    'General ASR model - test',
    1, 2, 12,
    '2021-01-21');

select * from ml_testing.model;

CREATE PROCEDURE insert_user(
    arg_role_name varchar(20),
    arg_name varchar(20),
    arg_surname varchar(80),
    arg_hourly_rate float
)
BEGIN
    DECLARE arg_role_id int;
    SELECT r.id INTO arg_role_id FROM ml_testing.role r WHERE r.name = arg_role_name;
    IF ISNULL(arg_role_id) THEN
        INSERT INTO ml_testing.role (name, can_view_analytics_flag)
            VALUES (arg_role_name, FALSE);
        COMMIT;
        SELECT r.id INTO arg_role_id FROM ml_testing.role r WHERE r.name = arg_role_name;
    END IF;
    INSERT INTO ml_testing.user (role_id, name, surname, hourly_rate)
        VALUES (arg_role_id, arg_name, arg_surname, arg_hourly_rate);
END;

CALL insert_user(
    'admin2',
    'nowy',
    'użytkownik',
    123.0
);

select * from ml_testing.user;