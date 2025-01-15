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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: daily_hit_totals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_hit_totals (
    id bigint NOT NULL,
    host_id integer NOT NULL,
    http_status character varying(3) NOT NULL,
    count integer NOT NULL,
    total_on date NOT NULL
);


--
-- Name: daily_hit_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_hit_totals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: daily_hit_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_hit_totals_id_seq OWNED BY public.daily_hit_totals.id;


--
-- Name: hits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hits (
    id bigint NOT NULL,
    host_id integer NOT NULL,
    path character varying(2048) NOT NULL,
    http_status character varying(3) NOT NULL,
    count integer NOT NULL,
    hit_on date NOT NULL,
    mapping_id integer
);


--
-- Name: hits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hits_id_seq OWNED BY public.hits.id;


--
-- Name: hits_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hits_staging (
    hostname text,
    path text,
    http_status character varying(3),
    count integer,
    hit_on date
);


--
-- Name: host_paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host_paths (
    id bigint NOT NULL,
    path character varying(2048),
    host_id integer,
    mapping_id integer,
    canonical_path character varying(2048)
);


--
-- Name: host_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.host_paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: host_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.host_paths_id_seq OWNED BY public.host_paths.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hosts (
    id bigint NOT NULL,
    site_id integer NOT NULL,
    hostname text NOT NULL,
    ttl integer,
    cname character varying(255),
    live_cname character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ip_address character varying(255),
    canonical_host_id integer
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hosts_id_seq OWNED BY public.hosts.id;


--
-- Name: imported_hits_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imported_hits_files (
    id bigint NOT NULL,
    filename character varying(255),
    content_hash character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: imported_hits_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imported_hits_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imported_hits_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imported_hits_files_id_seq OWNED BY public.imported_hits_files.id;


--
-- Name: mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mappings (
    id bigint NOT NULL,
    site_id integer NOT NULL,
    path character varying(2048) NOT NULL,
    new_url text,
    suggested_url text,
    archive_url text,
    from_redirector boolean DEFAULT false,
    type character varying(255) NOT NULL,
    hit_count integer
);


--
-- Name: mappings_batch_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mappings_batch_entries (
    id bigint NOT NULL,
    path character varying(2048),
    mappings_batch_id integer,
    mapping_id integer,
    processed boolean DEFAULT false,
    klass character varying(255),
    new_url text,
    type character varying(255),
    archive_url text
);


--
-- Name: mappings_batch_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mappings_batch_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_batch_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mappings_batch_entries_id_seq OWNED BY public.mappings_batch_entries.id;


--
-- Name: mappings_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mappings_batches (
    id bigint NOT NULL,
    tag_list character varying(255),
    new_url character varying(2048),
    update_existing boolean,
    user_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255) DEFAULT 'unqueued'::character varying,
    seen_outcome boolean DEFAULT false,
    type character varying(255),
    klass character varying(255)
);


--
-- Name: mappings_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mappings_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mappings_batches_id_seq OWNED BY public.mappings_batches.id;


--
-- Name: mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mappings_id_seq OWNED BY public.mappings.id;


--
-- Name: organisational_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisational_relationships (
    id bigint NOT NULL,
    parent_organisation_id integer,
    child_organisation_id integer
);


--
-- Name: organisational_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organisational_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisational_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organisational_relationships_id_seq OWNED BY public.organisational_relationships.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    homepage character varying(255),
    furl character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    css character varying(255),
    ga_profile_id character varying(16),
    whitehall_slug character varying(255),
    whitehall_type character varying(255),
    abbreviation character varying(255),
    content_id character varying(255) NOT NULL
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organisations_id_seq OWNED BY public.organisations.id;


--
-- Name: organisations_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations_sites (
    site_id integer NOT NULL,
    organisation_id integer NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    organisation_id integer NOT NULL,
    abbr character varying(255),
    query_params character varying(255),
    tna_timestamp timestamp without time zone NOT NULL,
    homepage character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    global_new_url text,
    launch_date date,
    special_redirect_strategy character varying(255),
    global_redirect_append_path boolean DEFAULT false NOT NULL,
    global_type character varying(255),
    homepage_title character varying(255),
    homepage_furl character varying(255),
    precompute_all_hits_view boolean DEFAULT false NOT NULL,
    alternative_archive_text: text,
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id bigint NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying(255),
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255),
    email character varying(255),
    uid character varying(255),
    permissions text,
    remotely_signed_out boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organisation_slug character varying(255),
    is_robot boolean DEFAULT false,
    disabled boolean DEFAULT false,
    organisation_content_id character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    object jsonb,
    object_changes jsonb
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: whitelisted_hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.whitelisted_hosts (
    id bigint NOT NULL,
    hostname text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: whitelisted_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.whitelisted_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: whitelisted_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.whitelisted_hosts_id_seq OWNED BY public.whitelisted_hosts.id;


--
-- Name: daily_hit_totals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_hit_totals ALTER COLUMN id SET DEFAULT nextval('public.daily_hit_totals_id_seq'::regclass);


--
-- Name: hits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hits ALTER COLUMN id SET DEFAULT nextval('public.hits_id_seq'::regclass);


--
-- Name: host_paths id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_paths ALTER COLUMN id SET DEFAULT nextval('public.host_paths_id_seq'::regclass);


--
-- Name: hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts ALTER COLUMN id SET DEFAULT nextval('public.hosts_id_seq'::regclass);


--
-- Name: imported_hits_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_hits_files ALTER COLUMN id SET DEFAULT nextval('public.imported_hits_files_id_seq'::regclass);


--
-- Name: mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings ALTER COLUMN id SET DEFAULT nextval('public.mappings_id_seq'::regclass);


--
-- Name: mappings_batch_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings_batch_entries ALTER COLUMN id SET DEFAULT nextval('public.mappings_batch_entries_id_seq'::regclass);


--
-- Name: mappings_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings_batches ALTER COLUMN id SET DEFAULT nextval('public.mappings_batches_id_seq'::regclass);


--
-- Name: organisational_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisational_relationships ALTER COLUMN id SET DEFAULT nextval('public.organisational_relationships_id_seq'::regclass);


--
-- Name: organisations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations ALTER COLUMN id SET DEFAULT nextval('public.organisations_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: whitelisted_hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.whitelisted_hosts ALTER COLUMN id SET DEFAULT nextval('public.whitelisted_hosts_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: daily_hit_totals daily_hit_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_hit_totals
    ADD CONSTRAINT daily_hit_totals_pkey PRIMARY KEY (id);


--
-- Name: hits hits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hits
    ADD CONSTRAINT hits_pkey PRIMARY KEY (id);


--
-- Name: host_paths host_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_paths
    ADD CONSTRAINT host_paths_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: imported_hits_files imported_hits_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_hits_files
    ADD CONSTRAINT imported_hits_files_pkey PRIMARY KEY (id);


--
-- Name: mappings_batch_entries mappings_batch_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings_batch_entries
    ADD CONSTRAINT mappings_batch_entries_pkey PRIMARY KEY (id);


--
-- Name: mappings_batches mappings_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings_batches
    ADD CONSTRAINT mappings_batches_pkey PRIMARY KEY (id);


--
-- Name: mappings mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mappings
    ADD CONSTRAINT mappings_pkey PRIMARY KEY (id);


--
-- Name: organisational_relationships organisational_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisational_relationships
    ADD CONSTRAINT organisational_relationships_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: whitelisted_hosts whitelisted_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.whitelisted_hosts
    ADD CONSTRAINT whitelisted_hosts_pkey PRIMARY KEY (id);


--
-- Name: index_daily_hit_totals_on_host_id_and_total_on_and_http_status; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_daily_hit_totals_on_host_id_and_total_on_and_http_status ON public.daily_hit_totals USING btree (host_id, total_on, http_status);


--
-- Name: index_hits_on_host_id_and_hit_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hits_on_host_id_and_hit_on ON public.hits USING btree (host_id, hit_on);


--
-- Name: index_hits_on_host_id_and_http_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hits_on_host_id_and_http_status ON public.hits USING btree (host_id, http_status);


--
-- Name: index_hits_on_host_id_and_path_and_hit_on_and_http_status; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hits_on_host_id_and_path_and_hit_on_and_http_status ON public.hits USING btree (host_id, path, hit_on, http_status);


--
-- Name: index_hits_on_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hits_on_mapping_id ON public.hits USING btree (mapping_id);


--
-- Name: index_host_paths_on_canonical_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_paths_on_canonical_path ON public.host_paths USING btree (canonical_path);


--
-- Name: index_host_paths_on_host_id_and_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_host_paths_on_host_id_and_path ON public.host_paths USING btree (host_id, path);


--
-- Name: index_host_paths_on_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_host_paths_on_mapping_id ON public.host_paths USING btree (mapping_id);


--
-- Name: index_hosts_on_canonical_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_canonical_host_id ON public.hosts USING btree (canonical_host_id);


--
-- Name: index_hosts_on_host; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hosts_on_host ON public.hosts USING btree (hostname);


--
-- Name: index_hosts_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hosts_on_site_id ON public.hosts USING btree (site_id);


--
-- Name: index_imported_hits_files_on_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_imported_hits_files_on_filename ON public.imported_hits_files USING btree (filename);


--
-- Name: index_mappings_batch_entries_on_mappings_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mappings_batch_entries_on_mappings_batch_id ON public.mappings_batch_entries USING btree (mappings_batch_id);


--
-- Name: index_mappings_batches_on_user_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mappings_batches_on_user_id_and_site_id ON public.mappings_batches USING btree (user_id, site_id);


--
-- Name: index_mappings_on_hit_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mappings_on_hit_count ON public.mappings USING btree (hit_count);


--
-- Name: index_mappings_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mappings_on_site_id ON public.mappings USING btree (site_id);


--
-- Name: index_mappings_on_site_id_and_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mappings_on_site_id_and_path ON public.mappings USING btree (site_id, path);


--
-- Name: index_mappings_on_site_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mappings_on_site_id_and_type ON public.mappings USING btree (site_id, type);


--
-- Name: index_organisational_relationships_on_child_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisational_relationships_on_child_organisation_id ON public.organisational_relationships USING btree (child_organisation_id);


--
-- Name: index_organisational_relationships_on_parent_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisational_relationships_on_parent_organisation_id ON public.organisational_relationships USING btree (parent_organisation_id);


--
-- Name: index_organisations_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organisations_on_content_id ON public.organisations USING btree (content_id);


--
-- Name: index_organisations_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_title ON public.organisations USING btree (title);


--
-- Name: index_organisations_on_whitehall_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organisations_on_whitehall_slug ON public.organisations USING btree (whitehall_slug);


--
-- Name: index_organisations_sites_on_site_id_and_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organisations_sites_on_site_id_and_organisation_id ON public.organisations_sites USING btree (site_id, organisation_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_sites_on_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_organisation_id ON public.sites USING btree (organisation_id);


--
-- Name: index_sites_on_site; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sites_on_site ON public.sites USING btree (abbr);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON public.taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_whitelisted_hosts_on_hostname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_whitelisted_hosts_on_hostname ON public.whitelisted_hosts USING btree (hostname);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20231212143730'),
('20231020093533'),
('20231017095753'),
('20221020085112'),
('20161111172455'),
('20160314150053'),
('20160314150052'),
('20150715141152'),
('20150429154045'),
('20150428155430'),
('20150423102347'),
('20150421161957'),
('20150421161752'),
('20150320164433'),
('20141120164444'),
('20141119113045'),
('20141118121300'),
('20141118112125'),
('20141114110930'),
('20141113115152'),
('20141111093926'),
('20141103142639'),
('20141103111339'),
('20141103110325'),
('20141031104246'),
('20140925104317'),
('20140924105220'),
('20140922152625'),
('20140912150755'),
('20140911113424'),
('20140815095728'),
('20140724164511'),
('20140708144520'),
('20140625132230'),
('20140623135055'),
('20140618145219'),
('20140618092821'),
('20140613165318'),
('20140611144610'),
('20140606155408'),
('20140529164329'),
('20140529130515'),
('20140528161617'),
('20140523100338'),
('20140520154514'),
('20140515135431'),
('20140507103006'),
('20140502160711'),
('20140502114341'),
('20140422184036'),
('20140422160500'),
('20140417100412'),
('20140404112839'),
('20140331121029'),
('20140331115315'),
('20140228174448'),
('20140228173250'),
('20140227154752'),
('20140227154306'),
('20140225175741'),
('20140225161453'),
('20140225152616'),
('20140127151419'),
('20140127151418'),
('20131231133153'),
('20131203115518'),
('20131203102650'),
('20131202174921'),
('20131202093544'),
('20131128155022'),
('20131128150000'),
('20131128120152'),
('20131127164943'),
('20131127140136'),
('20131112133657'),
('20131108121241'),
('20131107202738'),
('20131107192158'),
('20131106102619'),
('20131104141642'),
('20131023082026'),
('20131018160637'),
('20131010140146'),
('20131010115334'),
('20130927131427'),
('20130926082808'),
('20130925162249'),
('20130918110810'),
('20130913124740'),
('20130910135517'),
('20130910133049');



