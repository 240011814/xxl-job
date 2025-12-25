--liquibase formatted sql

--changeset xuxueli:1
--comment: Create xxl_job_group
CREATE TABLE xxl_job_group (
                               id           SERIAL PRIMARY KEY,
                               app_name     varchar(64)  NOT NULL,
                               title        varchar(12)  NOT NULL,
                               address_type smallint     NOT NULL DEFAULT 0,
                               address_list text,
                               update_time  timestamp
);

--changeset xuxueli:2
--comment: Create xxl_job_registry
CREATE TABLE xxl_job_registry (
                                  id             SERIAL PRIMARY KEY,
                                  registry_group varchar(50)  NOT NULL,
                                  registry_key   varchar(255) NOT NULL,
                                  registry_value varchar(255) NOT NULL,
                                  update_time    timestamp,
                                  CONSTRAINT uk_xxl_job_registry UNIQUE (registry_group, registry_key, registry_value)
);

--changeset xuxueli:3
--comment: Create xxl_job_info
CREATE TABLE xxl_job_info (
                              id                        SERIAL PRIMARY KEY,
                              job_group                 int          NOT NULL,
                              job_desc                  varchar(255) NOT NULL,
                              add_time                  timestamp,
                              update_time               timestamp,
                              author                    varchar(64),
                              alarm_email               varchar(255),
                              schedule_type             varchar(50)  NOT NULL DEFAULT 'NONE',
                              schedule_conf             varchar(128),
                              misfire_strategy          varchar(50)  NOT NULL DEFAULT 'DO_NOTHING',
                              executor_route_strategy   varchar(50),
                              executor_handler          varchar(255),
                              executor_param            varchar(512),
                              executor_block_strategy   varchar(50),
                              executor_timeout          int          NOT NULL DEFAULT 0,
                              executor_fail_retry_count int          NOT NULL DEFAULT 0,
                              glue_type                 varchar(50)  NOT NULL,
                              glue_source               text,
                              glue_remark               varchar(128),
                              glue_updatetime           timestamp,
                              child_jobid               varchar(255),
                              trigger_status            smallint     NOT NULL DEFAULT 0,
                              trigger_last_time         bigint       NOT NULL DEFAULT 0,
                              trigger_next_time         bigint       NOT NULL DEFAULT 0
);

--changeset xuxueli:4
--comment: Create xxl_job_logglue
CREATE TABLE xxl_job_logglue (
                                 id          SERIAL PRIMARY KEY,
                                 job_id      int          NOT NULL,
                                 glue_type   varchar(50),
                                 glue_source text,
                                 glue_remark varchar(128) NOT NULL,
                                 add_time    timestamp,
                                 update_time timestamp
);

--changeset xuxueli:5
--comment: Create xxl_job_log
CREATE TABLE xxl_job_log (
                             id                        BIGSERIAL PRIMARY KEY,
                             job_group                 int          NOT NULL,
                             job_id                    int          NOT NULL,
                             executor_address          varchar(255),
                             executor_handler          varchar(255),
                             executor_param            varchar(512),
                             executor_sharding_param   varchar(20),
                             executor_fail_retry_count int          NOT NULL DEFAULT 0,
                             trigger_time              timestamp,
                             trigger_code              int          NOT NULL,
                             trigger_msg               text,
                             handle_time               timestamp,
                             handle_code               int          NOT NULL,
                             handle_msg                text,
                             alarm_status              smallint     NOT NULL DEFAULT 0
);

CREATE INDEX idx_xxl_job_log_trigger_time ON xxl_job_log(trigger_time);
CREATE INDEX idx_xxl_job_log_handle_code ON xxl_job_log(handle_code);
CREATE INDEX idx_xxl_job_log_jobid_group ON xxl_job_log(job_id, job_group);
CREATE INDEX idx_xxl_job_log_jobid ON xxl_job_log(job_id);

--changeset xuxueli:6
--comment: Create xxl_job_log_report
CREATE TABLE xxl_job_log_report (
                                    id            SERIAL PRIMARY KEY,
                                    trigger_day   timestamp,
                                    running_count int NOT NULL DEFAULT 0,
                                    suc_count     int NOT NULL DEFAULT 0,
                                    fail_count    int NOT NULL DEFAULT 0,
                                    update_time   timestamp,
                                    CONSTRAINT uk_xxl_job_log_report_day UNIQUE (trigger_day)
);

--changeset xuxueli:7
--comment: Create xxl_job_lock
CREATE TABLE xxl_job_lock (
                              lock_name varchar(50) PRIMARY KEY
);

--changeset xuxueli:8
--comment: Create xxl_job_user
CREATE TABLE xxl_job_user (
                              id         SERIAL PRIMARY KEY,
                              username   varchar(50)  NOT NULL,
                              password   varchar(100) NOT NULL,
                              token      varchar(100),
                              role       smallint     NOT NULL,
                              permission varchar(255),
                              CONSTRAINT uk_xxl_job_user_username UNIQUE (username)
);

--changeset xuxueli:9
--comment: Init default data
INSERT INTO xxl_job_group (id, app_name, title, address_type, update_time)
VALUES
    (1, 'xxl-job-executor-sample', '通用执行器Sample', 0, CURRENT_TIMESTAMP),
    (2, 'xxl-job-executor-sample-ai', 'AI执行器Sample', 0, CURRENT_TIMESTAMP);

INSERT INTO xxl_job_user (id, username, password, role)
VALUES
    (1, 'admin', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1);

INSERT INTO xxl_job_lock (lock_name)
VALUES ('schedule_lock');
