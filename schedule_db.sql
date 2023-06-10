-- ###############            EDUCATION GROUPS                ############## --
/*
CREATE TABLE education_group
(
   ed_group_id NUMBER   NOT NULL,
       ed_info VARCHAR2(32),
   PRIMARY KEY (ed_group_Id)
);

   CREATE SEQUENCE ed_gr_seq
    START WITH 1
INCREMENT BY 1
    CACHE 100;

 CREATE OR REPLACE
TRIGGER ed_gr_ins_seq
        BEFORE INSERT
     ON education_group
    FOR EACH ROW
BEGIN
 SELECT ed_gr_seq.NEXTVAL
   INTO :new.ed_group_id
   FROM DUAL;
END;
*/

--INSERT INTO education_group(ed_info) VALUES('182');
--INSERT INTO education_group(ed_info) VALUES('364');
--INSERT INTO education_group(ed_info) VALUES('546');
-- ######################################################################### --

-- ###############            ROOMS                          ############### --
CREATE TABLE room
(
       room_id NUMBER NOT NULL,
     room_info VARCHAR2(32),
   PRIMARY KEY (room_Id)
);

     CREATE SEQUENCE room_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER room_ins_seq
        BEFORE INSERT
     ON room
    FOR EACH ROW
BEGIN
   SELECT room_seq.NEXTVAL
     INTO :new.room_Id
     FROM DUAL;
END;
-- ######################################################################### --
-- INSERT INTO room(room_info) VALUES('лабораторния №10');
-- INSERT INTO room(room_info) VALUES('лабораторния №12');
-- ###############            TEACHERS                       ############### --
/*
CREATE TABLE teacher
(
    teacher_id NUMBER NOT NULL,
  teacher_info VARCHAR2(32),
     person_id NUMBER NOT NULL,
   PRIMARY KEY (teacher_Id)
);

     CREATE SEQUENCE teacher_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER teacher_ins_seq
        BEFORE INSERT
     ON teacher
    FOR EACH ROW
BEGIN
   SELECT teacher_seq.NEXTVAL
     INTO :new.teacher_Id
     FROM DUAL;
END;
*/
--INSERT INTO teacher(teacher_info, person_id) VALUES('Семенов', 16);
--INSERT INTO teacher(teacher_info, person_id) VALUES('Петров', 13);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
     CREATE SEQUENCE GLOBAL_OFFICE_USR.teachers_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

     CREATE SEQUENCE GLOBAL_OFFICE_USR.teacherstatuses_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER GLOBAL_OFFICE_USR.teachers_ins_seq
        BEFORE INSERT
     ON GLOBAL_OFFICE_USR.teachers
    FOR EACH ROW
BEGIN
   SELECT GLOBAL_OFFICE_USR.teachers_seq.NEXTVAL
     INTO :new.teacher_Id
     FROM DUAL;
END;

 CREATE OR REPLACE
TRIGGER GLOBAL_OFFICE_USR.teacherstatuses_ins_seq
        BEFORE INSERT
     ON GLOBAL_OFFICE_USR.teacherstatuses
    FOR EACH ROW
BEGIN
   SELECT GLOBAL_OFFICE_USR.teacherstatuses_seq.NEXTVAL
     INTO :new.teacherstatus_id
     FROM DUAL;
END;

-- INSERT INTO GLOBAL_OFFICE_USR.teachers(teacher_fio, teacherstatus_id) VALUES('tsСеменов', 1);
-- INSERT INTO GLOBAL_OFFICE_USR.teachers(teacher_fio, teacherstatus_id) VALUES('tsПетров', 1);
-- INSERT INTO GLOBAL_OFFICE_USR.teacherstatuses(teacherstatus) VALUES('действующий');
-- SELECT * FROM GLOBAL_OFFICE_USR.teachers
-- SELECT * FROM GLOBAL_OFFICE_USR.teacherstatuses
-- SELECT * FROM teacher
-- SELECT * FROM GLOBAL_OFFICE_USR.subjects;
-- INSERT INTO GLOBAL_OFFICE_USR.subjects(subject) VALUES('tsАнатомия');
-- INSERT INTO GLOBAL_OFFICE_USR.subjects(subject) VALUES('tsБиология');
-- ######################################################################### --

-- ###############            TEACHER SCHEDULE              ################ --
CREATE TABLE ed_subgroup_type
(
   ed_subgroup_type VARCHAR2(32),
   PRIMARY KEY (ed_subgroup_type)
);

INSERT INTO ed_subgroup_type(ed_subgroup_type) VALUES ('Нет');
INSERT INTO ed_subgroup_type(ed_subgroup_type) VALUES('1 подгруппа');
INSERT INTO ed_subgroup_type(ed_subgroup_type) VALUES('2 подгруппа');

-----------------------------

CREATE TABLE teacher_schedule
(
   ts_id NUMBER NOT NULL,
   teacher_id NUMBER NOT NULL,
   room_id NUMBER NOT NULL,
   lesson_bdate TIMESTAMP NOT NULL,
   lesson_edate TIMESTAMP NOT NULL,
   ed_subject NUMBER NOT NULL,
   PRIMARY KEY (ts_id),
   CONSTRAINT fk_teacher
      FOREIGN KEY (teacher_id) REFERENCES GLOBAL_OFFICE_USR.teachers(teacher_id),
   CONSTRAINT fk_room
      FOREIGN KEY (room_id) REFERENCES room(room_id),
   CONSTRAINT fk_ed_subject
      FOREIGN KEY (ed_subject) REFERENCES GLOBAL_OFFICE_USR.subjects(subject_id)
);

CREATE UNIQUE INDEX tch_schedule_tch
    ON teacher_schedule(teacher_id, lesson_bdate, lesson_edate);
CREATE INDEX tch_schedule_room
    ON teacher_schedule(lesson_bdate, room_id);

     CREATE SEQUENCE teacher_sch_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER teacher_sch_ins_seq
        BEFORE INSERT
     ON teacher_schedule
    FOR EACH ROW
BEGIN
   SELECT teacher_sch_seq.NEXTVAL
     INTO :new.ts_Id
     FROM DUAL;
END;

---------------------------------------
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER tch_schdl_ins
        BEFORE INSERT OR UPDATE
     ON teacher_schedule
    FOR EACH ROW
DECLARE
   cnt INTEGER;
BEGIN
IF :new.lesson_edate < :new.lesson_bdate THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'Некорректное время начала и окончания занятия. Операция отменена.');
END IF;
SELECT COUNT(ts.teacher_id)
  INTO cnt -- количество строк соответствующих
           -- этому преподавателю
           -- и пересекающихся по времени
  FROM teacher_schedule ts
 WHERE ts.teacher_id = :new.teacher_id
   AND (
           (
           ts.lesson_bdate <= :new.lesson_bdate
       AND ts.lesson_edate >= :new.lesson_bdate
           )
        OR
           (
           ts.lesson_bdate <= :new.lesson_edate
       AND ts.lesson_edate >= :new.lesson_edate
           )
        OR
           (
           ts.lesson_bdate <= :new.lesson_bdate
       AND ts.lesson_edate >= :new.lesson_edate
           )
       );
IF cnt > 0 THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'обнаружено пересечение времени работы в расписании преподавателя. ' ||
      'Операция отменена.');
END IF;
END;
---------------------------------------

/*
INSERT INTO
   teacher_schedule(teacher_id, room_id, lesson_bdate,                    lesson_edate,                    ed_subject)
   VALUES          (2,          1,       TIMESTAMP '1998-05-31 10:46:00', TIMESTAMP '1998-05-31 12:16:00', 'Биология');
*/

-- ######################################################################### --

-- ################      EDUCATION GROUP SCHEDULE      ##################### --

CREATE TABLE ed_group_schedule
(
   egs_id NUMBER NOT NULL,
   ed_group_id NUMBER NOT NULL,
   ed_subgroup_type VARCHAR2(32),
   room_id NUMBER NOT NULL,
   lesson_bdate TIMESTAMP,
   lesson_edate TIMESTAMP,
   teacher_id NUMBER NOT NULL,
   ed_subject NUMBER NOT NULL,
   PRIMARY KEY (egs_id),
   CONSTRAINT fk_ed_group
      FOREIGN KEY (ed_group_id) REFERENCES GLOBAL_OFFICE_USR.studentgroups(studentGroup_Id),
   CONSTRAINT fk_ed_subgroup_type
      FOREIGN KEY (ed_subgroup_type) REFERENCES ed_subgroup_type(ed_subgroup_type),
   CONSTRAINT fk_ed_gr_sch_room
      FOREIGN KEY (room_id) REFERENCES room(room_id),
   CONSTRAINT fk_ed_gr_teacher
      FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id),
   CONSTRAINT fk_ed_gr_subjects
      FOREIGN KEY (ed_subject) REFERENCES GLOBAL_OFFICE_USR.subjects(subject_id)
);

CREATE UNIQUE INDEX ed_gr_schedule_eg
    ON ed_group_schedule(ed_group_id, lesson_bdate, lesson_edate, ed_subgroup_type);
CREATE INDEX ed_gr_schedule_room
    ON ed_group_schedule(lesson_bdate, room_id);
CREATE INDEX ed_gr_schedule_tch
    ON ed_group_schedule(teacher_id, lesson_bdate);


     CREATE SEQUENCE ed_gr_sch_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER ed_gr_sch_ins_seq
        BEFORE INSERT
     ON ed_group_schedule
    FOR EACH ROW
BEGIN
   SELECT ed_gr_sch_seq.NEXTVAL
     INTO :new.egs_Id
     FROM DUAL;
END;

-----------------------------------
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER ed_gr_schdl_ins
        BEFORE INSERT OR UPDATE
     ON ed_group_schedule
    FOR EACH ROW
DECLARE
   cnt INTEGER;
BEGIN
IF :new.lesson_edate < :new.lesson_bdate THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'Некорректное время начала и окончания занятия. Операция отменена.');
END IF;
SELECT COUNT(egs.ed_group_id)
  INTO cnt -- количество строк
           -- соответствующих этой группе или её подгруппе
           -- и пересекающихся по времени
  FROM ed_group_schedule egs
 WHERE egs.ed_group_id = :new.ed_group_id
   AND  (
        egs.ed_subgroup_type = 'Нет'
     OR egs.ed_subgroup_type = :new.ed_subgroup_type
        )
   AND (
           (
           egs.lesson_bdate <= :new.lesson_bdate
       AND egs.lesson_edate >= :new.lesson_bdate
           )
        OR
           (
           egs.lesson_bdate <= :new.lesson_edate
       AND egs.lesson_edate >= :new.lesson_edate
           )
        OR
           (
           egs.lesson_bdate <= :new.lesson_bdate
       AND egs.lesson_edate >= :new.lesson_edate
           )
       );
IF cnt > 0 THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'обнаружено пересечение времени учебы в расписании группы. ' ||
      'Операция отменена.');
END IF;
END;
-------------------------------------
/*

INSERT INTO
   ed_group_schedule(ed_group_id, room_id, ed_subgroup_type, teacher_id, lesson_bdate,                    lesson_edate,                    ed_subject)
   VALUES           (2,           2,       '1 подгруппа',            1,  TIMESTAMP '1998-05-31 10:45:00', TIMESTAMP '1998-05-31 12:10:00', 'Биология');

*/
--########################################################################## --

-- ################      ROOM SCHEDULE      ################################ --

CREATE TABLE room_schedule
(
   rs_id NUMBER NOT NULL,
   room_id NUMBER NOT NULL,
   lesson_bdate TIMESTAMP,
   lesson_edate TIMESTAMP,
   teacher_id NUMBER NOT NULL,
   ed_subject NUMBER NOT NULL,
   ed_group_id NUMBER NOT NULL,
   PRIMARY KEY (rs_id),
   CONSTRAINT fk_room_sch_room
      FOREIGN KEY (room_id) REFERENCES room(room_id),
   CONSTRAINT fk_room_teacher
      FOREIGN KEY (teacher_id) REFERENCES GLOBAL_OFFICE_USR.teachers(teacher_id),
   CONSTRAINT fk_room_sch_subjects
      FOREIGN KEY (ed_subject) REFERENCES GLOBAL_OFFICE_USR.subjects(subject_id)
);

CREATE UNIQUE INDEX room_schedule_rm
    ON room_schedule(room_id, lesson_bdate, lesson_edate, ed_group_id);
CREATE INDEX room_schedule_tch
    ON room_schedule(lesson_bdate, teacher_id);

     CREATE SEQUENCE rm_sch_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

 CREATE OR REPLACE
TRIGGER rm_sch_ins_seq
        BEFORE INSERT
     ON room_schedule
    FOR EACH ROW
BEGIN
   SELECT rm_sch_seq.NEXTVAL
     INTO :new.rs_Id
     FROM DUAL;
END;


-------------------------------------------
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER room_schdl_ins
        BEFORE INSERT OR UPDATE
     ON room_schedule
    FOR EACH ROW
DECLARE
   cnt INTEGER;
BEGIN
IF :new.lesson_edate < :new.lesson_bdate THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'Некорректное время начала и окончания занятия. Операция отменена.');
END IF;
SELECT COUNT(rms.room_id)
  INTO cnt
  FROM room_schedule rms
 WHERE rms.room_id = :new.room_id
   AND ed_group_id = :new.ed_group_id
   AND (
           (
           rms.lesson_bdate <= :new.lesson_bdate
       AND rms.lesson_edate >= :new.lesson_bdate
           )
        OR
           (
           rms.lesson_bdate <= :new.lesson_edate
       AND rms.lesson_edate >= :new.lesson_edate
           )
        OR
           (
           rms.lesson_bdate <= :new.lesson_bdate
       AND rms.lesson_edate >= :new.lesson_edate
           )
       );
IF cnt > 0 THEN
   RAISE_APPLICATION_ERROR(&error_id,
      'обнаружено пересечение времени занятий в аудитории. ' ||
      'Операция отменена.');
END IF;
END;
----------------------------------------
/*
INSERT INTO
   room_schedule(room_id, teacher_id, lesson_bdate,                    lesson_edate,                    ed_subject)
   VALUES       (2,       1,          TIMESTAMP '1998-05-31 10:41:00', TIMESTAMP '1998-05-31 12:12:00', 'Биология');

*/
-- ######################################################################### --

-- ################      INSERT PROCEDURE FOR SCHEDULE       ############### --
----------------------------------
   CREATE OR REPLACE
PROCEDURE ins_schedule(
                         tch_id IN NUMBER,
                         ed_gr_id IN NUMBER,
                         ed_subgr_type IN VARCHAR2,
                         rm_id IN NUMBER,
                         ls_bdate IN TIMESTAMP,
                         ls_edate IN TIMESTAMP,
                         ed_subj IN NUMBER
                      )
IS
BEGIN
--SET TRANSACTION READ WRITE;

INSERT INTO
  teacher_schedule(teacher_id, room_id, lesson_bdate, lesson_edate, ed_subject)
  VALUES          (tch_id,     rm_id,   ls_bdate,     ls_edate,     ed_subj   );
INSERT INTO
   ed_group_schedule(ed_group_id,       room_id,
                          ed_subgroup_type,       teacher_id,
                             lesson_bdate,     lesson_edate,      ed_subject)
   VALUES           (ed_gr_id,           rm_id,
                           ed_subgr_type,          tch_id,
                              ls_bdate,        ls_edate,          ed_subj   );
INSERT INTO
   room_schedule(room_id, teacher_id, lesson_bdate, lesson_edate, ed_subject, ed_group_id)
   VALUES       (rm_id,   tch_id,     ls_bdate,     ls_edate,     ed_subj,    ed_gr_id);

/* Обработка не позволяет получить клиентскому соединению информацию об ошибке
EXCEPTION WHEN OTHERS THEN BEGIN
      ROLLBACK; RETURN; END; */

END ins_schedule;
/*
CALL ins_schedule( 1, 1, 'Нет', 1
                 , TIMESTAMP '2013-04-10 10:40:00'
                 , TIMESTAMP '2013-04-10 12:10:00'
                 , 'Анатомия'
                 );
*/

----------------------------------
   CREATE OR REPLACE
PROCEDURE del_sch(
                         ts_id IN NUMBER,
                         egs_id IN NUMBER,
                         rs_id IN NUMBER
                      )
IS
BEGIN

DELETE
  FROM teacher_schedule ts
 WHERE ts.ts_id = ts_id;

DELETE
  FROM ed_group_schedule es
 WHERE es.egs_id = egs_id;

DELETE
  FROM room_schedule rs
 WHERE rs.rs_id = rs_id;

END del_sch;


   CREATE OR REPLACE
PROCEDURE del_schedule(
                         tch_id IN NUMBER,
                         ed_gr_id IN NUMBER,
                         ed_subgr_type IN VARCHAR2,
                         rm_id IN NUMBER,
                         ls_bdate IN TIMESTAMP,
                         ls_edate IN TIMESTAMP
                      )
IS
BEGIN

DELETE
  FROM teacher_schedule
 WHERE teacher_id = tch_id
   AND lesson_bdate = ls_bdate
   AND lesson_edate = ls_edate;

DELETE
  FROM ed_group_schedule
 WHERE ed_group_id = ed_gr_id
   AND lesson_bdate = ls_bdate
   AND lesson_edate = ls_edate
   AND ed_subgroup_type = ed_subgr_type;

DELETE
  FROM room_schedule
 WHERE room_id = rm_id
   AND lesson_bdate = ls_bdate
   AND lesson_edate = ls_edate;

END del_schedule;
-----------------------------------
/*
--
SELECT TO_CHAR(lesson_edate, 'dd-mm-yyyy hh24:mi')
     , TO_CHAR(lesson_edate, 'dd-mm-yyyy hh24:mi') FROM teacher_schedule
 WHERE teacher_id = 1
   AND lesson_bdate = TO_DATE('11-02-2013 12:20', 'dd-mm-yyyy hh24:mi')
   AND lesson_edate = TO_DATE('11-02-2013 12:20', 'dd-mm-yyyy hh24:mi')
SELECT * FROM ed_group_schedule;
SELECT * FROM room_schedule;
CALL del_schedule(
                    1,
                    1,
                    'Нет',
                    1,
                    TO_DATE('11-02-2013 12:20', 'dd-mm-yyyy hh24:mi'),
                    TO_DATE('11-02-2013 12:20', 'dd-mm-yyyy hh24:mi')
                 )
commit;
*/
-- ######################################################################### --

-- #####################        WEEK_SCHEDULE               ################ --
CREATE TABLE day_cell
(
   day_cell_id VARCHAR2(8) NOT NULL,
   btime TIMESTAMP,
   etime TIMESTAMP,
   PRIMARY KEY (day_cell_id)
);
   CREATE SEQUENCE day_cell_seq
    START WITH 1
INCREMENT BY 1;

 CREATE OR REPLACE
TRIGGER day_cell_ins_seq
        BEFORE INSERT
     ON day_cell
    FOR EACH ROW
BEGIN
 SELECT 'пара ' || day_cell_seq.NEXTVAL
   INTO :new.day_cell_id
   FROM DUAL;
END;
--SELECT TIMESTAMP '2013-04-01 23:00:00' FROM DUAL
/*
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 09:00:00')
                    , TIMESTAMP('2013-04-01 10:30:00'));
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 10:40:00')
                    , TIMESTAMP('2013-04-01 12:10:00'));
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 12:20:00')
                    , TIMESTAMP('2013-04-01 13:50:00'));
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 14:00:00')
                    , TIMESTAMP('2013-04-01 15:30:00'));
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 15:40:00')
                    , TIMESTAMP('2013-04-01 17:10:00'));
INSERT INTO day_cell( btime, etime)
              VALUES( TIMESTAMP('2013-04-01 17:20:00')
                    , TIMESTAMP('2013-04-01 18:50:00'));
SELECT * FROM day_cell
*/
CREATE TABLE week_type
(
   week_type VARCHAR2(16) NOT NULL,
   PRIMARY KEY (week_type)
);
/*
INSERT INTO week_type(week_type)
VALUES('числитель');
INSERT INTO week_type(week_type)
VALUES('знаменатель');
SELECT * FROM week_type

*/
CREATE TABLE week_day
(
   week_day VARCHAR2(16) NOT NULL,
   PRIMARY KEY (week_day)
);
/*
INSERT INTO week_day(week_day)
VALUES('1. понедельник');
INSERT INTO week_day(week_day)
VALUES('2. вторник');
INSERT INTO week_day(week_day)
VALUES('3. среда');
INSERT INTO week_day(week_day)
VALUES('4. четверг');
INSERT INTO week_day(week_day)
VALUES('5. пятница');
INSERT INTO week_day(week_day)
VALUES('6. суббота');
INSERT INTO week_day(week_day)
VALUES('7. воскресение');
SELECT * FROM week_day
*/

CREATE TABLE semester
(
   semester NUMBER(4) NOT NULL,
   bdate    TIMESTAMP,
   edate    TIMESTAMP,
   PRIMARY KEY (semester)
);
/*
INSERT INTO semester(semester, bdate, edate)
VALUES(1, TIMESTAMP '2013-09-01 00:00:00', TIMESTAMP '2013-12-31 00:00:00');
INSERT INTO semester(semester, bdate, edate)
VALUES(2, TIMESTAMP '2013-02-01 00:00:00', TIMESTAMP '2013-05-31 00:00:00');
*/

CREATE TABLE week_schedule
(
   ws_id        NUMBER NOT NULL,
   sch_year     NUMBER(4) NOT NULL,
   semester     NUMBER(4) NOT NULL,
   week_day     VARCHAR2(16) NOT NULL,
   day_cell_id  VARCHAR2(8) NOT NULL,
   week_type    VARCHAR2(16) NOT NULL,
   ed_group_id  NUMBER NOT NULL,
   ed_subgroup_type VARCHAR2(32) NOT NULL,
   teacher_id   NUMBER NOT NULL,
   room_id      NUMBER NOT NULL,
   ed_subject   NUMBER NOT NULL,
   PRIMARY KEY (ws_id),
   CONSTRAINT fk_week_sch_smstr
      FOREIGN KEY (semester) REFERENCES semester(semester),
   CONSTRAINT fk_week_sch_wday
      FOREIGN KEY (week_day) REFERENCES week_day(week_day),
   CONSTRAINT fk_week_sch_dcell
      FOREIGN KEY (day_cell_id) REFERENCES day_cell(day_cell_id),
   CONSTRAINT fk_week_sch_wtype
      FOREIGN KEY (week_type) REFERENCES week_type(week_type),
   CONSTRAINT fk_week_sch_ed_group
      FOREIGN KEY (ed_group_id) REFERENCES GLOBAL_OFFICE_USR.studentgroups(studentGroup_Id),
   CONSTRAINT fk_week_sch_ed_sbgr_type
      FOREIGN KEY (ed_subgroup_type) REFERENCES ed_subgroup_type(ed_subgroup_type),
   CONSTRAINT fk_week_sch_teacher
      FOREIGN KEY (teacher_id) REFERENCES GLOBAL_OFFICE_USR.teachers(teacher_id),
   CONSTRAINT fk_week_sch_room
      FOREIGN KEY (room_id) REFERENCES room(room_id),
   CONSTRAINT fk_week_sch_subject
      FOREIGN KEY (ed_subject) REFERENCES GLOBAL_OFFICE_USR.subjects(subject_id)
);

CREATE INDEX week_schedule_gr
ON week_schedule( ed_group_id, sch_year, semester
                , week_day, day_cell_id, week_type, ed_subgroup_type);
CREATE INDEX week_schedule_tch
ON week_schedule(teacher_id, sch_year, semester, week_day, day_cell_id, week_type);
CREATE INDEX week_schedule_cell
ON week_schedule(sch_year, semester, week_day, day_cell_id, week_type);


CREATE TABLE schedule_link
(
   ws_id NUMBER NOT NULL,
   ts_id NUMBER NOT NULL,
   egs_id NUMBER NOT NULL,
   rs_id NUMBER NOT NULL,
   CONSTRAINT fk_sch_link_ws_id
      FOREIGN KEY (ws_id) REFERENCES week_schedule(ws_id),
   CONSTRAINT fk_sch_link_ts_id
      FOREIGN KEY (ts_id) REFERENCES teacher_schedule(ts_id),
   CONSTRAINT fk_sch_link_egs_id
      FOREIGN KEY (egs_id) REFERENCES ed_group_schedule(egs_id),
   CONSTRAINT fk_sch_link_rs_id
      FOREIGN KEY (rs_id) REFERENCES room_schedule(rs_id)
);
CREATE INDEX schedule_link_main
ON schedule_link(ws_id);

     CREATE SEQUENCE wk_sch_seq
      START WITH 1
  INCREMENT BY 1
  CACHE 100;

DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER schdl_link_del
        BEFORE DELETE
     ON schedule_link
    FOR EACH ROW
DECLARE
BEGIN
DELETE FROM teacher_schedule ts
 WHERE ts.ts_id = :old.ts_id;
DELETE FROM ed_group_schedule es
 WHERE es.egs_id = :old.egs_id;
DELETE FROM room_schedule rs
 WHERE rs.rs_id = :old.rs_id;
END;

--CREATE INDEX week_schedule_cell ON week_schedule(week_type);
/*
INSERT INTO
week_schedule(sch_year, semester, week_day,         day_cell_id, week_type,   ed_group_id, teacher_id, room_id, ed_subject)
       VALUES(2013,     2,        '1. понедельник', 'пара 1',    'числитель', 1,           1,          1,       'Анатомия');
INSERT INTO
week_schedule(sch_year, semester, week_day,         day_cell_id, week_type,   ed_group_id, teacher_id, room_id, ed_subject)
       VALUES(2013,     2,        '1. понедельник', 'пара 1',    'числитель', 2,           2,          2,       'Биология');
INSERT INTO
week_schedule(sch_year, semester, week_day,         day_cell_id, week_type,   ed_group_id, teacher_id, room_id, ed_subject)
       VALUES(2013,     2,        '1. понедельник', 'пара 2',    'числитель', 1,           1,          1,       'Анатомия');
INSERT INTO
week_schedule(sch_year, semester, week_day,         day_cell_id, week_type,   ed_group_id, teacher_id, room_id, ed_subject)
       VALUES(2013,     2,        '1. понедельник', 'пара 2',    'числитель', 2,           2,          2,       'Биология');

*/
-------------------------------------------------------------------------------
--DEFINE error_id = "-20000"
-- CREATE OR REPLACE
--TRIGGER week_schdl_ins
--        BEFORE INSERT OR UPDATE
--     ON week_schedule
--    FOR EACH ROW
--DECLARE
--   cnt INTEGER;
--BEGIN
--IF :new.lesson_edate < :new.lesson_bdate THEN
--   RAISE_APPLICATION_ERROR(&error_id,
--      'Некорректное время начала и окончания занятия. Операция отменена.');
--END IF;
--SELECT COUNT(rms.room_id)
--  INTO cnt
--  FROM room_schedule rms
-- WHERE rms.room_id = :new.room_id
--   AND (
--           (
--           rms.lesson_bdate <= :new.lesson_bdate
--       AND rms.lesson_edate >= :new.lesson_bdate
--           )
--        OR
--           (
--           rms.lesson_bdate <= :new.lesson_edate
--       AND rms.lesson_edate >= :new.lesson_edate
--           )
--        OR
--           (
--           rms.lesson_bdate <= :new.lesson_bdate
--       AND rms.lesson_edate >= :new.lesson_edate
--           )
--       );
--IF cnt > 0 THEN
--   RAISE_APPLICATION_ERROR(&error_id,
--      'обнаружено пересечение времени занятий в аудитории. ' ||
--      'Операция отменена.');
--END IF;
--END;

------------------------------------------------------------------------------
  CREATE OR REPLACE
FUNCTION get_week_day(inp_date TIMESTAMP)
RETURN VARCHAR2
IS
wday VARCHAR2(16);
BEGIN
SELECT CASE TO_CHAR (inp_date, 'FmDay', 'nls_date_language=english')
          WHEN 'Monday' THEN '1. понедельник'
          WHEN 'Tuesday' THEN '2. вторник'
          WHEN 'Wednesday' THEN '3. среда'
          WHEN 'Thursday' THEN '4. четверг'
          WHEN 'Friday' THEN '5. пятница'
          WHEN 'Saturday' THEN '6. суббота'
          WHEN 'Sunday' THEN '7. воскресение'
       END INTO wday
  FROM dual;
RETURN wday;
END;
--SELECT to_char (TIMESTAMP '2013-05-07 01:30:00', 'FmDay', 'nls_date_language=english') FROM DUAL
-- SELECT TO_TIMESTAMP (to_char (TIMESTAMP '2013-05-07 01:30:00', 'DD-MM-') || to_char(SYSDATE, 'YYYY'), 'DD-MM-YYYY') FROM DUAL
------------------------------------------------------------------------------
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER wk_schdl_bins
        BEFORE INSERT
     ON week_schedule
    FOR EACH ROW
DECLARE
BEGIN
 SELECT wk_sch_seq.NEXTVAL
   INTO :new.ws_Id
   FROM DUAL;
END;

DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER wk_schdl_ains
        AFTER INSERT
     ON week_schedule
    FOR EACH ROW
DECLARE
curr_date TIMESTAMP;
semestr_edate TIMESTAMP;
cell_btime TIMESTAMP;
cell_etime TIMESTAMP;
is_fweek BOOLEAN;
tch_id        week_schedule.teacher_id%TYPE;
ed_subgr_type week_schedule.ed_subgroup_type%TYPE;
rm_id         week_schedule.room_id%TYPE;
sch_yr     week_schedule.sch_year%TYPE;
sr         week_schedule.semester%TYPE;
wk_day     week_schedule.week_day%TYPE;
dcell_id   week_schedule.day_cell_id%TYPE;
wk_type    week_schedule.week_type%TYPE;
ed_gr_id   week_schedule.ed_group_id%TYPE;
ed_subj    week_schedule.ed_subject%TYPE;
ts_id      NUMBER;
egs_id     NUMBER;
rs_id      NUMBER;
BEGIN
tch_id := :new.teacher_id;
ed_subgr_type := :new.ed_subgroup_type;
rm_id := :new.room_id;
sch_yr := :new.sch_year;
sr := :new.semester;
wk_day := :new.week_day;
dcell_id := :new.day_cell_id;
wk_type := :new.week_type;
ed_gr_id := :new.ed_group_id;
ed_subj := :new.ed_subject;

is_fweek := TRUE;
SELECT TO_TIMESTAMP (TO_CHAR (bdate, 'DD-MM-') || TO_CHAR(SYSDATE, 'YYYY'), 'DD-MM-YYYY')
  INTO curr_date -- выставить текущую дату на начало
  FROM semester WHERE semester = sr;
SELECT edate
  INTO semestr_edate
  FROM semester WHERE semester = sr;

WHILE get_week_day(curr_date) <> wk_day
LOOP
   IF get_week_day(curr_date) = '7. воскресение' THEN
      is_fweek := FALSE;
   END IF;
   curr_date := curr_date + INTERVAL '1' DAY;
END LOOP;
IF  NOT (sr = 1 AND (wk_type = 'числитель'   AND is_fweek
                 OR  wk_type = 'знаменатель' AND NOT is_fweek))
AND NOT (sr = 2 AND (wk_type = 'знаменатель' AND is_fweek
                 OR  wk_type = 'числитель'   AND NOT is_fweek))
THEN
   curr_date := curr_date + INTERVAL '7' day;
END IF;

WHILE curr_date < semestr_edate
LOOP

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(btime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_btime
    FROM day_cell WHERE day_cell_id = dcell_id;

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(etime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_etime
    FROM day_cell WHERE day_cell_id = dcell_id;

  ins_schedule( tch_id
              , ed_gr_id
              , ed_subgr_type
              , rm_id
              , cell_btime
              , cell_etime
              , ed_subj
              );
   SELECT ts.ts_id
     INTO ts_id
     FROM teacher_schedule ts
    WHERE ts.teacher_id = tch_id
      AND ts.lesson_bdate = cell_btime
      AND ts.lesson_edate = cell_etime;
   SELECT es.egs_id
     INTO egs_id
     FROM ed_group_schedule es
    WHERE es.ed_group_id = ed_gr_id
      AND es.lesson_bdate = cell_btime
      AND es.lesson_edate = cell_etime
      AND es.ed_subgroup_type = ed_subgr_type;
   SELECT rs.rs_id
     INTO rs_id
     FROM room_schedule rs
    WHERE rs.room_id = room_id
      AND rs.lesson_bdate = cell_btime
      AND rs.lesson_edate = cell_etime;

   INSERT INTO schedule_link(ws_id, ts_id, egs_id, rs_id)
   VALUES(:new.ws_id, ts_id, egs_id, rs_id);
   curr_date := curr_date + INTERVAL '14' day;
END LOOP;

END;
/*
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER ed_gr_schdl_ins
        BEFORE UPDATE
     ON ed_group_schedule
    FOR EACH ROW
DECLARE
BEGIN
   RAISE_APPLICATION_ERROR(&error_id, 'Операция обновления недоступна');
END;
*/
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER week_schdl_upd
        BEFORE UPDATE
     ON week_schedule
    FOR EACH ROW
DECLARE
BEGIN
   RAISE_APPLICATION_ERROR(&error_id, 'Операция обновления недоступна');
END;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
   CREATE OR REPLACE
PROCEDURE ins_week_schedule(
                              sch_yr     NUMBER,
                              sr     NUMBER, --semester
                              wk_day     VARCHAR2,
                              dcell_id VARCHAR2,
                              wk_type    VARCHAR2,
                              ed_gr_id  NUMBER,
                              ed_subgr_type VARCHAR2,
                              tch_id   NUMBER,
                              rm_id      NUMBER,
                              ed_subj   NUMBER
                           )
IS
curr_date TIMESTAMP;
semestr_edate TIMESTAMP;
cell_btime TIMESTAMP;
cell_etime TIMESTAMP;
is_fweek BOOLEAN;
BEGIN
is_fweek := TRUE;
SELECT TO_TIMESTAMP (TO_CHAR (bdate, 'DD-MM-') || TO_CHAR(SYSDATE, 'YYYY'), 'DD-MM-YYYY')
  INTO curr_date -- выставить текущую дату на начало
  FROM semester WHERE semester = sr;
SELECT edate
  INTO semestr_edate
  FROM semester WHERE semester = sr;

WHILE get_week_day(curr_date) <> wk_day
LOOP
   IF get_week_day(curr_date) = '7. воскресение' THEN
      is_fweek := FALSE;
   END IF;
   curr_date := curr_date + INTERVAL '1' DAY;
END LOOP;
IF  NOT (sr = 1 AND (wk_type = 'числитель'   AND is_fweek
                 OR  wk_type = 'знаменатель' AND NOT is_fweek))
AND NOT (sr = 2 AND (wk_type = 'знаменатель' AND is_fweek
                 OR  wk_type = 'числитель'   AND NOT is_fweek))
THEN
   curr_date := curr_date + INTERVAL '7' day;
END IF;

WHILE curr_date < semestr_edate
LOOP

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(btime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_btime
    FROM day_cell WHERE day_cell_id = dcell_id;

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(etime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_etime
    FROM day_cell WHERE day_cell_id = dcell_id;

  ins_schedule( tch_id
              , ed_gr_id
              , ed_subgr_type
              , rm_id
              , cell_btime
              , cell_btime
              , ed_subj
              );

   curr_date := curr_date + INTERVAL '14' day;
END LOOP;

INSERT INTO week_schedule( sch_year, semester, week_day, day_cell_id, week_type
                         , ed_group_id, ed_subgroup_type, teacher_id, room_id
                         , ed_subject)
                  VALUES ( sch_yr, sr, wk_day, dcell_id, wk_type, ed_gr_id
                         , ed_subgr_type, tch_id, rm_id, ed_subj);

END ins_week_schedule;


   CREATE OR REPLACE
PROCEDURE ins_wk_schedule(
                              sch_yr     NUMBER,
                              sr     NUMBER, --semester
                              wk_day     VARCHAR2,
                              dcell_id VARCHAR2,
                              ed_gr_id  NUMBER,
                              ed_subgr_type VARCHAR2,
                              tch_id   NUMBER,
                              rm_id      NUMBER,
                              ed_subj   NUMBER
                           )
IS
BEGIN
FOR wk_type in (SELECT week_type FROM week_type) LOOP
   INSERT INTO
   week_schedule
   (
      sch_year,
      semester,
      week_day,
      day_cell_id,
      week_type,
      ed_group_id,
      ed_subgroup_type,
      teacher_id,
      room_id,
      ed_subject
   )
   VALUES
   (
      sch_yr,
      sr,
      wk_day,
      dcell_id,
      wk_type.week_type,
      ed_gr_id,
      ed_subgr_type,
      tch_id,
      rm_id,
      ed_subj
   );
END LOOP;
END ins_wk_schedule;

/*
CALL ins_week_schedule(2013, 2, '1. понедельник', 'пара 3', 'числитель', 1, 'Нет', 1, 1, 'Биология');
COMMIT;
CALL ins_wk_schedule(2013, 2, '1. понедельник', 'пара 3', 1, 'Нет', 1, 1, 'Анатомия');
COMMIT;
*/

--INSERT INTO
--  teacher_schedule(teacher_id, room_id, lesson_bdate, lesson_edate, ed_subject)
--  VALUES          (tch_id,     rm_id,   cell_btime,   cell_etime,   ed_subj   );
--INSERT INTO
--   ed_group_schedule(ed_group_id,       room_id,
--                          ed_subgroup_type,       teacher_id,
--                             lesson_bdate,     lesson_edate,      ed_subject)
--   VALUES           (ed_gr_id,           rm_id,
--                           ed_subgr_type,          tch_id,
--                              cell_btime,        cell_etime,          ed_subj);
--INSERT INTO
--   room_schedule(room_id, teacher_id, lesson_bdate, lesson_edate, ed_subject)
--   VALUES       (rm_id,   tch_id,     cell_btime,   cell_etime,     ed_subj   );

--SELECT to_char (sysdate, 'FmDay', 'nls_date_language=english') FROM DUAL
--select to_date('28-02-2000', 'DD-MM-YYYY')+ interval '1' day from dual;

--SELECT to_char (DATE '2013-04-28', 'FmDay', 'nls_date_language=english') FROM DUAL
--SELECT INTERVAL '3 12:30:06.7' DAY TO SECOND(1) FROM DUAL;\
--to_char (DATE '2013-04-24', 'FmDay', 'nls_date_language=english')

-- SELECT * FROM teacher_schedule ORDER BY lesson_bdate
-- SELECT * FROM ed_group_schedule ORDER BY lesson_bdate
-- SELECT * FROM room_schedule ORDER BY lesson_bdate
-- SELECT * FROM week_schedule
-- TRUNCATE TABLE teacher_schedule
-- SELECT TO_CHAR(CAST(TIMESTAMP '2013-12-12 12:00:05' AS DATE), 'DD.MM.YYYY hh24:mi:ss') FROM DUAL
-------------------------------------------------------------------------------
DEFINE error_id = "-20000"
 CREATE OR REPLACE
TRIGGER wk_schdl_bdel
        BEFORE DELETE
     ON week_schedule
    FOR EACH ROW
DECLARE
BEGIN
DELETE FROM schedule_link sl
 WHERE sl.ws_id = :old.ws_id;
END;
-------------------------------------------------------------------------------
   CREATE OR REPLACE
PROCEDURE del_week_schedule(
                              sch_yr   NUMBER,
                              sr       NUMBER, --semester
                              wk_day   VARCHAR2,
                              dcell_id VARCHAR2,
                              wk_type  VARCHAR2,
                              ed_gr_id   NUMBER
                           )
IS
curr_date     TIMESTAMP;
semestr_edate TIMESTAMP;
cell_btime    TIMESTAMP;
cell_etime    TIMESTAMP;
is_fweek      BOOLEAN;
cnt           INTEGER;
tch_id        week_schedule.teacher_id%TYPE;
ed_subgr_type week_schedule.ed_subgroup_type%TYPE;
rm_id         week_schedule.room_id%TYPE;
BEGIN
SELECT COUNT(ws.ed_group_id)
  INTO cnt
  FROM week_schedule ws
 WHERE ws.sch_year = sch_yr
   AND ws.semester = sr
   AND ws.week_day = wk_day
   AND ws.day_cell_id = dcell_id
   AND ws.week_type = wk_type
   AND ws.ed_group_id = ed_gr_id;
IF cnt < 1 THEN
   RETURN;
END IF;

SELECT ws.teacher_id, ws.ed_subgroup_type, ws.room_id
  INTO tch_id, ed_subgr_type, rm_id
  FROM week_schedule ws
 WHERE ws.sch_year = sch_yr
   AND ws.semester = sr
   AND ws.week_day = wk_day
   AND ws.day_cell_id = dcell_id
   AND ws.week_type = wk_type
   AND ws.ed_group_id = ed_gr_id;

is_fweek := TRUE;
SELECT TO_TIMESTAMP (TO_CHAR (bdate, 'DD-MM-') || TO_CHAR(2013), 'DD-MM-YYYY')
  INTO curr_date -- выставить текущую дату на начало
  FROM semester WHERE semester = sr;
SELECT edate
  INTO semestr_edate
  FROM semester WHERE semester = sr;


WHILE get_week_day(curr_date) <> wk_day
LOOP
   IF get_week_day(curr_date) = '7. воскресение' THEN
      is_fweek := FALSE;
   END IF;
   curr_date := curr_date + INTERVAL '1' day;
END LOOP;
IF  NOT (sr = 1 AND (wk_type = 'числитель'   AND is_fweek
                 OR  wk_type = 'знаменатель' AND NOT is_fweek))
AND NOT (sr = 2 AND (wk_type = 'знаменатель' AND is_fweek
                 OR  wk_type = 'числитель'   AND NOT is_fweek))
THEN
   curr_date := curr_date + INTERVAL '7' day;
END IF;

WHILE curr_date < semestr_edate
LOOP

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(btime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_btime
    FROM day_cell WHERE day_cell_id = dcell_id;

  SELECT TO_TIMESTAMP(TO_CHAR(curr_date, 'DD-MM-YYYY') ||
                      TO_CHAR(etime, ' hh24:mi'),
         'DD-MM-YYYY hh24:mi')
    INTO cell_etime
    FROM day_cell WHERE day_cell_id = dcell_id;

  del_schedule( tch_id
              , ed_gr_id
              , ed_subgr_type
              , rm_id
              , cell_btime
              , cell_btime
              );

   curr_date := curr_date + INTERVAL '14' day;
END LOOP;

DELETE
  FROM week_schedule ws
 WHERE ws.sch_year = sch_yr
   AND ws.semester = sr
   AND ws.week_day = wk_day
   AND ws.day_cell_id = dcell_id
   AND ws.week_type = wk_type
   AND ws.ed_group_id = ed_gr_id;

END del_week_schedule;

   CREATE OR REPLACE
PROCEDURE del_wk_schedule(
                              sch_yr   NUMBER,
                              sr       NUMBER, --semester
                              wk_day   VARCHAR2,
                              dcell_id VARCHAR2,
                              ed_gr_id   NUMBER
                           )
IS
BEGIN
FOR wk_type in (SELECT week_type FROM week_type) LOOP
   del_week_schedule(sch_yr, sr, wk_day, dcell_id, wk_type.week_type, ed_gr_id);
END LOOP;
END del_wk_schedule;



   CREATE OR REPLACE
PROCEDURE del_wk_sch(ws_id NUMBER)
IS
sch_yr   NUMBER(4);
sr       NUMBER(4); --semester
wk_day   VARCHAR2(16);
dcell_id VARCHAR2(8);
ed_gr_id   NUMBER;
BEGIN

SELECT ws.sch_year
     , ws.semester
     , ws.week_day
     , ws.day_cell_id
     , ws.ed_group_id
  INTO sch_yr
     , sr
     , wk_day
     , dcell_id
     , ed_gr_id
  FROM week_schedule ws
 WHERE ws.ws_id = ws_id;

DELETE
  FROM week_schedule ws
 WHERE ws.sch_year = sch_yr
   AND ws.semester = sr
   AND ws.week_day = wk_day
   AND ws.day_cell_id = dcell_id
   AND ws.ed_group_id = ed_gr_id;

END del_wk_sch;


/*
INSERT INTO week_schedule( sch_year, semester, week_day, day_cell_id, week_type
                         , ed_group_id, ed_subgroup_type, teacher_id, room_id
                         , ed_subject)
VALUES (2013, 2, '1. понедельник', 'пара 3', 'знаменатель', 1, 'Нет', 1, 1, 'Анатомия');
CALL del_week_schedule(2013, 2, '1. понедельник', 'пара 3', 'числитель', 1);
CALL del_wk_schedule(2013, 2, '1. понедельник', 'пара 3', 1);
DELETE FROM week_schedule WHERE ws_id = 3;
COMMIT;
SELECT * FROM week_schedule;
*/

-------------------------------------------------------------------------------
SELECT CASE WHEN sframe.day_cell_id = 'пара 1'
            THEN sframe.week_day
            ELSE ' '
       END week_day
     , sframe.day_cell_id
     , NVL(sframe.studentgroup, 'отсутствует')
     , CASE WHEN wstp.ws_id IS NULL AND wsbt.ws_id IS NULL
            THEN '<p>-</p>'
       ELSE
       CASE WHEN NVL(wstp.teacher_id, -1) <> NVL(wsbt.teacher_id, -1)
              OR NVL(wstp.room_id, -1) <> NVL(wsbt.room_id, -1)
              OR NVL(wstp.ed_subject, -1) <> NVL(wsbt.ed_subject, -1)
              OR NVL(wstp.ed_subgroup_type, ' ') <> NVL(wsbt.ed_subgroup_type, ' ')
            THEN '<p>' || (SELECT teacher_info FROM teacher
                  WHERE teacher.teacher_id = wstp.teacher_id) || ' '
              || (SELECT room_info FROM room
                  WHERE room.room_id = wstp.room_id) || ' '
              || (SELECT sj.subject FROM GLOBAL_OFFICE_USR.subjects sj
                  WHERE sj.subject_id = wstp.ed_subject) || ' '
              || CASE WHEN NVL(wstp.ed_subgroup_type, '-') = 'Нет'
                      THEN ''
                      ELSE NVL(wstp.ed_subgroup_type, '-')
                 END
              || ' </p>' || CHR(13) || CHR(10)
              || '<p> ----------------------------- </p>' || CHR(13) || CHR(10)
              || '<p> ' || (SELECT teacher_info FROM teacher
                  WHERE teacher.teacher_id = wsbt.teacher_id) || ' '
              || (SELECT room_info FROM room
                  WHERE room.room_id = wsbt.room_id) || ' '
              || (SELECT sj.subject FROM GLOBAL_OFFICE_USR.subjects sj
                  WHERE sj.subject_id = wsbt.ed_subject) || ' '
              || CASE WHEN NVL(wsbt.ed_subgroup_type, '-') = 'Нет'
                      THEN ''
                      ELSE wsbt.ed_subgroup_type
                 END  || ' </p>'
            ELSE '<p>' || (SELECT teacher_info FROM teacher
                  WHERE teacher.teacher_id = wstp.teacher_id) || ' '
              || (SELECT room_info FROM room
                  WHERE room.room_id = wstp.room_id) || ' '
              || (SELECT sj.subject FROM GLOBAL_OFFICE_USR.subjects sj
                  WHERE sj.subject_id = wstp.ed_subject) || ' '
              || CASE WHEN NVL(wstp.ed_subgroup_type, '-') = 'Нет'
                      THEN ''
                      ELSE NVL(wstp.ed_subgroup_type, '-')
                 END || ' </p>'
       END
       END cell_sch
------------------------------------------------------------------------------
     , wsbt.teacher_id
     , wstp.teacher_id
------------------------------------------------------------------------------
  FROM
        (
   SELECT week_day, day_cell_id, studentgroup_id, studentgroup
     FROM week_day, day_cell
     LEFT OUTER JOIN
          (
     SELECT studentgroup_id, studentgroup
       FROM GLOBAL_OFFICE_USR.studentgroups sg
          , GLOBAL_OFFICE_USR.semesters sm
          , GLOBAL_OFFICE_USR.professionplans pp
      WHERE sg.semester_Id = sm.semester_id
        AND sm.professionplan_id = pp.professionplan_id
        AND sm.course_id = 1
        AND pp.profession_id = 3
            )       ON 1=1
          ) sframe
  LEFT OUTER JOIN
       week_schedule wstp
    ON sframe.day_cell_id = wstp.day_cell_id
   AND sframe.week_day = wstp.week_day
   AND sframe.studentgroup_id = wstp.ed_group_id
   AND wstp.sch_year = 2013
   AND wstp.semester = 1
   AND wstp.week_type = 'числитель'
  LEFT OUTER JOIN
       week_schedule wsbt
    ON sframe.studentgroup_id = wsbt.ed_group_id
   AND wsbt.sch_year = 2013
   AND wsbt.semester = 1
   AND wsbt.week_day = sframe.week_day
   AND wsbt.day_cell_id = sframe.day_cell_id
   AND wsbt.week_type = 'знаменатель'
 ORDER BY sframe.week_day, sframe.day_cell_id, sframe.studentgroup_id;

-- SELECT * FROM GLOBAL_OFFICE_USR.semesters
-- SELECT * FROM GLOBAL_OFFICE_USR.studentgroups
-- SELECT * FROM GLOBAL_OFFICE_USR.courses
-- SELECT * FROM GLOBAL_OFFICE_USR.professionplans
-- SELECT * FROM GLOBAL_OFFICE_USR.professions
-- ######################################################################### --
--SELECT to_char(to_date('1998/05/31-23:32:15', 'yyyy/mm/dd-hh24:mi:ss') + INTERVAL '1' DAY, 'yyyy/mm/dd-hh24:mi:ss') FROM DUAL
--SELECT 'Output from PL/SQL...' FROM DUAL;
-- SELECT * FROM teacher;
-- SELECT * FROM education_group;
-- SELECT * FROM room
-- SELECT * FROM week_schedule
-- SELECT * FROM GLOBAL_OFFICE_USR.teachers
/*
SELECT to_char(egs.lesson_bdate, 'hh24:mi:ss')
     , to_char(egs.lesson_edate, 'hh24:mi:ss')
     , egs.*
  FROM ed_group_schedule egs;
*/
----------------------------
/*
SELECT to_char(lesson_bdate, 'hh24:mi:ss')
     , to_char(ts.lesson_edate, 'hh24:mi:ss')
     , ts.*
  FROM teacher_schedule ts;
*/
-----------------------------
/*
SELECT to_char(rs.lesson_bdate, 'hh24:mi:ss')
     , to_char(rs.lesson_edate, 'hh24:mi:ss')
     , rs.*
  FROM room_schedule rs;
*/
-- commit


-- ############################################################################
INSERT INTO APEX_040200.wwv_flow_messages$
     (
       flow_id
     , APEX_040200.wwv_flow_messages$.name
     , message_language
     , message_text
     , security_group_id
     , last_updated_by
     , last_updated_on
     , created_by
     , created_on
     , message_comment
       )
SELECT 109
     , APEX_040200.wwv_flow_messages$.name
     , message_language
     , message_text
     , security_group_id
     , 'V'
     , SYSDATE
     , created_by
     , created_on
     , message_comment
  FROM APEX_040200.wwv_flow_messages$
 WHERE flow_id = 107;
DELETE FROM APEX_040200.wwv_flow_messages$
 WHERE flow_id = 109;
-- ############################################################################
