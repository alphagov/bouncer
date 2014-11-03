--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: daily_hit_totals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE daily_hit_totals (
    id integer NOT NULL,
    host_id integer NOT NULL,
    http_status character varying(3) NOT NULL,
    count integer NOT NULL,
    total_on date NOT NULL
);


--
-- Name: daily_hit_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE daily_hit_totals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: daily_hit_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE daily_hit_totals_id_seq OWNED BY daily_hit_totals.id;


--
-- Name: hits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hits (
    id integer NOT NULL,
    host_id integer NOT NULL,
    path character varying(2048) NOT NULL,
    path_hash character varying(40) NOT NULL,
    http_status character varying(3) NOT NULL,
    count integer NOT NULL,
    hit_on date NOT NULL,
    mapping_id integer
);


--
-- Name: hits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hits_id_seq OWNED BY hits.id;


--
-- Name: hits_staging; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hits_staging (
    hostname character varying(255) DEFAULT NULL::character varying,
    path text DEFAULT NULL::character varying,
    http_status character varying(3) DEFAULT NULL::character varying,
    count integer,
    hit_on date
);


--
-- Name: host_paths; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE host_paths (
    id integer NOT NULL,
    path character varying(2048) DEFAULT NULL::character varying,
    path_hash character varying(255) DEFAULT NULL::character varying,
    c14n_path_hash character varying(255) DEFAULT NULL::character varying,
    host_id integer,
    mapping_id integer
);


--
-- Name: host_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE host_paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: host_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE host_paths_id_seq OWNED BY host_paths.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    site_id integer NOT NULL,
    hostname character varying(255) NOT NULL,
    ttl integer,
    cname character varying(255) DEFAULT NULL::character varying,
    live_cname character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    ip_address character varying(255) DEFAULT NULL::character varying,
    canonical_host_id integer
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: imported_hits_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE imported_hits_files (
    id integer NOT NULL,
    filename character varying(255) DEFAULT NULL::character varying,
    content_hash character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: imported_hits_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE imported_hits_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imported_hits_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imported_hits_files_id_seq OWNED BY imported_hits_files.id;


--
-- Name: mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mappings (
    id integer NOT NULL,
    site_id integer NOT NULL,
    path character varying(2048) NOT NULL,
    path_hash character varying(40) NOT NULL,
    new_url text,
    suggested_url text,
    archive_url text,
    from_redirector boolean DEFAULT false,
    type character varying(255) NOT NULL,
    hit_count integer
);


--
-- Name: mappings_batch_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mappings_batch_entries (
    id integer NOT NULL,
    path character varying(2048) DEFAULT NULL::character varying,
    mappings_batch_id integer,
    mapping_id integer,
    processed boolean DEFAULT false,
    klass character varying(255) DEFAULT NULL::character varying,
    new_url character varying(2048) DEFAULT NULL::character varying,
    type character varying(255) DEFAULT NULL::character varying
);


--
-- Name: mappings_batch_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mappings_batch_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_batch_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mappings_batch_entries_id_seq OWNED BY mappings_batch_entries.id;


--
-- Name: mappings_batches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mappings_batches (
    id integer NOT NULL,
    tag_list character varying(255) DEFAULT NULL::character varying,
    new_url character varying(2048) DEFAULT NULL::character varying,
    update_existing boolean,
    user_id integer,
    site_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    state character varying(255) DEFAULT 'unqueued'::character varying,
    seen_outcome boolean DEFAULT false,
    type character varying(255) DEFAULT NULL::character varying,
    klass character varying(255) DEFAULT NULL::character varying
);


--
-- Name: mappings_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mappings_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mappings_batches_id_seq OWNED BY mappings_batches.id;


--
-- Name: mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mappings_id_seq OWNED BY mappings.id;


--
-- Name: organisational_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organisational_relationships (
    id integer NOT NULL,
    parent_organisation_id integer,
    child_organisation_id integer
);


--
-- Name: organisational_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organisational_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisational_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organisational_relationships_id_seq OWNED BY organisational_relationships.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organisations (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    homepage character varying(255) DEFAULT NULL::character varying,
    furl character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    css character varying(255) DEFAULT NULL::character varying,
    ga_profile_id character varying(16) DEFAULT NULL::character varying,
    whitehall_slug character varying(255) DEFAULT NULL::character varying,
    whitehall_type character varying(255) DEFAULT NULL::character varying,
    abbreviation character varying(255) DEFAULT NULL::character varying
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: organisations_sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organisations_sites (
    site_id integer NOT NULL,
    organisation_id integer NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sites (
    id integer NOT NULL,
    organisation_id integer NOT NULL,
    abbr character varying(255) NOT NULL,
    query_params character varying(255) DEFAULT NULL::character varying,
    tna_timestamp timestamp with time zone NOT NULL,
    homepage character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    global_new_url text,
    launch_date date,
    special_redirect_strategy character varying(255) DEFAULT NULL::character varying,
    global_redirect_append_path boolean DEFAULT false NOT NULL,
    global_type character varying(255) DEFAULT NULL::character varying,
    homepage_title character varying(255) DEFAULT NULL::character varying,
    homepage_furl character varying(255) DEFAULT NULL::character varying
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sites_id_seq OWNED BY sites.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255) DEFAULT NULL::character varying,
    tagger_id integer,
    tagger_type character varying(255) DEFAULT NULL::character varying,
    context character varying(128) DEFAULT NULL::character varying,
    created_at timestamp with time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    email character varying(255) DEFAULT NULL::character varying,
    uid character varying(255) DEFAULT NULL::character varying,
    permissions text,
    remotely_signed_out boolean DEFAULT false,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organisation_slug character varying(255) DEFAULT NULL::character varying,
    is_robot boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255) DEFAULT NULL::character varying,
    user_id integer,
    object_changes text,
    object text,
    created_at timestamp with time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: whitelisted_hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE whitelisted_hosts (
    id integer NOT NULL,
    hostname character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: whitelisted_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE whitelisted_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: whitelisted_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE whitelisted_hosts_id_seq OWNED BY whitelisted_hosts.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY daily_hit_totals ALTER COLUMN id SET DEFAULT nextval('daily_hit_totals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hits ALTER COLUMN id SET DEFAULT nextval('hits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY host_paths ALTER COLUMN id SET DEFAULT nextval('host_paths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY imported_hits_files ALTER COLUMN id SET DEFAULT nextval('imported_hits_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mappings ALTER COLUMN id SET DEFAULT nextval('mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mappings_batch_entries ALTER COLUMN id SET DEFAULT nextval('mappings_batch_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mappings_batches ALTER COLUMN id SET DEFAULT nextval('mappings_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisational_relationships ALTER COLUMN id SET DEFAULT nextval('organisational_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sites ALTER COLUMN id SET DEFAULT nextval('sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY whitelisted_hosts ALTER COLUMN id SET DEFAULT nextval('whitelisted_hosts_id_seq'::regclass);


--
-- Name: daily_hit_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY daily_hit_totals
    ADD CONSTRAINT daily_hit_totals_pkey PRIMARY KEY (id);


--
-- Name: hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hits
    ADD CONSTRAINT hits_pkey PRIMARY KEY (id);


--
-- Name: host_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY host_paths
    ADD CONSTRAINT host_paths_pkey PRIMARY KEY (id);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: imported_hits_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY imported_hits_files
    ADD CONSTRAINT imported_hits_files_pkey PRIMARY KEY (id);


--
-- Name: mappings_batch_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mappings_batch_entries
    ADD CONSTRAINT mappings_batch_entries_pkey PRIMARY KEY (id);


--
-- Name: mappings_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mappings_batches
    ADD CONSTRAINT mappings_batches_pkey PRIMARY KEY (id);


--
-- Name: mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mappings
    ADD CONSTRAINT mappings_pkey PRIMARY KEY (id);


--
-- Name: organisational_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organisational_relationships
    ADD CONSTRAINT organisational_relationships_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: whitelisted_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY whitelisted_hosts
    ADD CONSTRAINT whitelisted_hosts_pkey PRIMARY KEY (id);


--
-- Name: index_daily_hit_totals_on_host_id_and_total_on_and_http_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_daily_hit_totals_on_host_id_and_total_on_and_http_status ON daily_hit_totals USING btree (host_id, total_on, http_status);


--
-- Name: index_hits_on_host_id_and_hit_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hits_on_host_id_and_hit_on ON hits USING btree (host_id, hit_on);


--
-- Name: index_hits_on_host_id_and_http_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hits_on_host_id_and_http_status ON hits USING btree (host_id, http_status);


--
-- Name: index_hits_on_host_id_and_path_and_hit_on_and_http_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_hits_on_host_id_and_path_and_hit_on_and_http_status ON hits USING btree (host_id, path, hit_on, http_status);


--
-- Name: index_hits_on_mapping_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hits_on_mapping_id ON hits USING btree (mapping_id);


--
-- Name: index_host_paths_on_c14n_path_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_host_paths_on_c14n_path_hash ON host_paths USING btree (c14n_path_hash);


--
-- Name: index_host_paths_on_host_id_and_path_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_host_paths_on_host_id_and_path_hash ON host_paths USING btree (host_id, path_hash);


--
-- Name: index_host_paths_on_mapping_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_host_paths_on_mapping_id ON host_paths USING btree (mapping_id);


--
-- Name: index_hosts_on_canonical_host_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_canonical_host_id ON hosts USING btree (canonical_host_id);


--
-- Name: index_hosts_on_host; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_hosts_on_host ON hosts USING btree (hostname);


--
-- Name: index_hosts_on_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hosts_on_site_id ON hosts USING btree (site_id);


--
-- Name: index_imported_hits_files_on_filename; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_imported_hits_files_on_filename ON imported_hits_files USING btree (filename);


--
-- Name: index_mappings_batch_entries_on_mappings_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mappings_batch_entries_on_mappings_batch_id ON mappings_batch_entries USING btree (mappings_batch_id);


--
-- Name: index_mappings_batches_on_user_id_and_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mappings_batches_on_user_id_and_site_id ON mappings_batches USING btree (user_id, site_id);


--
-- Name: index_mappings_on_hit_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mappings_on_hit_count ON mappings USING btree (hit_count);


--
-- Name: index_mappings_on_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mappings_on_site_id ON mappings USING btree (site_id);


--
-- Name: index_mappings_on_site_id_and_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mappings_on_site_id_and_path ON mappings USING btree (site_id, path);


--
-- Name: index_mappings_on_site_id_and_path_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mappings_on_site_id_and_path_hash ON mappings USING btree (site_id, path_hash);


--
-- Name: index_mappings_on_site_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mappings_on_site_id_and_type ON mappings USING btree (site_id, type);


--
-- Name: index_organisational_relationships_on_child_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organisational_relationships_on_child_organisation_id ON organisational_relationships USING btree (child_organisation_id);


--
-- Name: index_organisational_relationships_on_parent_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organisational_relationships_on_parent_organisation_id ON organisational_relationships USING btree (parent_organisation_id);


--
-- Name: index_organisations_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organisations_on_title ON organisations USING btree (title);


--
-- Name: index_organisations_on_whitehall_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organisations_on_whitehall_slug ON organisations USING btree (whitehall_slug);


--
-- Name: index_organisations_sites_on_site_id_and_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organisations_sites_on_site_id_and_organisation_id ON organisations_sites USING btree (site_id, organisation_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_sites_on_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sites_on_organisation_id ON sites USING btree (organisation_id);


--
-- Name: index_sites_on_site; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sites_on_site ON sites USING btree (abbr);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_whitelisted_hosts_on_hostname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_whitelisted_hosts_on_hostname ON whitelisted_hosts USING btree (hostname);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130910133049');

INSERT INTO schema_migrations (version) VALUES ('20130910135517');

INSERT INTO schema_migrations (version) VALUES ('20130913124740');

INSERT INTO schema_migrations (version) VALUES ('20130918110810');

INSERT INTO schema_migrations (version) VALUES ('20130925162249');

INSERT INTO schema_migrations (version) VALUES ('20130926082808');

INSERT INTO schema_migrations (version) VALUES ('20130927131427');

INSERT INTO schema_migrations (version) VALUES ('20131010115334');

INSERT INTO schema_migrations (version) VALUES ('20131010140146');

INSERT INTO schema_migrations (version) VALUES ('20131018160637');

INSERT INTO schema_migrations (version) VALUES ('20131023082026');

INSERT INTO schema_migrations (version) VALUES ('20131104141642');

INSERT INTO schema_migrations (version) VALUES ('20131106102619');

INSERT INTO schema_migrations (version) VALUES ('20131107192158');

INSERT INTO schema_migrations (version) VALUES ('20131107202738');

INSERT INTO schema_migrations (version) VALUES ('20131108121241');

INSERT INTO schema_migrations (version) VALUES ('20131112133657');

INSERT INTO schema_migrations (version) VALUES ('20131127140136');

INSERT INTO schema_migrations (version) VALUES ('20131127164943');

INSERT INTO schema_migrations (version) VALUES ('20131128120152');

INSERT INTO schema_migrations (version) VALUES ('20131128150000');

INSERT INTO schema_migrations (version) VALUES ('20131128155022');

INSERT INTO schema_migrations (version) VALUES ('20131202093544');

INSERT INTO schema_migrations (version) VALUES ('20131202174921');

INSERT INTO schema_migrations (version) VALUES ('20131203102650');

INSERT INTO schema_migrations (version) VALUES ('20131203115518');

INSERT INTO schema_migrations (version) VALUES ('20131231133153');

INSERT INTO schema_migrations (version) VALUES ('20140127151418');

INSERT INTO schema_migrations (version) VALUES ('20140127151419');

INSERT INTO schema_migrations (version) VALUES ('20140225152616');

INSERT INTO schema_migrations (version) VALUES ('20140225161453');

INSERT INTO schema_migrations (version) VALUES ('20140225175741');

INSERT INTO schema_migrations (version) VALUES ('20140227154306');

INSERT INTO schema_migrations (version) VALUES ('20140227154752');

INSERT INTO schema_migrations (version) VALUES ('20140228173250');

INSERT INTO schema_migrations (version) VALUES ('20140228174448');

INSERT INTO schema_migrations (version) VALUES ('20140331115315');

INSERT INTO schema_migrations (version) VALUES ('20140331121029');

INSERT INTO schema_migrations (version) VALUES ('20140404112839');

INSERT INTO schema_migrations (version) VALUES ('20140417100412');

INSERT INTO schema_migrations (version) VALUES ('20140422160500');

INSERT INTO schema_migrations (version) VALUES ('20140422184036');

INSERT INTO schema_migrations (version) VALUES ('20140502114341');

INSERT INTO schema_migrations (version) VALUES ('20140502160711');

INSERT INTO schema_migrations (version) VALUES ('20140507103006');

INSERT INTO schema_migrations (version) VALUES ('20140515135431');

INSERT INTO schema_migrations (version) VALUES ('20140520154514');

INSERT INTO schema_migrations (version) VALUES ('20140523100338');

INSERT INTO schema_migrations (version) VALUES ('20140528161617');

INSERT INTO schema_migrations (version) VALUES ('20140529130515');

INSERT INTO schema_migrations (version) VALUES ('20140529164329');

INSERT INTO schema_migrations (version) VALUES ('20140606155408');

INSERT INTO schema_migrations (version) VALUES ('20140611144610');

INSERT INTO schema_migrations (version) VALUES ('20140613165318');

INSERT INTO schema_migrations (version) VALUES ('20140618092821');

INSERT INTO schema_migrations (version) VALUES ('20140618145219');

INSERT INTO schema_migrations (version) VALUES ('20140623135055');

INSERT INTO schema_migrations (version) VALUES ('20140625132230');

INSERT INTO schema_migrations (version) VALUES ('20140708144520');

INSERT INTO schema_migrations (version) VALUES ('20140724164511');

INSERT INTO schema_migrations (version) VALUES ('20140815095728');

INSERT INTO schema_migrations (version) VALUES ('20140911113424');

INSERT INTO schema_migrations (version) VALUES ('20140912150755');

INSERT INTO schema_migrations (version) VALUES ('20140922152625');

INSERT INTO schema_migrations (version) VALUES ('20140924105220');

INSERT INTO schema_migrations (version) VALUES ('20140925104317');

INSERT INTO schema_migrations (version) VALUES ('20141031104246');

INSERT INTO schema_migrations (version) VALUES ('20141103110325');

INSERT INTO schema_migrations (version) VALUES ('20141103111339');

INSERT INTO schema_migrations (version) VALUES ('20141103142639');


