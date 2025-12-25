--logicalFilePath:xxl-job-v1.0.0.sql

--changeset xuxueli:1
--comment: Create job group and registry tables
CREATE TABLE xxl_job_group (
                               id           SERIAL       NOT NULL,
                               app_name     varchar(64)  NOT NULL,
                               title        varchar(12)  NOT NULL,
                               address_type smallint     NOT NULL DEFAULT 0,
                               address_list text,
                               update_time  timestamp    DEFAULT NULL,
                               CONSTRAINT pk_xxl_job_group PRIMARY KEY (id)
);

CREATE TABLE xxl_job_registry (
                                  id             SERIAL       NOT NULL,
                                  registry_group varchar(50)  NOT NULL,
                                  registry_key   varchar(255) NOT NULL,
                                  registry_value varchar(255) NOT NULL,
                                  update_time    timestamp    DEFAULT NULL,
                                  CONSTRAINT pk_xxl_job_registry PRIMARY KEY (id),
                                  CONSTRAINT i_g_k_v UNIQUE (registry_group, registry_key, registry_value)
);

--changeset xuxueli:2
--comment: Create job info and logglue tables
CREATE TABLE xxl_job_info (
                              id                        SERIAL       NOT NULL,
                              job_group                 int          NOT NULL,
                              job_desc                  varchar(255) NOT NULL,
                              add_time                  timestamp    DEFAULT NULL,
                              update_time               timestamp    DEFAULT NULL,
                              author                    varchar(64)  DEFAULT NULL,
                              alarm_email               varchar(255) DEFAULT NULL,
                              schedule_type             varchar(50)  NOT NULL DEFAULT 'NONE',
                              schedule_conf             varchar(128) DEFAULT NULL,
                              misfire_strategy          varchar(50)  NOT NULL DEFAULT 'DO_NOTHING',
                              executor_route_strategy   varchar(50)  DEFAULT NULL,
                              executor_handler          varchar(255) DEFAULT NULL,
                              executor_param            varchar(512) DEFAULT NULL,
                              executor_block_strategy   varchar(50)  DEFAULT NULL,
                              executor_timeout          int          NOT NULL DEFAULT 0,
                              executor_fail_retry_count int          NOT NULL DEFAULT 0,
                              glue_type                 varchar(50)  NOT NULL,
                              glue_source               text,
                              glue_remark               varchar(128) DEFAULT NULL,
                              glue_updatetime           timestamp    DEFAULT NULL,
                              child_jobid               varchar(255) DEFAULT NULL,
                              trigger_status            smallint     NOT NULL DEFAULT 0,
                              trigger_last_time         bigint       NOT NULL DEFAULT 0,
                              trigger_next_time         bigint       NOT NULL DEFAULT 0,
                              CONSTRAINT pk_xxl_job_info PRIMARY KEY (id)
);

--changeset xuxueli:3
--comment: Create job log and report tables
CREATE TABLE xxl_job_log (
                             id                        bigserial    NOT NULL,
                             job_group                 int          NOT NULL,
                             job_id                    int          NOT NULL,
                             executor_address          varchar(255) DEFAULT NULL,
                             executor_handler          varchar(255) DEFAULT NULL,
                             executor_param            varchar(512) DEFAULT NULL,
                             executor_sharding_param   varchar(20)  DEFAULT NULL,
                             executor_fail_retry_count int          NOT NULL DEFAULT 0,
                             trigger_time              timestamp    DEFAULT NULL,
                             trigger_code              int          NOT NULL,
                             trigger_msg               text,
                             handle_time               timestamp    DEFAULT NULL,
                             handle_code               int          NOT NULL,
                             handle_msg                text,
                             alarm_status              smallint     NOT NULL DEFAULT 0,
                             CONSTRAINT pk_xxl_job_log PRIMARY KEY (id)
);

CREATE INDEX I_trigger_time ON xxl_job_log (trigger_time);
CREATE INDEX I_handle_code ON xxl_job_log (handle_code);
CREATE INDEX I_jobid_jobgroup ON xxl_job_log (job_id, job_group);

--changeset xuxueli:4
--comment: Create lock and user tables
CREATE TABLE xxl_job_lock (
                              lock_name varchar(50) NOT NULL,
                              CONSTRAINT pk_xxl_job_lock PRIMARY KEY (lock_name)
);

CREATE TABLE xxl_job_user (
                              id         SERIAL       NOT NULL,
                              username   varchar(50)  NOT NULL,
                              password   varchar(100) NOT NULL,
                              token      varchar(100) DEFAULT NULL,
                              role       smallint     NOT NULL,
                              permission varchar(255) DEFAULT NULL,
                              CONSTRAINT pk_xxl_job_user PRIMARY KEY (id),
                              CONSTRAINT i_username UNIQUE (username)
);

--changeset xuxueli:5
--comment: Insert default data
INSERT INTO xxl_job_group(app_name, title, address_type, update_time)
VALUES ('xxl-job-executor-sample', '通用执行器Sample', 0, CURRENT_TIMESTAMP);

INSERT INTO xxl_job_user(username, password, role)
VALUES ('admin', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1);

INSERT INTO xxl_job_lock (lock_name)
VALUES ('schedule_lock');

--changeset xuxueli:6
--comment: Create job log report table for PostgreSQL
CREATE TABLE xxl_job_log_report (
                                    id            SERIAL       NOT NULL,
                                    trigger_day   timestamp    DEFAULT NULL,
                                    running_count int          NOT NULL DEFAULT 0,
                                    suc_count     int          NOT NULL DEFAULT 0,
                                    fail_count    int          NOT NULL DEFAULT 0,
                                    update_time   timestamp    DEFAULT NULL,
                                    CONSTRAINT pk_xxl_job_log_report PRIMARY KEY (id),
                                    CONSTRAINT i_trigger_day UNIQUE (trigger_day)
);

--comment: Add index for performance
CREATE INDEX idx_report_trigger_day ON xxl_job_log_report(trigger_day);