DROP DATABASE IF EXISTS clients_database;
DROP ROLE IF EXISTS manager;
DROP ROLE IF EXISTS worker;

CREATE DATABASE clients_database;

\c clients_database;

CREATE TABLE positions_classifier (
    position_code SMALLSERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL
);

CREATE TABLE priority_classifier (
    priority_code SMALLSERIAL PRIMARY KEY,
    priority_name VARCHAR(8) NOT NULL
);

CREATE TABLE tasks_type_classifier (
    task_type_code SMALLSERIAL PRIMARY KEY,
    task_type_name VARCHAR(100) NOT NULL
);

CREATE TABLE paper_format_classifier (
    paper_format_code SMALLSERIAL PRIMARY KEY,
    paper_format_name VARCHAR(3) NOT NULL
);

CREATE TABLE print_technology_classifier (
    print_technology_code SMALLSERIAL PRIMARY KEY,
    print_technology_name VARCHAR(13) NOT NULL
);

CREATE TABLE organizations (
    organization_number SERIAL NOT NULL PRIMARY KEY,
    organization_name VARCHAR(50) NOT NULL,
    organization_email VARCHAR(256) NOT NULL UNIQUE,
    organization_mail VARCHAR(100) NOT NULL,
    organization_city VARCHAR(50) NOT NULL,
    client_type SMALLINT NOT NULL CONSTRAINT check_client_type CHECK(client_type IN (0, 1))
);

CREATE TABLE contact_persons (
    person_number BIGSERIAL PRIMARY KEY NOT NULL,
    person_name VARCHAR(50) NOT NULL,
    person_mobile_number BIGINT NOT NULL UNIQUE,
    person_email VARCHAR(256) NOT NULL UNIQUE,
    person_mail VARCHAR(50),
    organization_number INTEGER NOT NULL REFERENCES organizations(organization_number)
);

CREATE TABLE contracts (
    contract_number SERIAL PRIMARY KEY,
    contract_details TEXT,
    organization_number INTEGER NOT NULL REFERENCES organizations(organization_number)
);

CREATE TABLE employees (
    employee_number SERIAL PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    employee_surname VARCHAR(50) NOT NULL,
    employee_login VARCHAR(50) NOT NULL UNIQUE,
    employee_mobile_number BIGINT NOT NULL UNIQUE,
    employee_email VARCHAR(256) NOT NULL UNIQUE,
    position_code SMALLINT NOT NULL REFERENCES positions_classifier(position_code)
);

CREATE TABLE tasks (
    task_number BIGSERIAL PRIMARY KEY,
    creation_date TIMESTAMP DEFAULT NOW(),
    planned_completion_date TIMESTAMP,
    actual_completion_date TIMESTAMP,
    task_status SMALLINT NOT NULL DEFAULT 0 CONSTRAINT status_check CHECK(task_status IN (0, 1)),
    task_details TEXT,
    priority_code SMALLINT NOT NULL REFERENCES priority_classifier(priority_code),
    task_type_code SMALLINT NOT NULL REFERENCES tasks_type_classifier(task_type_code),
    person_number BIGINT NOT NULL REFERENCES contact_persons(person_number),
    contract_number INTEGER REFERENCES contracts(contract_number),
    author_number INTEGER NOT NULL REFERENCES employees(employee_number),
    performer_number INTEGER REFERENCES employees(employee_number)
);

CREATE TABLE printers (
    printer_number BIGSERIAL PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    printer_name VARCHAR(50) NOT NULL,
    paper_weight SMALLINT NOT NULL,
    colors_number SMALLINT NOT NULL,
    resolution VARCHAR(10) NOT NULL,
    print_speed SMALLINT NOT NULL,
    cartridge_count SMALLINT NOT NULL,
    tray_capacity SMALLINT NOT NULL,
    paper_format_code SMALLINT NOT NULL REFERENCES paper_format_classifier(paper_format_code),
    print_technology_code SMALLINT NOT NULL REFERENCES print_technology_classifier(print_technology_code)
);

CREATE TABLE participating_printers (
    printer_number BIGINT NOT NULL REFERENCES printers(printer_number),
    task_number BIGINT NOT NULL REFERENCES tasks(task_number),
    amount INTEGER NOT NULL,
    PRIMARY KEY(printer_number, task_number)
);

INSERT INTO priority_classifier(priority_name)
VALUES ('Низкий'), ('Средний'), ('Высокий');

INSERT INTO paper_format_classifier (paper_format_name)
VALUES ('A0'), ('A1'), ('A2'), ('A3'), ('A4'), ('A5');

INSERT INTO print_technology_classifier(print_technology_name)
VALUES ('Лазерный'), ('Светодиодный'), ('Струйный');

INSERT INTO tasks_type_classifier (task_type_name)
VALUES 
    ('Телефонный звонок'),
    ('Визит'),
    ('Отправка электронного сообщения'),
    ('Проведение презентации'),
    ('Отправка оборудования'),
    ('Поставка'),
    ('Установка'),
    ('Гарантийный ремонт'),
    ('Послегарантийный ремонт');

INSERT INTO positions_classifier (position_name)
VALUES ('manager'), ('worker');

INSERT INTO organizations(organization_name, 
                          organization_email, organization_mail, 
                          organization_city, client_type)
VALUES ('Микрозаймы', 'micro@mail.ru', 
        'Ул. Стромынка, д. 20', 'Москва', 0);

INSERT INTO organizations(organization_name, 
                          organization_email, organization_mail, 
                          organization_city, client_type)
VALUES ('Спербанк', 'sper@mail.ru', 
        'Ул. Стромынка, д. 21', 'Москва', 0);

INSERT INTO contact_persons(person_name, person_mobile_number, 
                            person_email, person_mail, 
                            organization_number)
VALUES('Sofia', 88005553535, 
       'sofia@gmail.com', 'Пр. Вернадского, 78', 
        1);

INSERT INTO contact_persons(person_name, person_mobile_number, 
                            person_email, person_mail, 
                            organization_number)
VALUES('Alice', 88005553536, 
       'alice@gmail.com', 'Пр. Вернадского, 79', 
       2);

CREATE ROLE manager;
CREATE ROLE worker;

GRANT SELECT ON tasks, employees, 
                contact_persons, organizations, 
                contracts, tasks_type_classifier, 
                priority_classifier, positions_classifier, 
                print_technology_classifier, paper_format_classifier, 
                printers, participating_printers
                TO manager, worker;

GRANT INSERT(planned_completion_date, task_details, 
             priority_code, task_type_code, 
             person_number, contract_number, author_number) ON tasks TO worker; 

GRANT INSERT ON employees TO admin;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO worker;
GRANT INSERT ON tasks, contracts, contact_persons, organizations TO manager;

GRANT UPDATE(performer_number) ON tasks TO manager;
GRANT UPDATE(task_status, task_details, 
             actual_completion_date, planned_completion_date, 
             priority_code) ON tasks TO manager, worker;

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY all_select ON tasks 
FOR SELECT 
TO manager, worker 
USING (
    (SELECT employee_login 
     FROM employees 
     WHERE(employee_number = author_number)) = current_user OR 
    (SELECT employee_login 
     FROM employees 
     WHERE(employee_number = performer_number)) = current_user
);

CREATE POLICY managers_select ON tasks 
FOR SELECT 
TO manager 
USING (
    (SELECT position_name 
     FROM positions_classifier 
     WHERE(position_code = (SELECT position_code 
                            FROM employees 
                            WHERE(employee_number = author_number)))) = 'worker'
); 

CREATE POLICY author_update ON tasks 
FOR UPDATE 
TO manager, worker 
USING(true)
WITH CHECK(
    (SELECT employee_login 
     FROM employees 
     WHERE(employee_number = author_number)) = current_user
);

CREATE POLICY update_status ON tasks 
FOR UPDATE 
TO manager, worker 
USING(true)
WITH CHECK((task_status = 1) AND 
           ((SELECT employee_login 
             FROM employees 
             WHERE(employee_number = author_number)) = current_user OR 
            (SELECT employee_login
             FROM employees 
             WHERE(employee_number = performer_number)) = current_user)
);

CREATE POLICY update_worker_task_performer ON tasks 
FOR UPDATE 
TO manager
USING (true)
WITH CHECK(
    (performer_number IS NOT NULL) AND
    (SELECT position_name 
     FROM positions_classifier 
     WHERE(position_code = (SELECT position_code 
                            FROM employees 
                            WHERE(employee_number = author_number)))) = 'worker'
);

CREATE FUNCTION check_task_update_availability()
RETURNS trigger
AS $$
BEGIN
    IF (NEW.actual_completion_date IS NOT NULL) THEN
        RAISE EXCEPTION 'Can not update actual_completion_date by hand';
    ELSIF ((NEW.task_status = 1) AND 
           ((OLD.planned_completion_date != NEW.planned_completion_date) OR 
            (OLD.task_details != NEW.task_details) OR 
            (OLD.priority_code != NEW.priority_code))) THEN
        RAISE EXCEPTION 'Can not update other fields simultaneously with task_status';
    ELSIF (OLD.task_status = 0 AND NEW.task_status = 1) THEN
        NEW.actual_completion_date = NOW();
    ELSIF (OLD.task_status = 1) THEN
        RAISE EXCEPTION 'Can not update completed task';
    ELSIF (NEW.planned_completion_date < NOW() OR NEW.planned_completion_date < OLD.creation_date) THEN
        RAISE EXCEPTION 'Wrong value for planned_completion_date';
    END IF;
    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER task_update_checker
BEFORE UPDATE ON tasks 
FOR EACH ROW 
EXECUTE FUNCTION check_task_update_availability();

CREATE PROCEDURE create_user(name text, surname text, 
                            login text, password text, 
                            mobile_number BIGINT, email text, 
                            code SMALLINT) 
AS $$
DECLARE
    granted_role text;
BEGIN 
    IF (SELECT COUNT(*) FROM pg_roles WHERE rolname=login) THEN
        RAISE EXCEPTION 'Such user already exists';
    ELSE 
        EXECUTE format('INSERT INTO employees(employee_name, 
                                              employee_surname, 
                                              employee_login, 
                                              employee_mobile_number, 
                                              employee_email, 
                                              position_code)
                        VALUES (%L, %L, %L, %L, %L, %L);', name, surname, 
                                                      login, mobile_number, 
                                                      email, code);
        EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L;', 
                        login, password);
        granted_role := (SELECT position_name 
            FROM positions_classifier 
            WHERE position_code = code);
        EXECUTE format('GRANT %I TO %I;', granted_role, login);
        EXECUTE format('GRANT CONNECT ON DATABASE clients_database TO %I;', 
                       granted_role, login);
        COMMIT;
    END IF;
END; $$ 
LANGUAGE plpgsql;

CREATE FUNCTION delete_employee_role() RETURNS trigger
AS $$
BEGIN
    EXECUTE format('DROP ROLE %I;', OLD.employee_login);
    RETURN NULL;
END; $$ 
LANGUAGE plpgsql;

CREATE TRIGGER role_delete_trigger 
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION delete_employee_role();

INSERT INTO printers(manufacturer, 
                     printer_name, paper_weight, 
                     colors_number, resolution, 
                     print_speed, cartridge_count, 
                     tray_capacity, paper_format_code, 
                     print_technology_code) 
VALUES('HP', 'LaserJet Pro', 64, 
       2, '5760x1440', 15, 1, 100, 5, 1);

INSERT INTO printers(manufacturer, 
                     printer_name, paper_weight, 
                     colors_number, resolution, 
                     print_speed, cartridge_count, 
                     tray_capacity, paper_format_code, 
                     print_technology_code) 
VALUES('Pantum', 'P2500W', 64, 
       2, '1200x1200', 22, 1, 100, 5, 1);

INSERT INTO printers(manufacturer, 
                     printer_name, paper_weight, 
                     colors_number, resolution, 
                     print_speed, cartridge_count, 
                     tray_capacity, paper_format_code, 
                     print_technology_code) 
VALUES('EPSON', 'L805', 300, 
       6, '5760x1440', 15, 6, 120, 5, 3);

-- Индексы
CREATE INDEX task_performer_number_idx ON tasks(performer_number);
CREATE INDEX task_author_number_idx ON tasks(author_number);
CREATE INDEX contact_persons_name_idx ON contact_persons(person_name);
CREATE INDEX contact_persons_mobile_number_idx ON contact_persons(person_mobile_number);
CREATE INDEX contact_persons_email_idx ON contact_persons(person_email);
CREATE INDEX organization_name_idx ON organizations(organization_name);
CREATE INDEX organization_email_idx ON organizations(organization_email);
CREATE INDEX organization_city_idx ON organizations(organization_city);
CREATE INDEX employee_login_idx ON employees(employee_login);

CREATE FUNCTION save_tasks_to_csv(employee_number INTEGER, start_date DATE, end_date DATE, path TEXT) RETURNS void 
AS $$
DECLARE
    all_tasks_count INTEGER;
    tasks_in_time_count INTEGER;
    tasks_bad_time_count INTEGER; 
    tasks_bad_time_not_completed_count INTEGER;
    tasks_in_time_not_completed_count INTEGER; 
    statement TEXT;
BEGIN
    all_tasks_count := (SELECT COUNT(*) 
                        FROM tasks 
                        WHERE ((performer_number = employee_number)
        AND (creation_date >= start_date) 
        AND (creation_date <= end_date)));

    tasks_in_time_count := (SELECT COUNT(*) 
                            FROM tasks
                            WHERE ((performer_number = employee_number)
        AND (creation_date >= start_date) 
        AND (creation_date <= end_date) 
        AND (actual_completion_date <= planned_completion_date)));

    tasks_bad_time_count := (SELECT COUNT(*) 
                             FROM tasks 
                             WHERE ((performer_number = employee_number)
        AND (creation_date >= start_date) 
        AND (creation_date <= end_date) 
        AND (actual_completion_date > planned_completion_date)));

    tasks_bad_time_not_completed_count := (SELECT COUNT(*) 
                                           FROM tasks 
                                           WHERE ((performer_number = employee_number)
        AND (creation_date >= start_date) 
        AND (creation_date <= end_date) 
        AND (NOW() < planned_completion_date)
        AND (actual_completion_date IS NULL)));

    tasks_in_time_not_completed_count := (SELECT COUNT(*) 
                                          FROM tasks 
                                          WHERE ((performer_number = employee_number)
        AND (creation_date >= start_date) 
        AND (creation_date <= end_date) 
        AND (NOW() >= planned_completion_date) 
        AND (actual_completion_date IS NULL)));
    
    statement := format('COPY (SELECT %s AS all_tasks_count, 
                                      %s AS tasks_in_time_count, 
                                      %s AS tasks_bad_time_count, 
                                      %s AS tasks_bad_time_not_completed_count, 
                                      %s AS tasks_in_time_not_completed_count) 
                                      TO ''%s/tasks_info.csv'' CSV HEADER;', 
        all_tasks_count, tasks_in_time_count, 
        tasks_bad_time_count, tasks_bad_time_not_completed_count, 
        tasks_in_time_not_completed_count, path);
    EXECUTE statement;
END; $$
LANGUAGE plpgsql;

SELECT pg_reload_conf();
CREATE EXTENSION pg_cron;
SELECT cron.schedule('0 0 * * *', 
                     $$ DELETE FROM tasks 
                        WHERE actual_completion_date < (NOW() - INTERVAL '12 month');
                     $$);
SET password_encryption='scram-sha-256';

CREATE FUNCTION save_tasks_to_json(path TEXT) RETURNS void
AS $$
DECLARE 
 statement TEXT;
BEGIN
    statement := format('
        COPY (
            SELECT json_agg(task)::TEXT
            FROM (SELECT 
                    t.task_number,
                    t.creation_date,
                    t.actual_completion_date,
                    t.planned_completion_date,
                    t.task_status, 
                    t.task_details,
                    (SELECT priority_name 
                     FROM priority_classifier 
                     WHERE priority_code = t.priority_code)
                     AS priority_code,
                    (SELECT task_type_name 
                     FROM tasks_type_classifier 
                     WHERE task_type_code = t.task_type_code)
                     AS task_type,
                    t.person_number,
                    t.contract_number,
                    t.author_number,
                    t.performer_number
                  FROM tasks AS t) 
            AS task ) TO ''%s/tasks.json'';', path
        );
        EXECUTE statement;
    RETURN;
END; $$
LANGUAGE plpgsql;


