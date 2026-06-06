--
-- PostgreSQL database dump
--

\restrict 0orZMrdhtqtybschasfeMTxJsc4HyKMg0vqK6wIikDHEvTvwCAMa9xMFrn97UJW

-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    user_id integer,
    device_name character varying(100) NOT NULL,
    device_code character varying(50) NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    control_mode character varying(20) DEFAULT 'auto'::character varying NOT NULL,
    heater_state character varying(10) DEFAULT 'OFF'::character varying NOT NULL,
    uv_light_state character varying(10) DEFAULT 'OFF'::character varying NOT NULL,
    fan_state character varying(10) DEFAULT 'OFF'::character varying NOT NULL,
    active_shoe_id integer,
    CONSTRAINT chk_control_mode CHECK (((control_mode)::text = ANY ((ARRAY['auto'::character varying, 'manual'::character varying])::text[]))),
    CONSTRAINT chk_fan_state CHECK (((fan_state)::text = ANY ((ARRAY['ON'::character varying, 'OFF'::character varying])::text[]))),
    CONSTRAINT chk_heater_state CHECK (((heater_state)::text = ANY ((ARRAY['ON'::character varying, 'OFF'::character varying])::text[]))),
    CONSTRAINT chk_uv_light_state CHECK (((uv_light_state)::text = ANY ((ARRAY['ON'::character varying, 'OFF'::character varying])::text[])))
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_id_seq OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: maintenance_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance_logs (
    id integer NOT NULL,
    device_id integer,
    component_name character varying(100),
    issue text,
    action_taken character varying(255) NOT NULL,
    maintenance_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.maintenance_logs OWNER TO postgres;

--
-- Name: maintenance_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maintenance_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.maintenance_logs_id_seq OWNER TO postgres;

--
-- Name: maintenance_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maintenance_logs_id_seq OWNED BY public.maintenance_logs.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    title character varying(100) NOT NULL,
    message text NOT NULL,
    notification_type character varying(20) DEFAULT 'INFO'::character varying,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: predictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.predictions (
    id integer NOT NULL,
    sensor_log_id integer,
    prediction_label character varying(50) NOT NULL,
    confidence_score double precision,
    estimated_drying_time double precision,
    drying_status character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.predictions OWNER TO postgres;

--
-- Name: predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.predictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.predictions_id_seq OWNER TO postgres;

--
-- Name: predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.predictions_id_seq OWNED BY public.predictions.id;


--
-- Name: sensor_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensor_logs (
    id integer NOT NULL,
    shoe_id integer,
    device_id integer,
    temperature double precision NOT NULL,
    humidity double precision NOT NULL,
    gas_level double precision NOT NULL,
    duration_usage double precision DEFAULT 0.0,
    fan_usage_duration double precision DEFAULT 0.0,
    uv_usage_duration double precision DEFAULT 0.0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sensor_logs OWNER TO postgres;

--
-- Name: sensor_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensor_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_logs_id_seq OWNER TO postgres;

--
-- Name: sensor_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensor_logs_id_seq OWNED BY public.sensor_logs.id;


--
-- Name: shoes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shoes (
    id integer NOT NULL,
    user_id integer,
    shoe_name character varying(100) NOT NULL,
    shoe_type character varying(50) NOT NULL,
    shoe_material character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT shoes_shoe_material_check CHECK (((shoe_material)::text = ANY ((ARRAY['Kanvas'::character varying, 'Kulit'::character varying, 'Mesh'::character varying])::text[])))
);


ALTER TABLE public.shoes OWNER TO postgres;

--
-- Name: shoes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shoes_id_seq OWNER TO postgres;

--
-- Name: shoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shoes_id_seq OWNED BY public.shoes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: maintenance_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs ALTER COLUMN id SET DEFAULT nextval('public.maintenance_logs_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: predictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predictions ALTER COLUMN id SET DEFAULT nextval('public.predictions_id_seq'::regclass);


--
-- Name: sensor_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_logs ALTER COLUMN id SET DEFAULT nextval('public.sensor_logs_id_seq'::regclass);


--
-- Name: shoes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shoes ALTER COLUMN id SET DEFAULT nextval('public.shoes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, user_id, device_name, device_code, status, created_at, control_mode, heater_state, uv_light_state, fan_state, active_shoe_id) FROM stdin;
1	1	Pengering Kamar Utama	ESP32-SHOE-001	inactive	2026-05-18 04:57:33.097361	auto	OFF	OFF	OFF	3
\.


--
-- Data for Name: maintenance_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_logs (id, device_id, component_name, issue, action_taken, maintenance_date) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, title, message, notification_type, is_read, created_at) FROM stdin;
1	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:14.950342
2	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:20.225583
3	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:25.502272
4	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:29.216431
5	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:34.462064
6	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:39.750138
7	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:45.023903
8	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:50.28424
9	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:55.561967
10	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:34:59.298114
11	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:04.564539
12	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:09.834927
13	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:15.104146
14	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:20.381158
15	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:24.098702
16	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:29.387826
17	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:34.665415
18	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:39.91571
19	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:45.173887
20	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:50.455123
21	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:54.197595
22	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:35:59.457871
23	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:04.726214
24	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:10.026234
25	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:15.259788
26	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:20.545852
27	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:24.249331
28	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:29.52843
29	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:34.799821
30	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:40.086781
31	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:45.366354
32	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:49.921832
33	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:54.36099
34	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:36:59.630685
35	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:04.913783
36	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:10.176884
37	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:15.456621
38	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:19.181229
39	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:24.447841
40	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:29.712279
41	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:34.981238
42	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:40.263295
43	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:45.532185
44	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:49.244705
45	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:54.520713
46	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:37:59.796124
47	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:05.061627
48	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:10.331562
49	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:15.610757
50	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:19.324856
51	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:24.63315
52	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:29.881139
53	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:35.15043
54	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:40.455151
55	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:44.139645
56	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:49.414054
57	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:54.692611
58	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:38:59.98101
59	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:05.228341
60	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:10.507381
61	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:14.231301
62	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:19.496184
63	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:24.789014
64	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:30.059472
65	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:35.328573
66	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:40.614038
67	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:44.334357
68	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:49.582441
69	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:39:54.865622
70	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:00.134627
71	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:05.404732
72	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:09.113075
73	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:14.382823
74	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:19.673089
75	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:24.937228
76	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:30.226885
77	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:35.505227
78	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:39.208463
79	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:44.496124
80	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:49.761737
81	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:40:55.032437
82	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:00.322428
83	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:05.578851
84	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:09.296607
85	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:14.571599
86	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:19.849826
87	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:25.11909
88	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:30.407524
89	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:34.140092
90	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:39.373259
91	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:44.64406
92	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:49.928303
93	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:41:55.199083
94	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:00.46017
95	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:04.204089
96	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:09.472506
97	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:14.766593
98	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:20.007444
99	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:25.276867
100	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:30.571893
101	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:34.287783
102	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:39.554077
103	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:44.830004
104	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:50.092675
105	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:55.370482
106	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:42:59.08551
107	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:04.36876
108	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:09.629428
109	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:14.895493
110	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:20.177057
111	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:25.442825
112	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:43:29.151907
113	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:22.435186
114	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:26.165592
115	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:31.423378
116	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:36.683489
117	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:41.955324
118	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:47.216875
119	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:52.496422
120	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:44:56.246402
121	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:01.529372
122	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:06.778094
123	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:12.040953
124	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:17.320602
125	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:21.885149
126	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:26.336866
127	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:31.600288
128	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:36.901084
129	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:42.136854
130	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:47.399532
131	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:51.136465
132	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:45:56.412427
133	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:01.673507
134	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:06.955465
135	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:12.216792
136	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:17.486434
137	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:21.205892
138	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:26.496001
139	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:31.755056
140	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:37.03776
141	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:42.299181
142	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:46:47.584382
143	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:12.214939
144	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:15.911461
145	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:21.189101
146	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:26.467893
147	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:31.745
148	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:37.021208
149	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:40.724916
150	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:46.006288
151	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:51.292918
152	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:48:56.538315
153	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:01.819092
154	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:07.089299
155	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:10.808032
156	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:16.076689
157	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:21.355107
158	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:26.615889
159	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:31.901907
160	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:37.180621
161	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:40.895212
162	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:46.16132
163	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:51.442602
164	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:49:56.706824
165	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:01.982984
166	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:06.555924
167	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:10.970011
168	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:16.244812
169	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:21.523448
170	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:26.790033
171	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:32.070614
172	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:35.792177
173	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:41.054568
174	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:46.334011
175	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:51.606755
176	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:50:56.88705
177	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:02.14948
178	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:05.879982
179	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:11.148248
180	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:16.430641
181	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:21.70458
182	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:26.970745
183	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:32.251943
184	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:35.96512
185	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:41.228028
186	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:46.510317
187	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:51.774312
188	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:51:57.047315
189	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:00.768819
190	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:06.047755
191	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:11.308735
192	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:16.581077
193	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:21.859798
194	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:27.132407
195	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:30.856395
196	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:36.124939
197	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:41.401337
198	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:46.66692
199	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:51.938202
200	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:52:57.230486
201	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:00.958063
202	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:06.246745
203	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:11.488752
204	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:16.764166
205	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:22.040458
206	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:25.752709
207	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:31.017602
208	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:36.292559
209	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:41.552203
210	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:46.827768
211	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:52.146123
212	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:53:55.872411
213	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:01.10661
214	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:06.36666
215	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:11.63823
216	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:16.913131
217	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:22.180445
218	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:25.912932
219	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:31.169191
220	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:36.437399
221	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:41.718995
222	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:47.006974
223	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:50.712486
224	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:54:55.991417
225	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:01.252676
226	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:06.534235
227	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:11.802895
228	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:17.081461
229	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:20.804604
230	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:26.075127
231	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:31.34406
232	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:36.638654
233	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:41.914351
234	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:47.200611
235	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:50.884359
236	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:55:56.154257
237	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:01.419669
238	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:06.694799
239	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:11.975027
240	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:16.549683
241	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:20.971213
242	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:26.237976
243	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:31.50688
244	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:36.822309
245	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:42.06825
246	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:45.779895
247	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:51.064961
248	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:56:56.314368
249	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:01.587124
250	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:06.869337
251	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:12.143041
252	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:15.876072
253	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:21.165205
254	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:26.416592
255	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:31.703142
256	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:36.958902
257	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:42.217935
258	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:45.945174
259	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:51.226991
260	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:57:56.505143
261	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:01.75597
262	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:07.046533
263	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:10.87243
264	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:16.085096
265	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:21.34932
266	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:26.617695
267	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:31.883563
268	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:37.146783
269	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:40.858152
270	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:46.124291
271	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:51.395302
272	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:58:56.659213
273	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:01.941836
274	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:07.215701
275	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:10.933128
276	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:16.217124
277	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:21.478451
278	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:26.751179
279	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:32.023399
280	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:35.703834
281	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:40.967624
282	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:46.259092
283	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:51.509516
284	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 12:59:56.802688
285	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:02.071269
286	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:05.827441
287	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:11.095434
288	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:16.367527
289	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:21.660942
290	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:00:26.927319
291	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:05:52.381209
292	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:05:57.656757
293	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:02.963497
294	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:08.235727
295	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:13.521169
296	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:17.203794
297	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:22.474496
298	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:27.737687
299	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:33.020966
300	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:38.312295
301	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:42.011927
302	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:47.287698
303	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:52.543306
304	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:06:57.830587
305	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:03.101246
306	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:08.404418
307	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:12.097842
308	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:17.367403
309	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:22.637128
310	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:27.906845
311	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:33.196725
312	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:38.454931
313	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:42.185834
314	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:47.454573
315	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:52.737863
316	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:07:57.996005
317	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:03.273236
318	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:07.839841
319	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:12.277007
320	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:17.577702
321	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:23.014898
322	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:28.230313
323	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:33.372482
324	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:37.190795
325	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:42.351792
326	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:48.831189
327	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:53.097556
328	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:08:59.169361
329	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:03.440584
330	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:07.180801
331	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:12.442453
332	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:17.705454
333	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:22.988692
334	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:28.253791
335	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:33.538404
336	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:37.256573
337	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:42.525148
338	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:47.793416
339	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:53.068739
340	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:09:58.345288
341	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:02.048367
342	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:07.318205
343	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:12.58762
344	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:17.867593
345	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:23.125014
346	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:10:28.417739
347	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:18.750377
348	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:24.027849
349	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:27.699563
350	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:32.958685
351	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:38.227982
352	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:43.526171
353	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:48.786781
354	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:54.086205
355	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:11:57.825495
356	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:03.077329
357	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:08.384608
358	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:13.648325
359	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:18.918495
360	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:24.187821
361	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:27.918366
362	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:33.187739
363	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:38.442613
364	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:43.743262
365	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:48.992337
366	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:52.718244
367	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:12:57.990836
368	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:03.262121
369	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:08.536234
370	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:13.806282
371	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:19.070891
372	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:22.806784
373	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:28.070805
374	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:33.341534
375	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:38.617199
376	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:43.889587
377	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:49.157683
378	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:52.891078
379	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:13:58.133314
380	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:03.405793
381	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:08.680825
382	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:13.965978
383	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:17.710459
384	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:22.967881
385	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:28.257101
386	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:33.533496
387	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:38.793924
388	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:44.063382
389	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:47.772893
390	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:53.057693
391	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:14:58.322083
392	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:03.614763
393	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:08.87767
394	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:14.165703
395	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:17.876099
396	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:23.132332
397	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:28.414801
398	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:33.687425
399	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:38.958573
400	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:42.665898
401	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:47.958573
402	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:53.23434
403	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:15:58.503586
404	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:03.798313
405	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:09.058159
406	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:12.778945
407	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:18.046379
408	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:23.31664
409	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:28.595024
410	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:33.893861
411	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:39.137632
412	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:42.844824
413	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:48.117817
414	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:53.38245
415	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:16:58.670573
416	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:03.951285
417	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:08.496693
418	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:12.916227
419	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:18.1932
420	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:23.490074
421	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:28.747845
422	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:34.042317
423	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:37.752096
424	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:43.016317
425	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:48.305056
426	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:53.581946
427	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:17:58.831215
428	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:04.125349
429	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:07.810621
430	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:13.083369
431	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:18.3676
432	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:23.62882
433	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:28.898403
434	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:34.171363
435	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:37.912019
436	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:43.180678
437	1	Deteksi Bau Sepatu!	Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.	DANGER	f	2026-06-05 13:18:48.501621
\.


--
-- Data for Name: predictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.predictions (id, sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at) FROM stdin;
1	1	Bau	\N	50.83	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:14.946568
2	2	Bau	\N	50.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:20.221695
3	3	Bau	\N	50.94	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:25.498607
4	4	Bau	\N	50.66	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:29.212299
5	5	Bau	\N	50.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:34.457957
6	6	Bau	\N	50.74	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:39.744127
7	7	Bau	\N	50.85	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:45.020367
8	8	Bau	\N	50.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:50.280858
9	9	Bau	\N	50.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:55.557917
10	10	Bau	\N	50.79	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:34:59.294187
11	11	Bau	\N	51.03	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:04.560378
12	12	Bau	\N	51.15	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:09.831437
13	13	Bau	\N	51.11	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:15.100607
14	14	Bau	\N	50.9	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:20.377964
15	15	Bau	\N	51.09	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:24.094561
16	16	Bau	\N	51.45	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:29.384667
17	17	Bau	\N	51.47	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:34.660172
18	18	Bau	\N	51.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:39.912169
19	19	Bau	\N	51.54	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:45.169836
20	20	Bau	\N	51.41	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:50.451886
21	21	Bau	\N	51.49	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:54.193046
22	22	Bau	\N	51.46	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:35:59.45394
23	23	Bau	\N	51.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:04.722849
24	24	Bau	\N	51.39	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:10.022575
25	25	Bau	\N	51.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:15.256374
26	26	Bau	\N	51.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:20.542122
27	27	Bau	\N	51.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:24.245987
28	28	Bau	\N	51.88	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:29.525144
29	29	Bau	\N	51.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:34.795966
30	30	Bau	\N	51.94	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:40.083187
31	31	Bau	\N	51.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:45.362931
32	32	Bau	\N	51.83	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:49.918589
33	33	Bau	\N	51.83	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:54.357244
34	34	Bau	\N	51.56	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:36:59.626959
35	35	Bau	\N	51.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:04.90864
36	36	Bau	\N	51.73	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:10.173418
37	37	Bau	\N	51.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:15.452644
38	38	Bau	\N	51.88	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:19.17698
39	39	Bau	\N	51.89	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:24.443794
40	40	Bau	\N	51.77	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:29.709384
41	41	Bau	\N	51.75	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:34.977464
42	42	Bau	\N	52.02	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:40.259662
43	43	Bau	\N	52.09	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:45.528498
44	44	Bau	\N	51.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:49.241672
45	45	Bau	\N	52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:54.516764
46	46	Bau	\N	51.67	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:37:59.792178
47	47	Bau	\N	52.15	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:05.057868
48	48	Bau	\N	51.92	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:10.327823
49	49	Bau	\N	52.08	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:15.606872
50	50	Bau	\N	52.19	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:19.321124
51	51	Bau	\N	52.2	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:24.629147
52	52	Bau	\N	51.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:29.876792
53	53	Bau	\N	52.23	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:35.146324
54	54	Bau	\N	52.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:40.447971
55	55	Bau	\N	52.17	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:44.135932
56	56	Bau	\N	52.15	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:49.410376
57	57	Bau	\N	52.37	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:54.687565
58	58	Bau	\N	52.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:38:59.973226
59	59	Bau	\N	52.32	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:05.224002
60	60	Bau	\N	52.51	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:10.503683
61	61	Bau	\N	52.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:14.227937
62	62	Bau	\N	52.41	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:19.491753
63	63	Bau	\N	52.37	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:24.784768
64	64	Bau	\N	52.4	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:30.055345
65	65	Bau	\N	52.41	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:35.324376
66	66	Bau	\N	52.33	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:40.61022
67	67	Bau	\N	52.47	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:44.330303
68	68	Bau	\N	52.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:49.57865
69	69	Bau	\N	52.36	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:39:54.862433
70	70	Bau	\N	52.22	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:00.130475
71	71	Bau	\N	52.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:05.400869
72	72	Bau	\N	52.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:09.109127
73	73	Bau	\N	52.45	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:14.378668
74	74	Bau	\N	52.5	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:19.669175
75	75	Bau	\N	52.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:24.933607
76	76	Bau	\N	52.26	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:30.222875
77	77	Bau	\N	52.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:35.501689
78	78	Bau	\N	52.41	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:39.204295
79	79	Bau	\N	52.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:44.492134
80	80	Bau	\N	52.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:49.757468
81	81	Bau	\N	52.74	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:40:55.0284
82	82	Bau	\N	52.8	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:00.317895
83	83	Bau	\N	52.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:05.574836
84	84	Bau	\N	52.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:09.293322
85	85	Bau	\N	52.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:14.568647
86	86	Bau	\N	52.73	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:19.8464
87	87	Bau	\N	52.54	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:25.115461
88	88	Bau	\N	52.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:30.402781
89	89	Bau	\N	52.54	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:34.13433
90	90	Bau	\N	52.59	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:39.36938
91	91	Bau	\N	52.66	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:44.640503
92	92	Bau	\N	52.7	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:49.924993
93	93	Bau	\N	52.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:41:55.195311
94	94	Bau	\N	52.3	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:00.457008
95	95	Bau	\N	52.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:04.200204
96	96	Bau	\N	52.8	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:09.468842
97	97	Bau	\N	52.59	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:14.761845
98	98	Bau	\N	52.4	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:20.004009
99	99	Bau	\N	52.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:25.272323
100	100	Bau	\N	52.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:30.567464
101	101	Bau	\N	52.57	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:34.281323
102	102	Bau	\N	52.66	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:39.548589
103	103	Bau	\N	52.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:44.825241
104	104	Bau	\N	52.9	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:50.089258
105	105	Bau	\N	52.63	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:55.367352
106	106	Bau	\N	52.89	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:42:59.081649
107	107	Bau	\N	52.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:04.365941
108	108	Bau	\N	52.87	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:09.625466
109	109	Bau	\N	52.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:14.891489
110	110	Bau	\N	52.79	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:20.173668
111	111	Bau	\N	52.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:25.438656
112	112	Bau	\N	52.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:43:29.148374
113	113	Bau	\N	53.64	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:22.431256
114	114	Bau	\N	53.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:26.161731
115	115	Bau	\N	53.33	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:31.420103
116	116	Bau	\N	53.17	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:36.679423
117	117	Bau	\N	53.28	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:41.951955
118	118	Bau	\N	53.21	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:47.211751
119	119	Bau	\N	53.17	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:52.493296
120	120	Bau	\N	53.25	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:44:56.242686
121	121	Bau	\N	53.28	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:01.525484
122	122	Bau	\N	53.06	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:06.774271
123	123	Bau	\N	53.16	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:12.037217
124	124	Bau	\N	52.94	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:17.313256
125	125	Bau	\N	52.85	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:21.881275
126	126	Bau	\N	52.62	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:26.328588
127	127	Bau	\N	52.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:31.596049
128	128	Bau	\N	52.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:36.896096
129	129	Bau	\N	52.75	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:42.133364
130	130	Bau	\N	52.71	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:47.394269
131	131	Bau	\N	52.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:51.132717
132	132	Bau	\N	52.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:45:56.408002
133	133	Bau	\N	53.04	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:01.670135
134	134	Bau	\N	53.28	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:06.948546
135	135	Bau	\N	53	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:12.213255
136	136	Bau	\N	52.85	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:17.482264
137	137	Bau	\N	53.14	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:21.202096
138	138	Bau	\N	53.18	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:26.492016
139	139	Bau	\N	52.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:31.750742
140	140	Bau	\N	52.81	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:37.033779
141	141	Bau	\N	52.67	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:42.295569
142	142	Bau	\N	52.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:46:47.579796
143	143	Bau	\N	54.16	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:12.209055
144	144	Bau	\N	53.61	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:15.907463
145	145	Bau	\N	53.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:21.18547
146	146	Bau	\N	54.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:26.463479
147	147	Bau	\N	54.14	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:31.741224
148	148	Bau	\N	53.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:37.016249
149	149	Bau	\N	53.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:40.721147
150	150	Bau	\N	53.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:46.002589
151	151	Bau	\N	53.91	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:51.288168
152	152	Bau	\N	53.86	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:48:56.534452
153	153	Bau	\N	53.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:01.81575
154	154	Bau	\N	54.42	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:07.083239
155	155	Bau	\N	54.12	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:10.804165
156	156	Bau	\N	54	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:16.074196
157	157	Bau	\N	53.77	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:21.352052
158	158	Bau	\N	53.92	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:26.612367
159	159	Bau	\N	53.97	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:31.898554
160	160	Bau	\N	54.07	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:37.175674
161	161	Bau	\N	54.43	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:40.891437
162	162	Bau	\N	54.39	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:46.157191
163	163	Bau	\N	54.2	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:51.439083
164	164	Bau	\N	54.48	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:49:56.703035
165	165	Bau	\N	53.85	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:01.978608
166	166	Bau	\N	53.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:06.55154
167	167	Bau	\N	54.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:10.966645
168	168	Bau	\N	55.51	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:16.240744
169	169	Bau	\N	55.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:21.520141
170	170	Bau	\N	55.34	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:26.786944
171	171	Bau	\N	55.11	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:32.066422
172	172	Bau	\N	54.43	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:35.788556
173	173	Bau	\N	54.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:41.051083
174	174	Bau	\N	54.38	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:46.329778
175	175	Bau	\N	54.36	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:51.603018
176	176	Bau	\N	54.42	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:50:56.883182
177	177	Bau	\N	54.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:02.145646
178	178	Bau	\N	54.67	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:05.872151
179	179	Bau	\N	54.46	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:11.145101
180	180	Bau	\N	54.4	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:16.427066
181	181	Bau	\N	54.42	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:21.700945
182	182	Bau	\N	54.97	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:26.966699
183	183	Bau	\N	54.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:32.248263
184	184	Bau	\N	55.32	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:35.960247
185	185	Bau	\N	55.14	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:41.223511
186	186	Bau	\N	55.18	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:46.506208
187	187	Bau	\N	55.59	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:51.769903
188	188	Bau	\N	55.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:51:57.044004
189	189	Bau	\N	55.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:00.765474
190	190	Bau	\N	56.16	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:06.043908
191	191	Bau	\N	56.47	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:11.30473
192	192	Bau	\N	56.34	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:16.576765
193	193	Bau	\N	55.66	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:21.855583
194	194	Bau	\N	55.45	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:27.1284
195	195	Bau	\N	55.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:30.852761
196	196	Bau	\N	55.47	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:36.121199
197	197	Bau	\N	55.36	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:41.396411
198	198	Bau	\N	55.38	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:46.662948
199	199	Bau	\N	55.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:51.934031
200	200	Bau	\N	55.23	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:52:57.226264
201	201	Bau	\N	55.48	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:00.953198
202	202	Bau	\N	55.53	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:06.242984
203	203	Bau	\N	55.91	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:11.485335
204	204	Bau	\N	56.5	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:16.760821
205	205	Bau	\N	56.42	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:22.03618
206	206	Bau	\N	57.04	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:25.747669
207	207	Bau	\N	57.19	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:31.014074
208	208	Bau	\N	56.96	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:36.28737
209	209	Bau	\N	57.03	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:41.547682
210	210	Bau	\N	56.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:46.823346
211	211	Bau	\N	56.64	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:52.140477
212	212	Bau	\N	56.7	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:53:55.866176
213	213	Bau	\N	57.09	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:01.102634
214	214	Bau	\N	57.5	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:06.363732
215	215	Bau	\N	57.96	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:11.634343
216	216	Bau	\N	58.05	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:16.906962
217	217	Bau	\N	57.86	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:22.176831
218	218	Bau	\N	57	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:25.908756
219	219	Bau	\N	55.83	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:31.16541
220	220	Bau	\N	56.66	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:36.433486
221	221	Bau	\N	56.68	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:41.715795
222	222	Bau	\N	56.53	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:47.002389
223	223	Bau	\N	57.94	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:50.709135
224	224	Bau	\N	58.36	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:54:55.987523
225	225	Bau	\N	57.97	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:01.249249
226	226	Bau	\N	56.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:06.530096
227	227	Bau	\N	56.93	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:11.799249
228	228	Bau	\N	57.29	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:17.077878
229	229	Bau	\N	58.02	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:20.80126
230	230	Bau	\N	58.26	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:26.071467
231	231	Bau	\N	57.93	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:31.340666
232	232	Bau	\N	58.31	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:36.635213
233	233	Bau	\N	57.81	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:41.911288
234	234	Bau	\N	57.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:47.197662
235	235	Bau	\N	56.48	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:50.880533
236	236	Bau	\N	57.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:55:56.151038
237	237	Bau	\N	58.43	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:01.416029
238	238	Bau	\N	59.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:06.691428
239	239	Bau	\N	60	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:11.971255
240	240	Bau	\N	60.31	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:16.545912
241	241	Bau	\N	60.19	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:20.967314
242	242	Bau	\N	61.06	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:26.234023
243	243	Bau	\N	61.19	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:31.503759
244	244	Bau	\N	61.72	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:36.817575
245	245	Bau	\N	62.15	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:42.063671
246	246	Bau	\N	62.46	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:45.7762
247	247	Bau	\N	62.63	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:51.059799
248	248	Bau	\N	62.71	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:56:56.310878
249	249	Bau	\N	62.22	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:01.583409
250	250	Bau	\N	62.01	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:06.866019
251	251	Bau	\N	61.45	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:12.13942
252	252	Bau	\N	61.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:15.871562
253	253	Bau	\N	62.2	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:21.160568
254	254	Bau	\N	62.39	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:26.411812
255	255	Bau	\N	62.07	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:31.69822
256	256	Bau	\N	61.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:36.95556
257	257	Bau	\N	63.01	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:42.214679
258	258	Bau	\N	63.22	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:45.941351
259	259	Bau	\N	63.29	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:51.222999
260	260	Bau	\N	63.34	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:57:56.501621
261	261	Bau	\N	63.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:01.752644
262	262	Bau	\N	63.67	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:07.041621
263	263	Bau	\N	61.68	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:10.867765
264	264	Bau	\N	58.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:16.080208
265	265	Bau	\N	56.49	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:21.342247
266	266	Bau	\N	54.08	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:26.613559
267	267	Bau	\N	51.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:31.880325
268	268	Bau	\N	49.33	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:37.142742
269	269	Bau	\N	47.07	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:40.853302
270	270	Bau	\N	43.87	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:46.119896
271	271	Bau	\N	46.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:51.391529
272	272	Bau	\N	46.53	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:58:56.65575
273	273	Bau	\N	45.05	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:59:01.938058
274	274	Bau	\N	44.34	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:59:07.211873
275	275	Bau	\N	43.31	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 12:59:10.93006
276	276	Bau	\N	42.59	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:16.211935
277	277	Bau	\N	40.84	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:21.475251
278	278	Bau	\N	39.68	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:26.74756
279	279	Bau	\N	38.95	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:32.020151
280	280	Bau	\N	38.23	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:35.699526
281	281	Bau	\N	37.64	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:40.964267
282	282	Bau	\N	36.28	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:46.255221
283	283	Bau	\N	35.32	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:51.506146
284	284	Bau	\N	34.75	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 12:59:56.799347
285	285	Bau	\N	34.23	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:02.067723
286	286	Bau	\N	33.17	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:05.82361
287	287	Bau	\N	32.7	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:11.090681
288	288	Bau	\N	31.87	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:16.363337
289	289	Bau	\N	31.72	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:21.656232
290	290	Bau	\N	31.28	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:26.923785
291	291	Wangi	\N	30.73	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:32.195439
292	292	Wangi	\N	30.13	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:35.90472
293	293	Wangi	\N	29.71	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:41.170045
294	294	Wangi	\N	29.57	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:46.460878
295	295	Wangi	\N	29.29	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:51.751896
296	296	Wangi	\N	29.07	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:00:57.031811
297	297	Wangi	\N	28.82	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:00.707542
298	298	Wangi	\N	28.67	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:05.972912
299	299	Wangi	\N	28.39	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:11.264835
300	300	Wangi	\N	27.87	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:16.524308
301	301	Wangi	\N	27.99	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:21.786436
302	302	Wangi	\N	27.59	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:27.086043
303	303	Wangi	\N	27.37	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:30.804535
304	304	Wangi	\N	26.67	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:36.086199
305	305	Wangi	\N	26.79	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:41.341874
306	306	Wangi	\N	27.05	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:46.616303
307	307	Wangi	\N	26.43	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:51.882424
308	308	Wangi	\N	26.16	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:01:57.171551
309	309	Wangi	\N	26.34	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:00.899162
310	310	Wangi	\N	26.01	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:06.160259
311	311	Wangi	\N	26.11	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:11.428031
312	312	Wangi	\N	26.26	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:16.694776
313	313	Wangi	\N	25.82	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:21.971608
314	314	Wangi	\N	25.6	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:25.712576
315	315	Wangi	\N	25.88	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:30.971502
316	316	Wangi	\N	25.27	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:36.237383
317	317	Wangi	\N	25.26	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:41.514277
318	318	Wangi	\N	25.32	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:46.789163
319	319	Wangi	\N	25.1	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:52.065478
320	320	Wangi	\N	25.32	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:02:55.780527
321	321	Wangi	\N	25	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:01.053134
322	322	Wangi	\N	24.54	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:06.327647
323	323	Wangi	\N	24.82	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:11.584043
324	324	Wangi	\N	24.98	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:16.881474
325	325	Wangi	\N	24.9	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:22.127664
326	326	Wangi	\N	24.84	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:25.863517
327	327	Wangi	\N	24.69	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:31.125503
328	328	Wangi	\N	24.43	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:03:36.41303
329	329	Wangi	\N	27.63	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:32.88601
330	330	Wangi	\N	27.78	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:38.152807
331	331	Wangi	\N	28.42	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:43.422524
332	332	Wangi	\N	28.88	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:47.104288
333	333	Bau	\N	29.12	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:52.377758
334	334	Bau	\N	29.4	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:05:57.649518
335	335	Bau	\N	29.88	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:02.957651
336	336	Bau	\N	30.06	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:08.231394
337	337	Bau	\N	30.52	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:13.518193
338	338	Bau	\N	30.91	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:17.199674
339	339	Bau	\N	34.16	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:22.471081
340	340	Bau	\N	42.97	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:27.733556
341	341	Bau	\N	38.28	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:33.016897
342	342	Bau	\N	37.22	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:38.308011
343	343	Bau	\N	37.04	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:42.008731
344	344	Bau	\N	36.16	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:47.282707
345	345	Bau	\N	36.5	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:52.539149
346	346	Bau	\N	36.07	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:06:57.826542
347	347	Bau	\N	36.14	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:03.096777
348	348	Bau	\N	36.11	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:08.400292
349	349	Bau	\N	36.21	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:12.09466
350	350	Bau	\N	36.47	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:17.363451
351	351	Bau	\N	36.52	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:22.633435
352	352	Bau	\N	36.92	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:27.902768
353	353	Bau	\N	37.33	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:33.192985
354	354	Bau	\N	37.15	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:38.451038
355	355	Bau	\N	37.27	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:42.182323
356	356	Bau	\N	37.77	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:47.45127
357	357	Bau	\N	37.97	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:52.730386
358	358	Bau	\N	37.86	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:07:57.992487
359	359	Bau	\N	37.91	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:03.269192
360	360	Bau	\N	38.16	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:07.836147
361	361	Bau	\N	38.63	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:12.274321
362	362	Bau	\N	39.11	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:17.574299
363	363	Bau	\N	38.57	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:23.010814
364	364	Bau	\N	39.21	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:28.226944
365	365	Bau	\N	39.34	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:33.366803
366	366	Bau	\N	39.55	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:37.185832
367	367	Bau	\N	39.59	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:42.347366
368	368	Bau	\N	39.79	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:48.826553
369	369	Bau	\N	39.99	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:53.094432
370	370	Bau	\N	40.25	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:08:59.163353
371	371	Bau	\N	40.12	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:09:03.435657
372	372	Bau	\N	40.27	Sedang dikeringkan (Kondisi sepatu hampir kering)	2026-06-05 13:09:07.175483
373	373	Bau	\N	40.64	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:12.438229
374	374	Bau	\N	41.05	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:17.700374
375	375	Bau	\N	41.27	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:22.984817
376	376	Bau	\N	41.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:28.24996
377	377	Bau	\N	41.09	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:33.531698
378	378	Bau	\N	41.21	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:37.252284
379	379	Bau	\N	41.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:42.521439
380	380	Bau	\N	41.37	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:47.789517
381	381	Bau	\N	41.69	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:53.064865
382	382	Bau	\N	41.48	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:09:58.341468
383	383	Bau	\N	41.62	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:02.04449
384	384	Bau	\N	41.55	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:07.314209
385	385	Bau	\N	41.79	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:12.584115
386	386	Bau	\N	41.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:17.86389
387	387	Bau	\N	41.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:23.12091
388	388	Bau	\N	42.06	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:10:28.413232
389	389	Bau	\N	45.37	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:18.747091
390	390	Bau	\N	45.76	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:24.023711
391	391	Bau	\N	45.17	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:27.694597
392	392	Bau	\N	45.59	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:32.955225
393	393	Bau	\N	45.64	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:38.22495
394	394	Bau	\N	46.08	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:43.521142
395	395	Bau	\N	46.25	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:48.782984
396	396	Bau	\N	46.51	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:54.081515
397	397	Bau	\N	46.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:11:57.822194
398	398	Bau	\N	46.68	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:03.073775
399	399	Bau	\N	46.9	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:08.379435
400	400	Bau	\N	47.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:13.644447
401	401	Bau	\N	47.93	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:18.914327
402	402	Bau	\N	48.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:24.183716
403	403	Bau	\N	48.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:27.914552
404	404	Bau	\N	48.35	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:33.181584
405	405	Bau	\N	48.1	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:38.437879
406	406	Bau	\N	48.31	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:43.739844
407	407	Bau	\N	48.14	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:48.988475
408	408	Bau	\N	48.38	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:52.714393
409	409	Bau	\N	48.19	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:12:57.987726
410	410	Bau	\N	48.12	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:03.256242
411	411	Bau	\N	48.3	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:08.531497
412	412	Bau	\N	48.52	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:13.802432
413	413	Bau	\N	48.28	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:19.063931
414	414	Bau	\N	48	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:22.802938
415	415	Bau	\N	48.21	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:28.067431
416	416	Bau	\N	47.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:33.336368
417	417	Bau	\N	48.09	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:38.613874
418	418	Bau	\N	47.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:43.883877
419	419	Bau	\N	47.79	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:49.154415
420	420	Bau	\N	47.8	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:52.879753
421	421	Bau	\N	55.91	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:13:58.130516
422	422	Bau	\N	60.56	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:03.401429
423	423	Bau	\N	56.43	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:08.676986
424	424	Bau	\N	54.1	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:13.962143
425	425	Bau	\N	52.85	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:17.706884
426	426	Bau	\N	51.43	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:22.964116
427	427	Bau	\N	50.73	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:28.250743
428	428	Bau	\N	49.91	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:33.529473
429	429	Bau	\N	49.75	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:38.789092
430	430	Bau	\N	49.57	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:44.059159
431	431	Bau	\N	49.15	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:47.769753
432	432	Bau	\N	48.91	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:53.053844
433	433	Bau	\N	48.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:14:58.318364
434	434	Bau	\N	48.53	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:03.610403
435	435	Bau	\N	48.31	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:08.874202
436	436	Bau	\N	48.01	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:14.161951
437	437	Bau	\N	47.76	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:17.870192
438	438	Bau	\N	47.77	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:23.128527
439	439	Bau	\N	47.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:28.411277
440	440	Bau	\N	47.58	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:33.683122
441	441	Bau	\N	47.6	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:38.954927
442	442	Bau	\N	47.34	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:42.662456
443	443	Bau	\N	47.11	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:47.954631
444	444	Bau	\N	47.13	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:53.230585
445	445	Bau	\N	47.23	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:15:58.499894
446	446	Bau	\N	47.25	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:03.790192
447	447	Bau	\N	47.28	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:09.054588
448	448	Bau	\N	47.01	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:12.774794
449	449	Bau	\N	47.3	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:18.042282
450	450	Bau	\N	47.32	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:23.313084
451	451	Bau	\N	47.44	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:28.590396
452	452	Bau	\N	47.11	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:33.890046
453	453	Bau	\N	47.14	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:39.132829
454	454	Bau	\N	47.2	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:42.841689
455	455	Bau	\N	47.27	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:48.113743
456	456	Bau	\N	47.49	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:53.37925
457	457	Bau	\N	47.07	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:16:58.667619
458	458	Bau	\N	46.99	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:03.947835
459	459	Bau	\N	46.89	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:08.493206
460	460	Bau	\N	46.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:12.91295
461	461	Bau	\N	46.8	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:18.189877
462	462	Bau	\N	46.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:23.486794
463	463	Bau	\N	46.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:28.743583
464	464	Bau	\N	46.65	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:34.037298
465	465	Bau	\N	46.89	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:37.747425
466	466	Bau	\N	46.94	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:43.01079
467	467	Bau	\N	46.78	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:48.300761
468	468	Bau	\N	47.02	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:53.57726
469	469	Bau	\N	46.79	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:17:58.827727
470	470	Bau	\N	46.87	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:04.121463
471	471	Bau	\N	46.82	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:07.804575
472	472	Bau	\N	46.8	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:13.079419
473	473	Bau	\N	46.74	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:18.363473
474	474	Bau	\N	46.62	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:23.624604
475	475	Bau	\N	46.84	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:28.895035
476	476	Bau	\N	47.22	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:34.165585
477	477	Bau	\N	46.95	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:37.907709
478	478	Bau	\N	46.98	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:43.177032
479	479	Bau	\N	46.96	Sedang dikeringkan (Kondisi sepatu masih sangat basah)	2026-06-05 13:18:48.496654
\.


--
-- Data for Name: sensor_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sensor_logs (id, shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at) FROM stdin;
1	1	1	28.3	73.5	159.78	0.49	0.29	0.1	2026-06-05 12:34:14.921349
2	1	1	28.3	73.4	166.15	0.49	0.29	0.1	2026-06-05 12:34:20.194121
3	1	1	28.3	73.4	165.27	0.49	0.29	0.1	2026-06-05 12:34:25.472819
4	1	1	28.2	73.4	160	0.5	0.29	0.1	2026-06-05 12:34:29.1812
5	1	1	28.3	73.5	163.52	0.5	0.29	0.1	2026-06-05 12:34:34.44627
6	1	1	28.2	73.5	159.34	0.5	0.29	0.1	2026-06-05 12:34:39.718437
7	1	1	28.2	73.5	162.2	0.5	0.29	0.1	2026-06-05 12:34:44.997075
8	1	1	28.2	73.4	159.78	0.5	0.29	0.1	2026-06-05 12:34:50.262089
9	1	1	28.1	73.5	163.3	0.5	0.29	0.1	2026-06-05 12:34:55.533711
10	1	1	28.1	73.6	160.22	0.5	0.29	0.1	2026-06-05 12:34:59.269873
11	1	1	28.1	73.7	163.96	0.51	0.29	0.1	2026-06-05 12:35:04.547287
12	1	1	28.1	73.7	167.03	0.51	0.29	0.1	2026-06-05 12:35:09.805323
13	1	1	28.1	73.8	163.52	0.51	0.29	0.1	2026-06-05 12:35:15.084092
14	1	1	28	73.8	160.22	0.51	0.29	0.1	2026-06-05 12:35:20.363136
15	1	1	28	73.9	162.64	0.51	0.29	0.1	2026-06-05 12:35:24.078147
16	1	1	28	74	169.45	0.51	0.29	0.1	2026-06-05 12:35:29.357166
17	1	1	28	74.1	167.47	0.51	0.29	0.1	2026-06-05 12:35:34.639741
18	1	1	28	74.2	168.57	0.52	0.29	0.1	2026-06-05 12:35:39.896957
19	1	1	28	74.3	164.62	0.52	0.29	0.1	2026-06-05 12:35:45.15669
20	1	1	27.9	74.3	163.08	0.52	0.29	0.1	2026-06-05 12:35:50.436105
21	1	1	27.9	74.5	160.44	0.52	0.29	0.1	2026-06-05 12:35:54.161287
22	1	1	27.9	74.5	159.78	0.52	0.29	0.1	2026-06-05 12:35:59.428586
23	1	1	27.8	74.6	156.26	0.52	0.29	0.1	2026-06-05 12:36:04.709874
24	1	1	27.8	74.7	154.95	0.53	0.29	0.1	2026-06-05 12:36:09.994586
25	1	1	27.8	74.7	161.76	0.53	0.29	0.1	2026-06-05 12:36:15.244275
26	1	1	27.8	74.7	163.52	0.53	0.29	0.1	2026-06-05 12:36:20.522334
27	1	1	27.8	74.7	158.46	0.53	0.29	0.1	2026-06-05 12:36:24.23123
28	1	1	27.8	74.7	167.47	0.53	0.29	0.1	2026-06-05 12:36:29.507827
29	1	1	27.8	74.7	159.12	0.53	0.29	0.1	2026-06-05 12:36:34.779499
30	1	1	27.8	74.8	166.81	0.53	0.29	0.1	2026-06-05 12:36:40.056078
31	1	1	27.7	74.8	160	0.54	0.29	0.1	2026-06-05 12:36:45.340486
32	1	1	27.7	74.9	163.52	0.54	0.29	0.1	2026-06-05 12:36:49.903819
33	1	1	27.7	75	161.1	0.54	0.29	0.1	2026-06-05 12:36:54.335188
34	1	1	27.7	74.9	156.48	0.54	0.29	0.1	2026-06-05 12:36:59.600779
35	1	1	27.7	75	159.78	0.54	0.29	0.1	2026-06-05 12:37:04.877807
36	1	1	27.7	75.1	156.04	0.54	0.29	0.1	2026-06-05 12:37:10.148501
37	1	1	27.7	75.1	161.76	0.54	0.29	0.1	2026-06-05 12:37:15.423171
38	1	1	27.7	75.1	160	0.55	0.29	0.1	2026-06-05 12:37:19.157089
39	1	1	27.7	75.2	157.8	0.55	0.29	0.1	2026-06-05 12:37:24.419305
40	1	1	27.6	75.2	156.7	0.55	0.29	0.1	2026-06-05 12:37:29.685965
41	1	1	27.6	75.2	156.26	0.55	0.29	0.1	2026-06-05 12:37:34.961907
42	1	1	27.6	75.3	160.66	0.55	0.29	0.1	2026-06-05 12:37:40.239972
43	1	1	27.6	75.4	160.22	0.55	0.29	0.1	2026-06-05 12:37:45.510083
44	1	1	27.6	75.4	157.36	0.56	0.29	0.1	2026-06-05 12:37:49.224505
45	1	1	27.6	75.4	157.8	0.56	0.29	0.1	2026-06-05 12:37:54.500482
46	1	1	27.6	75.5	147.03	0.56	0.29	0.1	2026-06-05 12:37:59.775079
47	1	1	27.6	75.5	159.34	0.56	0.29	0.1	2026-06-05 12:38:05.040315
48	1	1	27.6	75.5	153.41	0.56	0.29	0.1	2026-06-05 12:38:10.313914
49	1	1	27.5	75.5	159.34	0.56	0.29	0.1	2026-06-05 12:38:15.590076
50	1	1	27.5	75.6	159.78	0.56	0.29	0.1	2026-06-05 12:38:19.304212
51	1	1	27.5	75.7	157.58	0.57	0.29	0.1	2026-06-05 12:38:24.614709
52	1	1	27.5	75.6	154.73	0.57	0.29	0.1	2026-06-05 12:38:29.855662
53	1	1	27.5	75.7	158.46	0.57	0.29	0.1	2026-06-05 12:38:35.129871
54	1	1	27.5	75.7	161.54	0.57	0.29	0.1	2026-06-05 12:38:40.433021
55	1	1	27.5	75.7	156.92	0.57	0.29	0.1	2026-06-05 12:38:44.112948
56	1	1	27.5	75.8	154.07	0.57	0.29	0.1	2026-06-05 12:38:49.394355
57	1	1	27.5	75.8	159.78	0.57	0.29	0.1	2026-06-05 12:38:54.663649
58	1	1	27.5	75.9	162.64	0.58	0.29	0.1	2026-06-05 12:38:59.94257
59	1	1	27.5	75.8	158.46	0.58	0.29	0.1	2026-06-05 12:39:05.206828
60	1	1	27.5	75.8	163.3	0.58	0.29	0.1	2026-06-05 12:39:10.489099
61	1	1	27.5	75.8	159.12	0.58	0.29	0.1	2026-06-05 12:39:14.214029
62	1	1	27.5	75.8	160.66	0.58	0.29	0.1	2026-06-05 12:39:19.473776
63	1	1	27.5	75.8	159.78	0.58	0.29	0.1	2026-06-05 12:39:24.755134
64	1	1	27.5	75.8	160.44	0.58	0.29	0.1	2026-06-05 12:39:30.029532
65	1	1	27.5	75.9	158.24	0.59	0.29	0.1	2026-06-05 12:39:35.31097
66	1	1	27.5	75.8	158.68	0.59	0.29	0.1	2026-06-05 12:39:40.58557
67	1	1	27.5	75.9	159.78	0.59	0.29	0.1	2026-06-05 12:39:44.286493
68	1	1	27.5	76	166.37	0.59	0.29	0.1	2026-06-05 12:39:49.562185
69	1	1	27.5	76	154.73	0.59	0.29	0.1	2026-06-05 12:39:54.840927
70	1	1	27.4	76	152.97	0.59	0.29	0.1	2026-06-05 12:40:00.109056
71	1	1	27.5	75.9	161.1	0.6	0.29	0.1	2026-06-05 12:40:05.382219
72	1	1	27.4	76	167.25	0.6	0.29	0.1	2026-06-05 12:40:09.092926
73	1	1	27.4	76	158.9	0.6	0.29	0.1	2026-06-05 12:40:14.366101
74	1	1	27.4	76	160.22	0.6	0.29	0.1	2026-06-05 12:40:19.643245
75	1	1	27.4	76	156.26	0.6	0.29	0.1	2026-06-05 12:40:24.917636
76	1	1	27.4	76	154.07	0.6	0.29	0.1	2026-06-05 12:40:30.19987
77	1	1	27.5	76.1	159.78	0.6	0.29	0.1	2026-06-05 12:40:35.475893
78	1	1	27.4	76.1	155.38	0.61	0.29	0.1	2026-06-05 12:40:39.186285
79	1	1	27.4	76.1	159.78	0.61	0.29	0.1	2026-06-05 12:40:44.46408
80	1	1	27.5	76.1	161.54	0.61	0.29	0.1	2026-06-05 12:40:49.730773
81	1	1	27.5	76.1	161.98	0.61	0.29	0.1	2026-06-05 12:40:55.009972
82	1	1	27.4	76.1	165.49	0.61	0.29	0.1	2026-06-05 12:41:00.281718
83	1	1	27.4	76.1	163.3	0.61	0.29	0.1	2026-06-05 12:41:05.556828
84	1	1	27.4	76.2	166.81	0.61	0.29	0.1	2026-06-05 12:41:09.268031
85	1	1	27.4	76.1	162.64	0.62	0.29	0.1	2026-06-05 12:41:14.547922
86	1	1	27.4	76.1	163.52	0.62	0.29	0.1	2026-06-05 12:41:19.815899
87	1	1	27.4	76.1	158.9	0.62	0.29	0.1	2026-06-05 12:41:25.09334
88	1	1	27.4	76.1	159.12	0.62	0.29	0.1	2026-06-05 12:41:30.379077
89	1	1	27.4	76.1	158.9	0.62	0.29	0.1	2026-06-05 12:41:34.106005
90	1	1	27.4	76.1	160	0.62	0.29	0.1	2026-06-05 12:41:39.354148
91	1	1	27.4	76.2	159.56	0.63	0.29	0.1	2026-06-05 12:41:44.626118
92	1	1	27.4	76.1	162.86	0.63	0.29	0.1	2026-06-05 12:41:49.895843
93	1	1	27.4	76.1	159.78	0.63	0.29	0.1	2026-06-05 12:41:55.172181
94	1	1	27.4	76.1	152.75	0.63	0.29	0.1	2026-06-05 12:42:00.442771
95	1	1	27.4	76	161.54	0.63	0.29	0.1	2026-06-05 12:42:04.170943
96	1	1	27.3	76.1	167.25	0.63	0.29	0.1	2026-06-05 12:42:09.444707
97	1	1	27.4	76.1	160	0.63	0.29	0.1	2026-06-05 12:42:14.728491
98	1	1	27.4	76.1	155.16	0.64	0.29	0.1	2026-06-05 12:42:19.987801
99	1	1	27.4	76.1	159.78	0.64	0.29	0.1	2026-06-05 12:42:25.258045
100	1	1	27.4	76.1	159.78	0.64	0.29	0.1	2026-06-05 12:42:30.533964
101	1	1	27.4	76.2	157.14	0.64	0.29	0.1	2026-06-05 12:42:34.250696
102	1	1	27.4	76.2	159.34	0.64	0.29	0.1	2026-06-05 12:42:39.517937
103	1	1	27.4	76.2	160.22	0.64	0.29	0.1	2026-06-05 12:42:44.797737
104	1	1	27.4	76.3	163.3	0.64	0.29	0.1	2026-06-05 12:42:50.073488
105	1	1	27.3	76.3	158.24	0.65	0.29	0.1	2026-06-05 12:42:55.351901
106	1	1	27.3	76.2	167.25	0.65	0.29	0.1	2026-06-05 12:42:59.066332
107	1	1	27.3	76.2	159.78	0.65	0.29	0.1	2026-06-05 12:43:04.345218
108	1	1	27.3	76.2	166.81	0.65	0.29	0.1	2026-06-05 12:43:09.610628
109	1	1	27.4	76.2	160.88	0.65	0.29	0.1	2026-06-05 12:43:14.878126
110	1	1	27.3	76.3	162.42	0.65	0.29	0.1	2026-06-05 12:43:20.150466
111	1	1	27.3	76.3	160.44	0.65	0.29	0.1	2026-06-05 12:43:25.422068
112	1	1	27.3	76.4	159.78	0.66	0.29	0.1	2026-06-05 12:43:29.13401
113	1	1	27.5	77.2	158.68	0.58	0.29	0.1	2026-06-05 12:44:22.408831
114	1	1	27.5	76.9	167.25	0.58	0.29	0.1	2026-06-05 12:44:26.134232
115	1	1	27.5	76.7	162.86	0.58	0.29	0.1	2026-06-05 12:44:31.397579
116	1	1	27.5	76.6	161.1	0.58	0.29	0.1	2026-06-05 12:44:36.653496
117	1	1	27.5	76.5	166.37	0.59	0.29	0.1	2026-06-05 12:44:41.924293
118	1	1	27.6	76.5	162.64	0.59	0.29	0.1	2026-06-05 12:44:47.19316
119	1	1	27.6	76.4	163.96	0.59	0.29	0.1	2026-06-05 12:44:52.473278
120	1	1	27.6	76.5	163.52	0.59	0.29	0.1	2026-06-05 12:44:56.211352
121	1	1	27.6	76.5	164.4	0.59	0.29	0.1	2026-06-05 12:45:01.511207
122	1	1	27.6	76.4	161.1	0.59	0.29	0.1	2026-06-05 12:45:06.748511
123	1	1	27.6	76.4	163.52	0.59	0.29	0.1	2026-06-05 12:45:12.018755
124	1	1	27.6	76.2	162.86	0.6	0.29	0.1	2026-06-05 12:45:17.292695
125	1	1	27.6	76.2	160.44	0.6	0.29	0.1	2026-06-05 12:45:21.868229
126	1	1	27.7	76.2	152.53	0.6	0.29	0.1	2026-06-05 12:45:26.295627
127	1	1	27.6	76.2	163.74	0.6	0.3	0.1	2026-06-05 12:45:31.567486
128	1	1	27.7	76.1	164.18	0.6	0.3	0.1	2026-06-05 12:45:36.870597
129	1	1	27.7	75.9	163.08	0.6	0.3	0.11	2026-06-05 12:45:42.104644
130	1	1	27.7	76	159.78	0.6	0.3	0.11	2026-06-05 12:45:47.372165
131	1	1	27.7	76.4	157.14	0.61	0.3	0.11	2026-06-05 12:45:51.107827
132	1	1	27.8	76.1	162.2	0.61	0.3	0.11	2026-06-05 12:45:56.377366
133	1	1	27.8	76.1	163.96	0.61	0.3	0.11	2026-06-05 12:46:01.651859
134	1	1	27.8	76	172.53	0.61	0.31	0.11	2026-06-05 12:46:06.916113
135	1	1	27.8	76	165.27	0.61	0.31	0.11	2026-06-05 12:46:12.190379
136	1	1	27.9	76	159.56	0.61	0.31	0.11	2026-06-05 12:46:17.45915
137	1	1	27.9	76	166.81	0.62	0.31	0.12	2026-06-05 12:46:21.189804
138	1	1	27.9	76	167.91	0.62	0.31	0.12	2026-06-05 12:46:26.467969
139	1	1	27.9	76	163.08	0.62	0.31	0.12	2026-06-05 12:46:31.7351
140	1	1	27.9	75.7	165.71	0.62	0.31	0.12	2026-06-05 12:46:37.010844
141	1	1	28	75.5	164.84	0.62	0.32	0.12	2026-06-05 12:46:42.278865
142	1	1	28	75.5	156.7	0.62	0.32	0.12	2026-06-05 12:46:47.554732
143	1	1	28	77.6	152.75	0.58	0.29	0.1	2026-06-05 12:48:12.179356
144	1	1	27.9	76.9	157.36	0.58	0.29	0.1	2026-06-05 12:48:15.889893
145	1	1	27.9	76.3	159.34	0.58	0.29	0.1	2026-06-05 12:48:21.160796
146	1	1	27.9	76.9	170.77	0.58	0.29	0.1	2026-06-05 12:48:26.439328
147	1	1	27.9	77.2	163.74	0.59	0.29	0.1	2026-06-05 12:48:31.717073
148	1	1	27.9	77.5	152.75	0.59	0.29	0.1	2026-06-05 12:48:36.99753
149	1	1	27.9	77.2	159.78	0.59	0.29	0.1	2026-06-05 12:48:40.707104
150	1	1	27.8	77.2	150.55	0.59	0.29	0.11	2026-06-05 12:48:45.978884
151	1	1	27.8	77.2	159.78	0.59	0.29	0.11	2026-06-05 12:48:51.255789
152	1	1	27.8	77.2	158.68	0.59	0.29	0.11	2026-06-05 12:48:56.519018
153	1	1	27.8	77.4	156.26	0.59	0.29	0.11	2026-06-05 12:49:01.79331
154	1	1	27.8	77.6	163.52	0.6	0.29	0.11	2026-06-05 12:49:07.056361
155	1	1	27.8	77.6	155.82	0.6	0.29	0.11	2026-06-05 12:49:10.788426
156	1	1	27.8	77.3	159.78	0.6	0.29	0.11	2026-06-05 12:49:16.064053
157	1	1	27.8	77.2	156.26	0.6	0.29	0.12	2026-06-05 12:49:21.327005
158	1	1	27.7	77.3	159.78	0.6	0.29	0.12	2026-06-05 12:49:26.600171
159	1	1	27.7	77.5	156.26	0.6	0.29	0.12	2026-06-05 12:49:31.877422
160	1	1	27.7	77.8	151.65	0.6	0.29	0.12	2026-06-05 12:49:37.145542
161	1	1	27.7	77.9	158.46	0.61	0.29	0.12	2026-06-05 12:49:40.868047
162	1	1	27.7	77.8	159.78	0.61	0.29	0.12	2026-06-05 12:49:46.140502
163	1	1	27.7	77.8	154.95	0.61	0.29	0.12	2026-06-05 12:49:51.416353
164	1	1	27.7	77.9	159.78	0.61	0.29	0.13	2026-06-05 12:49:56.686317
165	1	1	27.7	77.4	155.38	0.61	0.29	0.13	2026-06-05 12:50:01.963104
166	1	1	27.7	77.6	153.41	0.61	0.29	0.13	2026-06-05 12:50:06.524448
167	1	1	27.6	78.6	156.92	0.62	0.29	0.13	2026-06-05 12:50:10.949994
168	1	1	27.6	79.2	156.92	0.62	0.29	0.13	2026-06-05 12:50:16.225593
169	1	1	27.6	79.4	156.7	0.62	0.29	0.13	2026-06-05 12:50:21.496912
170	1	1	27.6	79.1	154.95	0.62	0.29	0.13	2026-06-05 12:50:26.770057
171	1	1	27.6	78.8	156.26	0.62	0.29	0.14	2026-06-05 12:50:32.040138
172	1	1	27.5	78.3	152.75	0.62	0.29	0.14	2026-06-05 12:50:35.774179
173	1	1	27.6	78.4	155.16	0.62	0.29	0.14	2026-06-05 12:50:41.037657
174	1	1	27.6	78.1	154.29	0.63	0.29	0.14	2026-06-05 12:50:46.309542
175	1	1	27.6	78.1	153.85	0.63	0.29	0.14	2026-06-05 12:50:51.588268
176	1	1	27.6	78.3	150.55	0.63	0.29	0.14	2026-06-05 12:50:56.858574
177	1	1	27.6	78.5	156.48	0.63	0.29	0.14	2026-06-05 12:51:02.120849
178	1	1	27.6	78.3	156.92	0.63	0.29	0.14	2026-06-05 12:51:05.84866
179	1	1	27.5	78.2	155.82	0.63	0.29	0.15	2026-06-05 12:51:11.129195
180	1	1	27.5	78.1	156.7	0.63	0.29	0.15	2026-06-05 12:51:16.411769
181	1	1	27.5	78.2	154.95	0.64	0.29	0.15	2026-06-05 12:51:21.672549
182	1	1	27.5	78.7	157.14	0.64	0.29	0.15	2026-06-05 12:51:26.94123
183	1	1	27.5	78.7	152.09	0.64	0.29	0.15	2026-06-05 12:51:32.221008
184	1	1	27.5	78.9	161.1	0.64	0.29	0.15	2026-06-05 12:51:35.944029
185	1	1	27.5	78.9	156.48	0.64	0.29	0.15	2026-06-05 12:51:41.208169
186	1	1	27.5	79.1	152.75	0.64	0.29	0.16	2026-06-05 12:51:46.483132
187	1	1	27.5	79.4	156.26	0.65	0.29	0.16	2026-06-05 12:51:51.746038
188	1	1	27.5	79.3	160	0.65	0.29	0.16	2026-06-05 12:51:57.020312
189	1	1	27.5	79.6	151.21	0.65	0.29	0.16	2026-06-05 12:52:00.742611
190	1	1	27.5	80	156.48	0.65	0.29	0.16	2026-06-05 12:52:06.020839
191	1	1	27.5	80.4	154.73	0.65	0.29	0.16	2026-06-05 12:52:11.287615
192	1	1	27.5	80.4	151.65	0.65	0.29	0.16	2026-06-05 12:52:16.559932
193	1	1	27.4	79.6	155.16	0.65	0.29	0.17	2026-06-05 12:52:21.83222
194	1	1	27.4	79.4	154.51	0.66	0.29	0.17	2026-06-05 12:52:27.104611
195	1	1	27.4	79.4	156.26	0.66	0.29	0.17	2026-06-05 12:52:30.840104
196	1	1	27.4	79.5	152.75	0.66	0.29	0.17	2026-06-05 12:52:36.099278
197	1	1	27.4	79.3	154.51	0.66	0.29	0.17	2026-06-05 12:52:41.374749
198	1	1	27.4	79.1	159.78	0.66	0.29	0.17	2026-06-05 12:52:46.643828
199	1	1	27.4	79.1	153.41	0.66	0.29	0.17	2026-06-05 12:52:51.910899
200	1	1	27.4	79.4	148.79	0.66	0.29	0.18	2026-06-05 12:52:57.197881
201	1	1	27.4	79.3	157.8	0.67	0.29	0.18	2026-06-05 12:53:00.922402
202	1	1	27.4	79.4	156.7	0.67	0.29	0.18	2026-06-05 12:53:06.221588
203	1	1	27.4	79.9	154.29	0.67	0.29	0.18	2026-06-05 12:53:11.468643
204	1	1	27.4	80.6	152.75	0.67	0.29	0.18	2026-06-05 12:53:16.745178
205	1	1	27.4	80.5	153.19	0.67	0.29	0.18	2026-06-05 12:53:22.007863
206	1	1	27.4	80.9	159.56	0.67	0.29	0.18	2026-06-05 12:53:25.719368
207	1	1	27.4	81.2	156.26	0.67	0.29	0.19	2026-06-05 12:53:30.9917
208	1	1	27.4	81.1	152.53	0.68	0.29	0.19	2026-06-05 12:53:36.258095
209	1	1	27.4	81	156.92	0.68	0.29	0.19	2026-06-05 12:53:41.529699
210	1	1	27.4	80.9	157.8	0.68	0.29	0.19	2026-06-05 12:53:46.805215
211	1	1	27.4	80.7	154.07	0.68	0.29	0.19	2026-06-05 12:53:52.111025
212	1	1	27.4	81	148.35	0.68	0.29	0.19	2026-06-05 12:53:55.833436
213	1	1	27.3	81.3	153.19	0.68	0.29	0.19	2026-06-05 12:54:01.077899
214	1	1	27.3	81.8	151.65	0.69	0.29	0.2	2026-06-05 12:54:06.34974
215	1	1	27.4	82	156.7	0.69	0.29	0.2	2026-06-05 12:54:11.617459
216	1	1	27.3	82.1	158.68	0.69	0.29	0.2	2026-06-05 12:54:16.889827
217	1	1	27.4	82	154.07	0.69	0.29	0.2	2026-06-05 12:54:22.158672
218	1	1	27.3	80.9	160.44	0.69	0.29	0.2	2026-06-05 12:54:25.894004
219	1	1	27.4	79.8	154.73	0.69	0.29	0.2	2026-06-05 12:54:31.145549
220	1	1	27.3	80.4	163.52	0.69	0.29	0.2	2026-06-05 12:54:36.41622
221	1	1	27.3	80.6	159.34	0.7	0.29	0.21	2026-06-05 12:54:41.69972
222	1	1	27.3	80.7	153.19	0.7	0.29	0.21	2026-06-05 12:54:46.982691
223	1	1	27.3	81.9	160.44	0.7	0.29	0.21	2026-06-05 12:54:50.695408
224	1	1	27.3	82.6	154.51	0.7	0.29	0.21	2026-06-05 12:54:55.96777
225	1	1	27.3	81.9	161.32	0.7	0.29	0.21	2026-06-05 12:55:01.235443
226	1	1	27.3	80.9	156.26	0.7	0.29	0.21	2026-06-05 12:55:06.514005
227	1	1	27.3	80.7	163.3	0.7	0.29	0.21	2026-06-05 12:55:11.781292
228	1	1	27.3	81.1	163.08	0.71	0.29	0.22	2026-06-05 12:55:17.058569
229	1	1	27.3	82	160.22	0.71	0.29	0.22	2026-06-05 12:55:20.787205
230	1	1	27.3	82	166.37	0.71	0.29	0.22	2026-06-05 12:55:26.05362
231	1	1	27.3	81.9	160.22	0.71	0.29	0.22	2026-06-05 12:55:31.324017
232	1	1	27.3	82.2	162.86	0.71	0.29	0.22	2026-06-05 12:55:36.621697
233	1	1	27.3	81.7	161.98	0.71	0.29	0.22	2026-06-05 12:55:41.895784
234	1	1	27.3	81.7	156.7	0.72	0.29	0.22	2026-06-05 12:55:47.182091
235	1	1	27.3	80.5	156.7	0.72	0.29	0.23	2026-06-05 12:55:50.863603
236	1	1	27.3	81.6	165.05	0.72	0.29	0.23	2026-06-05 12:55:56.13693
237	1	1	27.3	82.5	158.68	0.72	0.29	0.23	2026-06-05 12:56:01.399644
238	1	1	27.3	83.4	165.27	0.72	0.29	0.23	2026-06-05 12:56:06.667798
239	1	1	27.3	84.1	160.88	0.72	0.29	0.23	2026-06-05 12:56:11.957775
240	1	1	27.3	84.2	166.37	0.72	0.29	0.23	2026-06-05 12:56:16.525931
241	1	1	27.3	84.4	158.46	0.73	0.29	0.23	2026-06-05 12:56:20.944152
242	1	1	27.3	85.1	164.18	0.73	0.29	0.24	2026-06-05 12:56:26.208231
243	1	1	27.3	85.4	160.22	0.73	0.29	0.24	2026-06-05 12:56:31.483671
244	1	1	27.3	86	159.56	0.73	0.29	0.24	2026-06-05 12:56:36.795113
245	1	1	27.3	86.3	163.3	0.73	0.29	0.24	2026-06-05 12:56:42.033599
246	1	1	27.3	86.5	166.59	0.73	0.29	0.24	2026-06-05 12:56:45.760041
247	1	1	27.3	86.8	163.74	0.73	0.29	0.24	2026-06-05 12:56:51.032292
248	1	1	27.3	87	161.1	0.74	0.29	0.24	2026-06-05 12:56:56.298026
249	1	1	27.3	86.4	162.86	0.74	0.29	0.25	2026-06-05 12:57:01.568128
250	1	1	27.3	86.3	159.78	0.74	0.29	0.25	2026-06-05 12:57:06.851295
251	1	1	27.3	85.6	162.2	0.74	0.29	0.25	2026-06-05 12:57:12.113988
252	1	1	27.3	85.5	169.67	0.74	0.29	0.25	2026-06-05 12:57:15.851226
253	1	1	27.4	86.3	162.64	0.74	0.29	0.25	2026-06-05 12:57:21.122455
254	1	1	27.3	86.5	164.62	0.74	0.29	0.25	2026-06-05 12:57:26.391073
255	1	1	27.3	86.2	163.74	0.75	0.29	0.25	2026-06-05 12:57:31.658849
256	1	1	27.3	86.4	156.7	0.75	0.29	0.26	2026-06-05 12:57:36.931016
257	1	1	27.4	87.2	161.98	0.75	0.29	0.26	2026-06-05 12:57:42.202975
258	1	1	27.3	87.4	164.62	0.75	0.29	0.26	2026-06-05 12:57:45.923797
259	1	1	27.3	87.5	163.96	0.75	0.29	0.26	2026-06-05 12:57:51.204067
260	1	1	27.4	87.7	158.46	0.75	0.29	0.26	2026-06-05 12:57:56.478767
261	1	1	27.3	87.8	163.52	0.76	0.29	0.26	2026-06-05 12:58:01.739039
262	1	1	27.4	87.9	162.2	0.76	0.29	0.26	2026-06-05 12:58:07.015492
263	1	1	27.3	85.8	163.3	0.76	0.29	0.26	2026-06-05 12:58:10.843513
264	1	1	27.4	82.8	152.75	0.76	0.29	0.27	2026-06-05 12:58:16.05715
265	1	1	27.4	80.3	159.78	0.76	0.29	0.27	2026-06-05 12:58:21.3084
266	1	1	27.9	77.2	162.42	0.76	0.29	0.27	2026-06-05 12:58:26.589491
267	1	1	29	74	160	0.76	0.29	0.27	2026-06-05 12:58:31.857553
268	1	1	30.3	70.5	165.05	0.77	0.3	0.27	2026-06-05 12:58:37.126023
269	1	1	31.2	67.9	161.1	0.77	0.3	0.27	2026-06-05 12:58:40.819511
270	1	1	32.6	63.9	162.2	0.77	0.3	0.27	2026-06-05 12:58:46.094981
271	1	1	33.6	65.6	165.93	0.77	0.3	0.28	2026-06-05 12:58:51.36917
272	1	1	34.2	65	169.23	0.77	0.3	0.28	2026-06-05 12:58:56.64093
273	1	1	34.9	63.3	164.4	0.77	0.3	0.28	2026-06-05 12:59:01.911064
274	1	1	35.5	62.3	161.98	0.77	0.3	0.28	2026-06-05 12:59:07.185493
275	1	1	35.9	61.1	160.88	0.78	0.3	0.28	2026-06-05 12:59:10.906838
276	1	1	36.4	59.9	165.93	0.78	0.31	0.28	2026-06-05 12:59:16.182045
277	1	1	36.9	58.1	160.66	0.78	0.31	0.28	2026-06-05 12:59:21.450172
278	1	1	37.4	56.7	159.78	0.78	0.31	0.28	2026-06-05 12:59:26.723903
279	1	1	37.8	55.6	163.74	0.78	0.31	0.29	2026-06-05 12:59:31.994885
280	1	1	38.3	54.6	163.08	0.78	0.31	0.29	2026-06-05 12:59:35.673632
281	1	1	38.6	53.7	166.81	0.79	0.31	0.29	2026-06-05 12:59:40.94024
282	1	1	39	52.3	162.86	0.79	0.31	0.29	2026-06-05 12:59:46.21658
283	1	1	39.4	51.1	163.3	0.79	0.32	0.29	2026-06-05 12:59:51.493947
284	1	1	39.7	50.4	162.2	0.79	0.32	0.29	2026-06-05 12:59:56.775342
285	1	1	40.1	49.6	163.08	0.79	0.32	0.29	2026-06-05 13:00:02.055831
286	1	1	40.5	48.2	166.81	0.79	0.32	0.3	2026-06-05 13:00:05.799124
287	1	1	40.7	47.9	159.12	0.79	0.32	0.3	2026-06-05 13:00:11.072885
288	1	1	41	47	156.7	0.8	0.32	0.3	2026-06-05 13:00:16.345598
289	1	1	41.3	46.4	163.74	0.8	0.32	0.3	2026-06-05 13:00:21.624174
290	1	1	41.6	45.9	160.44	0.8	0.33	0.3	2026-06-05 13:00:26.90126
291	1	1	41.9	45.1	162.42	0.8	0.33	0.3	2026-06-05 13:00:32.170914
292	1	1	42.1	44.5	159.78	0.8	0.33	0.3	2026-06-05 13:00:35.879121
293	1	1	42.4	44	156.92	0.8	0.33	0.3	2026-06-05 13:00:41.146999
294	1	1	42.6	43.5	163.08	0.8	0.33	0.31	2026-06-05 13:00:46.434391
295	1	1	42.8	43.1	163.08	0.81	0.33	0.31	2026-06-05 13:00:51.727275
296	1	1	43.1	42.8	159.78	0.81	0.33	0.31	2026-06-05 13:00:57.005157
297	1	1	43.3	42.3	163.3	0.81	0.33	0.31	2026-06-05 13:01:00.695936
298	1	1	43.5	42	163.96	0.81	0.34	0.31	2026-06-05 13:01:05.961756
299	1	1	43.7	41.6	163.96	0.81	0.34	0.31	2026-06-05 13:01:11.239252
300	1	1	43.9	41.2	157.8	0.81	0.34	0.31	2026-06-05 13:01:16.506506
301	1	1	44	41	164.4	0.81	0.34	0.32	2026-06-05 13:01:21.776166
302	1	1	44.2	40.7	158.46	0.82	0.34	0.32	2026-06-05 13:01:27.05966
303	1	1	44.3	40.3	161.98	0.82	0.34	0.32	2026-06-05 13:01:30.789381
304	1	1	44.5	40.3	140	0.82	0.34	0.32	2026-06-05 13:01:36.062993
305	1	1	44.6	39.5	163.3	0.82	0.35	0.32	2026-06-05 13:01:41.327918
306	1	1	44.7	39.6	165.27	0.82	0.35	0.32	2026-06-05 13:01:46.599923
307	1	1	44.8	39.1	161.1	0.82	0.35	0.32	2026-06-05 13:01:51.862131
308	1	1	45	38.8	158.46	0.83	0.35	0.32	2026-06-05 13:01:57.145781
309	1	1	45.1	38.8	161.32	0.83	0.35	0.33	2026-06-05 13:02:00.871632
310	1	1	45.2	38.6	156.26	0.83	0.35	0.33	2026-06-05 13:02:06.136865
311	1	1	45.3	38.3	165.27	0.83	0.35	0.33	2026-06-05 13:02:11.413432
312	1	1	45.4	38.2	169.89	0.83	0.35	0.33	2026-06-05 13:02:16.678777
313	1	1	45.5	38	162.2	0.83	0.36	0.33	2026-06-05 13:02:21.95056
314	1	1	45.6	37.8	160.22	0.83	0.36	0.33	2026-06-05 13:02:25.698081
315	1	1	45.8	37.8	163.52	0.84	0.36	0.33	2026-06-05 13:02:30.955572
316	1	1	45.9	37.5	154.07	0.84	0.36	0.34	2026-06-05 13:02:36.218885
317	1	1	45.9	37.2	162.2	0.84	0.36	0.34	2026-06-05 13:02:41.49203
318	1	1	46.1	37.2	159.78	0.84	0.36	0.34	2026-06-05 13:02:46.767797
319	1	1	46.2	36.9	160.44	0.84	0.36	0.34	2026-06-05 13:02:52.043963
320	1	1	46.3	36.8	166.81	0.84	0.37	0.34	2026-06-05 13:02:55.754878
321	1	1	46.4	36.6	162.2	0.84	0.37	0.34	2026-06-05 13:03:01.029207
322	1	1	46.5	36.4	154.07	0.85	0.37	0.34	2026-06-05 13:03:06.301032
323	1	1	46.6	36.3	161.98	0.85	0.37	0.34	2026-06-05 13:03:11.570918
324	1	1	46.7	36.3	164.18	0.85	0.37	0.35	2026-06-05 13:03:16.845693
325	1	1	46.8	36.2	163.08	0.85	0.37	0.35	2026-06-05 13:03:22.114235
326	1	1	47	35.8	168.57	0.85	0.37	0.35	2026-06-05 13:03:25.839661
327	1	1	47.1	35.8	162.86	0.85	0.37	0.35	2026-06-05 13:03:31.115529
328	1	1	47.1	35.5	164.4	0.86	0.38	0.35	2026-06-05 13:03:36.384248
329	1	1	40.1	43.2	169.89	0.85	0.37	0.34	2026-06-05 13:05:32.858049
330	1	1	39.7	43.9	162.42	0.85	0.37	0.34	2026-06-05 13:05:38.124105
331	1	1	39.3	44.6	167.25	0.85	0.37	0.34	2026-06-05 13:05:43.394285
332	1	1	39	45.1	170.99	0.85	0.37	0.34	2026-06-05 13:05:47.089312
333	1	1	38.5	45.8	167.69	0.85	0.37	0.34	2026-06-05 13:05:52.355292
334	1	1	38.3	46.3	164.84	0.85	0.37	0.34	2026-06-05 13:05:57.632811
335	1	1	37.9	47	165.71	0.86	0.38	0.34	2026-06-05 13:06:02.925766
336	1	1	37.5	47.6	161.54	0.86	0.38	0.34	2026-06-05 13:06:08.209223
337	1	1	37.3	48	166.15	0.86	0.38	0.34	2026-06-05 13:06:13.497479
338	1	1	37	48.7	162.86	0.86	0.38	0.34	2026-06-05 13:06:17.17484
339	1	1	36.8	49	241.76	0.86	0.38	0.34	2026-06-05 13:06:22.44878
340	1	1	36.4	50	447.69	0.86	0.38	0.34	2026-06-05 13:06:27.715089
341	1	1	36	50.8	313.19	0.86	0.38	0.34	2026-06-05 13:06:32.990224
342	1	1	35.8	51.2	278.9	0.87	0.38	0.34	2026-06-05 13:06:38.282128
343	1	1	35.6	51.9	258.9	0.87	0.39	0.34	2026-06-05 13:06:41.994136
344	1	1	35.4	51.9	240.22	0.87	0.39	0.34	2026-06-05 13:06:47.254655
345	1	1	35.2	52.3	241.76	0.87	0.39	0.34	2026-06-05 13:06:52.52373
346	1	1	35	52.9	218.24	0.87	0.39	0.34	2026-06-05 13:06:57.800604
347	1	1	34.9	53.1	216.48	0.87	0.39	0.34	2026-06-05 13:07:03.080349
348	1	1	34.7	53.5	208.57	0.88	0.39	0.34	2026-06-05 13:07:08.373238
349	1	1	34.6	53.7	207.47	0.88	0.39	0.34	2026-06-05 13:07:12.070339
350	1	1	34.5	54.1	205.05	0.88	0.4	0.34	2026-06-05 13:07:17.343571
351	1	1	34.3	54.6	196.48	0.88	0.4	0.34	2026-06-05 13:07:22.618693
352	1	1	34.2	55	197.58	0.88	0.4	0.34	2026-06-05 13:07:27.888074
353	1	1	34	55.5	198.24	0.88	0.4	0.34	2026-06-05 13:07:33.173888
354	1	1	33.9	55.7	190.11	0.88	0.4	0.34	2026-06-05 13:07:38.436971
355	1	1	33.7	56	188.79	0.89	0.4	0.34	2026-06-05 13:07:42.162016
356	1	1	33.6	56.4	192.53	0.89	0.4	0.34	2026-06-05 13:07:47.427268
357	1	1	33.5	56.8	188.57	0.89	0.4	0.34	2026-06-05 13:07:52.703751
358	1	1	33.3	57	184.18	0.89	0.41	0.34	2026-06-05 13:07:57.976464
359	1	1	33.2	57.3	179.12	0.89	0.41	0.34	2026-06-05 13:08:03.250326
360	1	1	33.1	57.8	173.85	0.89	0.41	0.34	2026-06-05 13:08:07.819508
361	1	1	32.9	58.1	181.32	0.89	0.41	0.34	2026-06-05 13:08:12.255477
362	1	1	32.8	58.4	187.47	0.9	0.41	0.34	2026-06-05 13:08:17.555505
363	1	1	32.7	58.2	180.88	0.9	0.41	0.34	2026-06-05 13:08:22.988246
364	1	1	32.7	58.4	191.87	0.9	0.41	0.34	2026-06-05 13:08:28.20195
365	1	1	32.6	58.8	186.15	0.9	0.42	0.34	2026-06-05 13:08:33.346551
366	1	1	32.5	59	187.91	0.9	0.42	0.34	2026-06-05 13:08:37.154399
367	1	1	32.5	59.1	186.37	0.9	0.42	0.34	2026-06-05 13:08:42.335823
368	1	1	32.4	59.4	185.05	0.9	0.42	0.34	2026-06-05 13:08:48.812425
369	1	1	32.3	59.5	189.45	0.91	0.42	0.34	2026-06-05 13:08:53.08243
370	1	1	32.3	59.7	190.55	0.91	0.42	0.34	2026-06-05 13:08:59.13535
371	1	1	32.2	59.8	186.37	0.91	0.42	0.34	2026-06-05 13:09:03.412336
372	1	1	32.2	60	184.84	0.91	0.42	0.34	2026-06-05 13:09:07.145448
373	1	1	32.1	60.4	185.27	0.91	0.43	0.34	2026-06-05 13:09:12.412982
374	1	1	32.1	60.8	184.62	0.91	0.43	0.34	2026-06-05 13:09:17.685001
375	1	1	32	61.1	183.96	0.92	0.43	0.34	2026-06-05 13:09:22.959
376	1	1	32	61.2	188.35	0.92	0.43	0.34	2026-06-05 13:09:28.227417
377	1	1	31.9	61.2	178.46	0.92	0.43	0.34	2026-06-05 13:09:33.50606
378	1	1	31.9	61.4	176.04	0.92	0.43	0.34	2026-06-05 13:09:37.225454
379	1	1	31.8	61.4	185.93	0.92	0.43	0.34	2026-06-05 13:09:42.496476
380	1	1	31.8	61.5	179.56	0.92	0.44	0.34	2026-06-05 13:09:47.77237
381	1	1	31.8	61.5	187.69	0.92	0.44	0.34	2026-06-05 13:09:53.041932
382	1	1	31.8	61.5	182.2	0.93	0.44	0.34	2026-06-05 13:09:58.317382
383	1	1	31.7	61.7	182.2	0.93	0.44	0.34	2026-06-05 13:10:02.028076
384	1	1	31.6	61.8	179.56	0.93	0.44	0.34	2026-06-05 13:10:07.299096
385	1	1	31.6	62	180.22	0.93	0.44	0.34	2026-06-05 13:10:12.570064
386	1	1	31.5	62.1	180.88	0.93	0.44	0.34	2026-06-05 13:10:17.847188
387	1	1	31.5	62.2	181.98	0.93	0.45	0.34	2026-06-05 13:10:23.106842
388	1	1	31.5	62.3	180.88	0.93	0.45	0.34	2026-06-05 13:10:28.383559
389	1	1	30.3	66.7	168.13	0.94	0.45	0.34	2026-06-05 13:11:18.724894
390	1	1	30.1	67	173.63	0.94	0.45	0.34	2026-06-05 13:11:23.999152
391	1	1	30	66.7	168.79	0.94	0.45	0.34	2026-06-05 13:11:27.667505
392	1	1	29.8	67	175.16	0.94	0.45	0.34	2026-06-05 13:11:32.939304
393	1	1	29.7	67.3	170.11	0.94	0.45	0.34	2026-06-05 13:11:38.210316
394	1	1	29.6	67.5	177.8	0.94	0.45	0.34	2026-06-05 13:11:43.485061
395	1	1	29.5	67.9	172.97	0.94	0.45	0.34	2026-06-05 13:11:48.758137
396	1	1	29.4	68.1	176.26	0.95	0.46	0.34	2026-06-05 13:11:54.048138
397	1	1	29.3	68.5	170.55	0.95	0.46	0.34	2026-06-05 13:11:57.800154
398	1	1	29.2	68.7	167.91	0.95	0.46	0.34	2026-06-05 13:12:03.062669
399	1	1	29.2	68.8	170.77	0.95	0.46	0.34	2026-06-05 13:12:08.343126
400	1	1	29.1	69.1	176.04	0.95	0.46	0.34	2026-06-05 13:12:13.616139
401	1	1	29.1	69.8	171.65	0.95	0.46	0.34	2026-06-05 13:12:18.90035
402	1	1	29	69.9	175.82	0.95	0.46	0.34	2026-06-05 13:12:24.166776
403	1	1	29	70	173.19	0.96	0.46	0.34	2026-06-05 13:12:27.890056
404	1	1	29	70.1	176.04	0.96	0.47	0.34	2026-06-05 13:12:33.156745
405	1	1	29	70	172.31	0.96	0.47	0.34	2026-06-05 13:12:38.422394
406	1	1	28.9	70.2	174.29	0.96	0.47	0.34	2026-06-05 13:12:43.722061
407	1	1	28.9	70.1	172.53	0.96	0.47	0.34	2026-06-05 13:12:48.971955
408	1	1	28.9	70.1	178.68	0.96	0.47	0.34	2026-06-05 13:12:52.695592
409	1	1	28.9	70.1	173.85	0.97	0.47	0.34	2026-06-05 13:12:57.972786
410	1	1	28.9	70.2	169.45	0.97	0.47	0.34	2026-06-05 13:13:03.233284
411	1	1	28.9	70.2	173.85	0.97	0.48	0.34	2026-06-05 13:13:08.504665
412	1	1	28.9	70.3	176.92	0.97	0.48	0.34	2026-06-05 13:13:13.775549
413	1	1	28.9	70.2	173.41	0.97	0.48	0.34	2026-06-05 13:13:19.048953
414	1	1	28.9	70.2	166.37	0.97	0.48	0.34	2026-06-05 13:13:22.776638
415	1	1	28.9	70.1	174.51	0.97	0.48	0.34	2026-06-05 13:13:28.043171
416	1	1	28.9	70	167.69	0.98	0.48	0.34	2026-06-05 13:13:33.314897
417	1	1	28.9	70.1	171.21	0.98	0.48	0.34	2026-06-05 13:13:38.586662
418	1	1	28.9	70.2	165.93	0.98	0.48	0.34	2026-06-05 13:13:43.856509
419	1	1	28.9	69.9	169.23	0.98	0.49	0.34	2026-06-05 13:13:49.142126
420	1	1	28.9	69.8	172.09	0.98	0.49	0.34	2026-06-05 13:13:52.843786
421	1	1	28.9	69.7	382.86	0.98	0.49	0.34	2026-06-05 13:13:58.110743
422	1	1	28.8	69.7	503.96	0.98	0.49	0.34	2026-06-05 13:14:03.386665
423	1	1	28.8	70	389.89	0.99	0.49	0.34	2026-06-05 13:14:08.659523
424	1	1	28.8	69.8	335.6	0.99	0.49	0.34	2026-06-05 13:14:13.93282
425	1	1	28.9	69.8	301.54	0.99	0.49	0.34	2026-06-05 13:14:17.679439
426	1	1	28.8	69.7	269.89	0.99	0.5	0.34	2026-06-05 13:14:22.946545
427	1	1	28.8	69.7	251.87	0.99	0.5	0.34	2026-06-05 13:14:28.221655
428	1	1	28.8	69.6	233.63	0.99	0.5	0.34	2026-06-05 13:14:33.502727
429	1	1	28.9	69.6	227.69	0.99	0.5	0.34	2026-06-05 13:14:38.762617
430	1	1	28.9	69.6	223.08	1	0.5	0.34	2026-06-05 13:14:44.033954
431	1	1	28.9	69.6	212.31	1	0.5	0.34	2026-06-05 13:14:47.753925
432	1	1	29	69.5	206.81	1	0.5	0.34	2026-06-05 13:14:53.031144
433	1	1	28.9	69.6	202.64	1	0.51	0.34	2026-06-05 13:14:58.305035
434	1	1	29	69.4	200	1	0.51	0.34	2026-06-05 13:15:03.583337
435	1	1	29	69.2	199.78	1	0.51	0.34	2026-06-05 13:15:08.849996
436	1	1	29	69.2	192.09	1	0.51	0.34	2026-06-05 13:15:14.134195
437	1	1	29	69.1	188.35	1.01	0.51	0.34	2026-06-05 13:15:17.837999
438	1	1	29	69	191.43	1.01	0.51	0.34	2026-06-05 13:15:23.111226
439	1	1	29.1	69	195.16	1.01	0.51	0.34	2026-06-05 13:15:28.385971
440	1	1	29.1	68.9	187.25	1.01	0.52	0.34	2026-06-05 13:15:33.660494
441	1	1	29.1	68.8	190.55	1.01	0.52	0.34	2026-06-05 13:15:38.933922
442	1	1	29.1	68.8	183.96	1.01	0.52	0.34	2026-06-05 13:15:42.646989
443	1	1	29.1	68.7	180.88	1.01	0.52	0.34	2026-06-05 13:15:47.93227
444	1	1	29.1	68.7	181.32	1.01	0.52	0.34	2026-06-05 13:15:53.203803
445	1	1	29.1	68.6	186.59	1.02	0.52	0.34	2026-06-05 13:15:58.484304
446	1	1	29.1	68.6	187.03	1.02	0.52	0.34	2026-06-05 13:16:03.754562
447	1	1	29.1	68.6	187.91	1.02	0.53	0.34	2026-06-05 13:16:09.03056
448	1	1	29.1	68.6	180.88	1.02	0.53	0.34	2026-06-05 13:16:12.749051
449	1	1	29.1	68.7	185.71	1.02	0.53	0.34	2026-06-05 13:16:18.019613
450	1	1	29.1	68.7	186.15	1.02	0.53	0.34	2026-06-05 13:16:23.290707
451	1	1	29.2	68.7	187.25	1.02	0.53	0.34	2026-06-05 13:16:28.565841
452	1	1	29.1	68.7	180.88	1.02	0.53	0.34	2026-06-05 13:16:33.866155
453	1	1	29.1	68.7	181.54	1.02	0.54	0.34	2026-06-05 13:16:39.117706
454	1	1	29.1	68.7	183.08	1.03	0.54	0.34	2026-06-05 13:16:42.81798
455	1	1	29.2	68.8	180.22	1.03	0.54	0.34	2026-06-05 13:16:48.09544
456	1	1	29.1	68.8	187.91	1.03	0.54	0.34	2026-06-05 13:16:53.370021
457	1	1	29.1	68.7	179.78	1.03	0.54	0.34	2026-06-05 13:16:58.65411
458	1	1	29.2	68.6	178.68	1.03	0.54	0.34	2026-06-05 13:17:03.931529
459	1	1	29.1	68.6	178.02	1.03	0.54	0.34	2026-06-05 13:17:08.478562
460	1	1	29.1	68.5	178.9	1.03	0.55	0.34	2026-06-05 13:17:12.900985
461	1	1	29.1	68.5	178.46	1.03	0.55	0.34	2026-06-05 13:17:18.174366
462	1	1	29.1	68.5	178.9	1.04	0.55	0.34	2026-06-05 13:17:23.456906
463	1	1	29.1	68.6	176.04	1.04	0.55	0.34	2026-06-05 13:17:28.725512
464	1	1	29.2	68.5	172.53	1.04	0.55	0.34	2026-06-05 13:17:34.010085
465	1	1	29.1	68.6	178.02	1.04	0.55	0.34	2026-06-05 13:17:37.719542
466	1	1	29.1	68.6	179.12	1.04	0.55	0.34	2026-06-05 13:17:42.996288
467	1	1	29.1	68.6	175.16	1.04	0.56	0.34	2026-06-05 13:17:48.285235
468	1	1	29.1	68.6	181.32	1.04	0.56	0.34	2026-06-05 13:17:53.546552
469	1	1	29.1	68.6	175.38	1.04	0.56	0.34	2026-06-05 13:17:58.810615
470	1	1	29.1	68.6	177.36	1.04	0.56	0.34	2026-06-05 13:18:04.098733
471	1	1	29.1	68.6	176.04	1.05	0.56	0.34	2026-06-05 13:18:07.789645
472	1	1	29.1	68.7	172.75	1.05	0.56	0.34	2026-06-05 13:18:13.0657
473	1	1	29.1	68.7	171.43	1.05	0.56	0.34	2026-06-05 13:18:18.335558
474	1	1	29.1	68.6	170.99	1.05	0.57	0.34	2026-06-05 13:18:23.60191
475	1	1	29.1	68.7	173.85	1.05	0.57	0.34	2026-06-05 13:18:28.881939
476	1	1	29.1	68.8	180.88	1.05	0.57	0.34	2026-06-05 13:18:34.148512
477	1	1	29.1	68.8	173.85	1.05	0.57	0.34	2026-06-05 13:18:37.879716
478	1	1	29.1	68.9	172.09	1.05	0.57	0.34	2026-06-05 13:18:43.151939
479	1	1	29.1	68.8	174.29	1.06	0.57	0.34	2026-06-05 13:18:48.419058
\.


--
-- Data for Name: shoes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shoes (id, user_id, shoe_name, shoe_type, shoe_material, created_at) FROM stdin;
1	1	Nike Air Max Blue	Running	Mesh	2026-05-19 04:57:33.103686
2	1	Adidas Samba Black	Casual	Kanvas	2026-05-19 04:57:33.103686
3	1	Prada Derby Leather	Formal	Kulit	2026-05-19 04:57:33.103686
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, created_at) FROM stdin;
1	John Doe	johndoe@example.com	$2a$10$cJxOnevDl7myk4UuNz9aQutHmw6iPzTUFly/QZqbgrGqzpHGC67H6	2026-05-16 04:57:33.090768
\.


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 1, true);


--
-- Name: maintenance_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maintenance_logs_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 674, true);


--
-- Name: predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.predictions_id_seq', 877, true);


--
-- Name: sensor_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensor_logs_id_seq', 877, true);


--
-- Name: shoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shoes_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: devices devices_device_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_code_key UNIQUE (device_code);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: maintenance_logs maintenance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs
    ADD CONSTRAINT maintenance_logs_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (id);


--
-- Name: sensor_logs sensor_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_logs
    ADD CONSTRAINT sensor_logs_pkey PRIMARY KEY (id);


--
-- Name: shoes shoes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shoes
    ADD CONSTRAINT shoes_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: devices devices_active_shoe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_active_shoe_id_fkey FOREIGN KEY (active_shoe_id) REFERENCES public.shoes(id) ON DELETE SET NULL;


--
-- Name: devices devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: devices fk_active_shoe; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT fk_active_shoe FOREIGN KEY (active_shoe_id) REFERENCES public.shoes(id) ON DELETE SET NULL;


--
-- Name: maintenance_logs maintenance_logs_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_logs
    ADD CONSTRAINT maintenance_logs_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: predictions predictions_sensor_log_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_sensor_log_id_fkey FOREIGN KEY (sensor_log_id) REFERENCES public.sensor_logs(id) ON DELETE CASCADE;


--
-- Name: sensor_logs sensor_logs_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_logs
    ADD CONSTRAINT sensor_logs_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE SET NULL;


--
-- Name: sensor_logs sensor_logs_shoe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_logs
    ADD CONSTRAINT sensor_logs_shoe_id_fkey FOREIGN KEY (shoe_id) REFERENCES public.shoes(id) ON DELETE SET NULL;


--
-- Name: shoes shoes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shoes
    ADD CONSTRAINT shoes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 0orZMrdhtqtybschasfeMTxJsc4HyKMg0vqK6wIikDHEvTvwCAMa9xMFrn97UJW

