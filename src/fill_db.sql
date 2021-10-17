INSERT INTO admin.lang (code, name, is_essential_flag) values
    ('de-DE', 'german', B'1'),
    ('es-ES', 'spanish', B'1'),
    ('en-GB', 'english', B'1'),
    ('pt-PT', 'portuguese', B'0'),
    ('pl-PL', 'polish', B'0');



INSERT INTO admin.role (name, can_view_analytics_flag) values
    ('admin', B'1'),
    ('developer', B'1'),
    ('linguist', B'0'),
    ('manager', B'1'),
    ('data manager', B'0');


INSERT INTO admin.user (role_id, name, surname) values
    (2, 'jakub', 'korczakowski'),
    (1, 'jan', 'korczakowski'),
    (3, 'maciej', 'ciepelko'),
    (3, 'kacper', 'branicki'),
    (3, 'rafał', 'korsarz');

INSERT INTO admin.user_lang (user_id, lang_id, proficiency_level) values
    (1, 2, 3),
    (1, 3, 1),
    (3, 1, 3),
    (3, 2, 1),
    (4, 4, 3),
    (4, 2, 3),
    (5, 5, 3);


INSERT INTO analytics.work_time (user_id, start_time, finish_time) values
    (1, '2021-10-08 04:05:07', '2021-10-08 05:05:07'),
    (1, '2021-10-09 04:05:07', '2021-10-09 04:56:07'),
    (1, '2021-10-09 10:20:05', '2021-10-09 12:20:05'),
    (2, '2021-10-10 12:45:56', '2021-10-10 14:45:56'),
    (3, '2021-10-09 08:13:03', Null),
    (2, '2021-10-08 09:56:05', '2021-10-08 10:15:05'),
    (5, '2021-10-08 15:44:57', Null);


INSERT INTO core.domain (name) values
    ('GENERAL'),
    ('GREETING'),
    ('APP'),
    ('PHONE');

INSERT INTO core.corpus (domain_id, lang_id, name, major_version, minor_version, bugfix_version, created_at) values
    (1, 2, 'mozilla-voice-general-corpora-en-gb', 1, 3, 34, '2021-01-20'),
    (1, 2, 'voice-institute-am34-corpora-en-gb', 21, 4, 0, '2021-08-21'),
    (3, 4, 'twitter-dev-corpora-pt-pt', 123, 6, 1, '2021-05-06'),
    (3, 1, 'twitter-dev-corpora-de-de', 125, 6, 1, '2021-05-06'),
    (2, 1, 'android-wakeup-corpora-de-de', 125, 6, 1, '2020-11-12');

INSERT INTO core.row (reference, speaker_age) values
    ('quick brown fox jumps over the lazy dog', 40),
    ('slow white fox jumps over the crazy dog', 40),
    ('lion is a king of the animal kingdom', 40),
    ('Es freut mich, dich kennenzulernen.', 23),
    ('Wie geht''s?', 23),
    ('Ich möchte ein Bier.', 40),
    ('Guten Morgen. ', 16),
    ('Guten Tag.', 56),
    ('Elas comem batatas. ', 22),
    ('Eu saí do parque.', 23);

INSERT INTO core.corpus_row (corpus_id, row_id) values
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (3, 5),
    (3, 6),
    (5, 7),
    (5, 8),
    (4, 9),
    (4, 10);

INSERT INTO core.product (name) values
    ('voice assistant'),
    ('lite voice assistant'),
    ('twitter app'),
    ('android system');

INSERT INTO core.model_type (type) values
    ('ASR'),
    ('ASR-lite'),
    ('MT'),
    ('TTS');

INSERT INTO core.model (product_id, type_id, name, major_version, minor_version, bugfix_version, created_at) values
    (1, 1, 'General ASR model', 1, 0, 12, '2021-01-20'),
    (1, 1, 'General ASR model', 2, 0, 12, '2021-11-20'),
    (1, 2, 'Lite ASR model', 1, 0, 52, '2021-01-20'),
    (1, 2, 'Lite ASR model', 4, 0, 67, '2021-09-24');

INSERT INTO core.component (name, details) values
    ('fixer', '{"input": "standard"}'::json),
    ('normalizer', '{"input": "standard"}'::json),
    ('acoustic model', '{"input": "standard"}'::json),
    ('neural net', '{"input": "normalized"}'::json);

INSERT INTO core.model_component (model_id, component_id, order_number) values
    (1, 1, 4),
    (1, 2, 2),
    (1, 3, 1),
    (1, 4, 3);

INSERT INTO core.evaluation (model_id, user_id, report, is_completed_flag) values
    (1, 1, 'Model seems to do a bad job regarding number handling', B'1'),
    (1, 2, Null, B'0'),
    (1, 3, Null, B'0'),
    (1, 4, Null, B'0');


INSERT INTO core.hypothesis (row_id, model_component_id, text, score) values
    (1, 4, 'quick brown fox jump over that lazy dog', 0.90),
    (1, 1, 'quick brown fox jumps over the lazy dog', 1.0),
    (1, 2, 'quick brown fox jumper over that lazy dog', 0.80),
    (1, 3, 'quicker browner fox jump over that lazy dog', 0.70);

INSERT INTO core.comment (hypothesis_id, evaluation_id, comment) values
    (1, 1, 'Invalid jump word handling'),
    (2, 1, 'No errors'),
    (3, 1, 'Invalid jump word handling'),
    (4, 1, 'Invalid jump word handling');
