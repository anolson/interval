--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    body text,
    created_at timestamp without time zone,
    user_id integer,
    workout_id integer
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: data_values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE data_values (
    id integer NOT NULL,
    training_file_id integer,
    relative_time integer,
    absolute_time integer,
    power integer,
    cadence integer,
    heartrate integer,
    speed double precision,
    distance double precision
);


--
-- Name: data_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_values_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: data_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_values_id_seq OWNED BY data_values.id;


--
-- Name: markers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE markers (
    id integer NOT NULL,
    active boolean DEFAULT true,
    avg_cadence integer DEFAULT 0,
    avg_heartrate integer DEFAULT 0,
    avg_power integer DEFAULT 0,
    avg_speed double precision DEFAULT 0,
    "comment" character varying(255),
    duration time without time zone,
    duration_seconds integer DEFAULT 0,
    distance double precision DEFAULT 0,
    "end" integer,
    energy integer DEFAULT 0,
    max_cadence integer DEFAULT 0,
    max_heartrate integer DEFAULT 0,
    max_power integer,
    max_speed double precision DEFAULT 0,
    "start" integer,
    training_file_id integer,
    workout_id integer
);


--
-- Name: markers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE markers_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: markers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE markers_id_seq OWNED BY markers.id;


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_info (
    version integer
);


--
-- Name: training_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE training_files (
    id integer NOT NULL,
    created_at timestamp without time zone,
    filename character varying(255),
    payload bytea,
    powermeter_properties text,
    workout_id integer
);


--
-- Name: training_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE training_files_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: training_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE training_files_id_seq OWNED BY training_files.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    created_at timestamp without time zone,
    disabled boolean DEFAULT false,
    last_login timestamp without time zone,
    password_hash character varying(255),
    password_salt character varying(255),
    username character varying(255),
    preferences text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: workouts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workouts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    name character varying(255),
    notes text,
    performed_on timestamp without time zone,
    permalink character varying(255),
    uploaded boolean DEFAULT false,
    user_id integer
);


--
-- Name: workouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workouts_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: workouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workouts_id_seq OWNED BY workouts.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE data_values ALTER COLUMN id SET DEFAULT nextval('data_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE markers ALTER COLUMN id SET DEFAULT nextval('markers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE training_files ALTER COLUMN id SET DEFAULT nextval('training_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE workouts ALTER COLUMN id SET DEFAULT nextval('workouts_id_seq'::regclass);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: data_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY data_values
    ADD CONSTRAINT data_values_pkey PRIMARY KEY (id);


--
-- Name: markers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY markers
    ADD CONSTRAINT markers_pkey PRIMARY KEY (id);


--
-- Name: training_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY training_files
    ADD CONSTRAINT training_files_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workouts
    ADD CONSTRAINT workouts_pkey PRIMARY KEY (id);


--
-- Name: index_data_values_on_training_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_data_values_on_training_file_id ON data_values USING btree (training_file_id);


--
-- Name: fk_comments_workout_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_comments_workout_id FOREIGN KEY (workout_id) REFERENCES workouts(id);


--
-- Name: fk_data_values_training_file_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_values
    ADD CONSTRAINT fk_data_values_training_file_id FOREIGN KEY (training_file_id) REFERENCES training_files(id);


--
-- Name: fk_markers_training_file_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY markers
    ADD CONSTRAINT fk_markers_training_file_id FOREIGN KEY (training_file_id) REFERENCES training_files(id);


--
-- Name: fk_markers_workout_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY markers
    ADD CONSTRAINT fk_markers_workout_id FOREIGN KEY (workout_id) REFERENCES workouts(id);


--
-- Name: fk_training_files_workout_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_files
    ADD CONSTRAINT fk_training_files_workout_id FOREIGN KEY (workout_id) REFERENCES workouts(id);


--
-- Name: fk_workouts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workouts
    ADD CONSTRAINT fk_workouts_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_info (version) VALUES (2)