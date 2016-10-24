CREATE
  TABLE PERSON
  (
    P_ID     NUMBER PRIMARY KEY,
    PNAME    VARCHAR2(100),
    USERNAME VARCHAR2(20),
    PASSWORD VARCHAR2(20),
    ADDRESS  VARCHAR2(250),
    DOB      DATE,
    GENDER   CHAR(1)
  );

CREATE
  TABLE SICK_PERSON
  (
    P_ID   NUMBER PRIMARY KEY,
    HS1_ID NUMBER,
    HS2_ID NUMBER,
    HS1_AUTH_DATE DATE,
    HS2_AUTH_DATE DATE
  );

CREATE
  TABLE WELL_PERSON
  (
    P_ID   NUMBER PRIMARY KEY,
    HS1_ID NUMBER,
    HS2_ID NUMBER,
    HS1_AUTH_DATE DATE,
    HS2_AUTH_DATE DATE
  );

CREATE
  TABLE DISEASE
  (
    D_ID  NUMBER PRIMARY KEY,
    DNAME VARCHAR2(50)
  );

CREATE
  TABLE RECORD_DISEASE
  (
    P_ID        NUMBER,
    D_ID        NUMBER,
    RECORD_TIME TIMESTAMP,
    PRIMARY KEY(P_ID, D_ID)
  );

CREATE
  TABLE DISEASE_OBSERVATION
  (
    D_ID    NUMBER,
    OB_TYPE VARCHAR2(50),
    PRIMARY KEY(D_ID, OB_TYPE)
  );

CREATE
  TABLE RECOMMENDATION
  (
    R_ID        NUMBER PRIMARY KEY,
    FREQUENCY   VARCHAR2(20),
    DESCRIPTION VARCHAR2(1024),
    METRIC      VARCHAR2(20),
    LOWER_BOUND VARCHAR2(20),
    UPPER_BOUND VARCHAR2(20),
    STRING_VALUE VARCHAR2(20)
  );

CREATE
  TABLE STANDARD_RECOMMENDATION
  (
    D_ID      NUMBER,
    R_ID      NUMBER,
    PRIMARY KEY(D_ID, R_ID)
  );

CREATE
  TABLE SPECIFIC_RECOMMENDATION
  (
    P_ID      NUMBER,
    R_ID      NUMBER,
    RECO_TIME TIMESTAMP,
    PRIMARY KEY(P_ID, R_ID)
  );

CREATE
  TABLE ALERT
  (
    A_ID        NUMBER PRIMARY KEY,
    P_ID        NUMBER,
    DESCRIPTION VARCHAR2(1024)
  );

CREATE
  TABLE OBSERVATION
  (
    OB_ID    NUMBER PRIMARY KEY,
    --OB_TYPE  VARCHAR2(50),
    R_ID NUMBER,
    OB_VALUE VARCHAR2(20)
  );

CREATE
  TABLE OBSERVATION_TYPE
  (
    OB_TYPE     VARCHAR2(50),
    R_ID        NUMBER PRIMARY KEY
   -- PRIMARY KEY(OB_TYPE, R_ID)
  );

CREATE
  TABLE RECORD_OBSERVATION
  (
    OB_ID       NUMBER,
    P_ID        NUMBER,
    RECORD_TIME TIMESTAMP,
    OB_TIME     TIMESTAMP,
    PRIMARY KEY(OB_ID, P_ID)
  );


ALTER TABLE SICK_PERSON ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE SICK_PERSON ADD FOREIGN KEY (HS1_ID) REFERENCES PERSON(P_ID);
ALTER TABLE SICK_PERSON ADD FOREIGN KEY (HS2_ID) REFERENCES PERSON(P_ID);
ALTER TABLE WELL_PERSON ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE WELL_PERSON ADD FOREIGN KEY (HS1_ID) REFERENCES PERSON(P_ID);
ALTER TABLE WELL_PERSON ADD FOREIGN KEY (HS2_ID) REFERENCES PERSON(P_ID);
ALTER TABLE RECORD_DISEASE ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE RECORD_DISEASE ADD FOREIGN KEY (D_ID) REFERENCES DISEASE(D_ID);
--ALTER TABLE DISEASE_OBSERVATION ADD FOREIGN KEY (D_ID) REFERENCES DISEASE(D_ID);
--ALTER TABLE DISEASE_OBSERVATION ADD FOREIGN KEY (OB_TYPE) REFERENCES OBSERVATION_TYPE(OB_TYPE);
ALTER TABLE STANDARD_RECOMMENDATION ADD FOREIGN KEY (D_ID) REFERENCES DISEASE(D_ID);
ALTER TABLE STANDARD_RECOMMENDATION ADD FOREIGN KEY (R_ID) REFERENCES RECOMMENDATION(R_ID);
ALTER TABLE SPECIFIC_RECOMMENDATION ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE SPECIFIC_RECOMMENDATION ADD FOREIGN KEY (R_ID) REFERENCES RECOMMENDATION(R_ID);
ALTER TABLE ALERT ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE OBSERVATION_TYPE ADD FOREIGN KEY (R_ID) REFERENCES RECOMMENDATION (R_ID);
--ALTER TABLE OBSERVATION ADD FOREIGN KEY (OB_TYPE) REFERENCES OBSERVATION_TYPE(OB_TYPE);
ALTER TABLE OBSERVATION ADD FOREIGN KEY (R_ID) REFERENCES OBSERVATION_TYPE(R_ID);
ALTER TABLE RECORD_OBSERVATION ADD FOREIGN KEY (OB_ID) REFERENCES OBSERVATION(OB_ID);
ALTER TABLE RECORD_OBSERVATION ADD FOREIGN KEY (P_ID) REFERENCES PERSON(P_ID);
ALTER TABLE ALERT ADD viewed varchar(20);



set serveroutput on format wrapped;

create or replace TRIGGER obsv_value_bound
  BEFORE
    INSERT-- OR
    --UPDATE OF ob_value
  ON observation
FOR EACH ROW
declare is_null number;
lo_bound number;
up_bound number;
alert_count number;
descrip_reco VARCHAR2(1024);
BEGIN
select R1.lower_bound into is_null from RECOMMENDATION R1 where R1.r_id = :new.r_id;
--if (select R1.lower_bound from RECOMMENDATION R1 where R1.r_id = :new.r_id) <> NULL
--if :new.r_id <> null
if is_null is not null
  then
    select to_number(R1.lower_bound) into lo_bound from RECOMMENDATION R1 where R1.r_id = :new.r_id;
    select to_number(R1.upper_bound) into up_bound from RECOMMENDATION R1 where R1.r_id = :new.r_id;
    select R1.description into descrip_reco from RECOMMENDATION R1 where R1.r_id = :new.r_id;
    if (to_number(:new.ob_value) > up_bound or to_number(:new.ob_value) < lo_bound)
      then
      select count(*) into alert_count from alert;
      insert into alert values(alert_count+1,1, descrip_reco, 'False');
       --DBMS_OUTPUT.PUT_LINE('InsertingYY');
       --select R1.lower_bound from RECOMMENDATION R1 where R1.r_id = :new.r_id;
       else
       --DBMS_OUTPUT.PUT_LINE('InsertingNNN');
    end if;
end if;
END;
/



COMMIT;
