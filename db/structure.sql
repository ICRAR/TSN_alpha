--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
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
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


--
-- Name: upsert_alliances_sel_id_set_created_at_a_credit_a_id_1565721813(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_alliances_sel_id_set_created_at_a_credit_a_id_1565721813(id_sel integer, created_at_set character varying, credit_set integer, id_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "alliances" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "credit" = "credit_set", "id" = "id_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "alliances"("created_at", "credit", "id", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "credit_set", "id_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_alliances_sel_id_set_created_at_a_id_a_rank_a_3663847193(integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_alliances_sel_id_set_created_at_a_id_a_rank_a_3663847193(id_sel integer, created_at_set character varying, id_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "alliances" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "alliances"("created_at", "id", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_alliances_sel_id_set_created_at_a_id_a_ranking1386808332(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_alliances_sel_id_set_created_at_a_id_a_ranking1386808332(id_sel integer, created_at_set character varying, id_set integer, ranking_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "alliances" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "ranking" = "ranking_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "alliances"("created_at", "id", "ranking", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", "ranking_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_boinc_stats_items_sel_boinc_id_set_boinc_id_a_466734959(integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_boinc_stats_items_sel_boinc_id_set_boinc_id_a_466734959(boinc_id_sel integer, boinc_id_set integer, created_at_set character varying, credit_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "boinc_stats_items" SET "boinc_id" = "boinc_id_set", "created_at" = CAST("created_at_set" AS timestamp without time zone), "credit" = "credit_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "boinc_id" = "boinc_id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "boinc_stats_items"("boinc_id", "created_at", "credit", "updated_at") VALUES ("boinc_id_set", CAST("created_at_set" AS timestamp without time zone), "credit_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_boinc_stats_items_sel_boinc_id_set_boinc_id_a_credit(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_boinc_stats_items_sel_boinc_id_set_boinc_id_a_credit(boinc_id_sel integer, boinc_id_set integer, credit_set integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "boinc_stats_items" SET "boinc_id" = "boinc_id_set", "credit" = "credit_set"
                WHERE "boinc_id" = "boinc_id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "boinc_stats_items"("boinc_id", "credit") VALUES ("boinc_id_set", "credit_set");
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_boinc_stats_items_sel_boinc_id_set_rac_a_boinc493652726(integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_boinc_stats_items_sel_boinc_id_set_rac_a_boinc493652726(boinc_id_sel integer, "RAC_set" integer, boinc_id_set integer, created_at_set character varying, credit_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "boinc_stats_items" SET "RAC" = "RAC_set", "boinc_id" = "boinc_id_set", "created_at" = CAST("created_at_set" AS timestamp without time zone), "credit" = "credit_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "boinc_id" = "boinc_id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "boinc_stats_items"("RAC", "boinc_id", "created_at", "credit", "updated_at") VALUES ("RAC_set", "boinc_id_set", CAST("created_at_set" AS timestamp without time zone), "credit_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_general_stats_items_sel_id_set_created_at_a_id1344156864(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_general_stats_items_sel_id_set_created_at_a_id1344156864(id_sel integer, created_at_set character varying, id_set integer, rank_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "general_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "rank" = "rank_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "general_stats_items"("created_at", "id", "rank", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", "rank_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_general_stats_items_sel_id_set_created_at_a_id1345086872(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_general_stats_items_sel_id_set_created_at_a_id1345086872(id_sel integer, created_at_set character varying, id_set integer, last_trophy_credit_value_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "general_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "last_trophy_credit_value" = "last_trophy_credit_value_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "general_stats_items"("created_at", "id", "last_trophy_credit_value", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", "last_trophy_credit_value_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_general_stats_items_sel_id_set_created_at_a_id148520188(integer, character varying, integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_general_stats_items_sel_id_set_created_at_a_id148520188(id_sel integer, created_at_set character varying, id_set integer, recent_avg_credit_set integer, total_credit_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "general_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "recent_avg_credit" = "recent_avg_credit_set", "total_credit" = "total_credit_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "general_stats_items"("created_at", "id", "recent_avg_credit", "total_credit", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", "recent_avg_credit_set", "total_credit_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_general_stats_items_sel_id_set_created_at_a_id4172225045(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_general_stats_items_sel_id_set_created_at_a_id4172225045(id_sel integer, created_at_set character varying, id_set integer, total_credit_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "general_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "id" = "id_set", "total_credit" = "total_credit_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "id" = "id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "general_stats_items"("created_at", "id", "total_credit", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "id_set", "total_credit_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_nereus_stats_items_sel_nereus_id_set_created_a4012556711(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_nereus_stats_items_sel_nereus_id_set_created_a4012556711(nereus_id_sel integer, created_at_set character varying, credit_set integer, nereus_id_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "nereus_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "credit" = "credit_set", "nereus_id" = "nereus_id_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "nereus_id" = "nereus_id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "nereus_stats_items"("created_at", "credit", "nereus_id", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "credit_set", "nereus_id_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


--
-- Name: upsert_nereus_stats_items_sel_nereus_id_set_created_a4167488404(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION upsert_nereus_stats_items_sel_nereus_id_set_created_a4167488404(nereus_id_sel integer, created_at_set character varying, daily_credit_set integer, nereus_id_set integer, updated_at_set character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
          DECLARE
            first_try INTEGER := 1;
          BEGIN
            LOOP
              -- first try to update the key
              UPDATE "nereus_stats_items" SET "created_at" = CAST("created_at_set" AS timestamp without time zone), "daily_credit" = "daily_credit_set", "nereus_id" = "nereus_id_set", "updated_at" = CAST("updated_at_set" AS timestamp without time zone)
                WHERE "nereus_id" = "nereus_id_sel";
              IF found THEN
                RETURN;
              END IF;
              -- not there, so try to insert the key
              -- if someone else inserts the same key concurrently,
              -- we could get a unique-key failure
              BEGIN
                INSERT INTO "nereus_stats_items"("created_at", "daily_credit", "nereus_id", "updated_at") VALUES (CAST("created_at_set" AS timestamp without time zone), "daily_credit_set", "nereus_id_set", CAST("updated_at_set" AS timestamp without time zone));
                RETURN;
              EXCEPTION WHEN unique_violation THEN
                -- seamusabshere 9/20/12 only retry once
                IF (first_try = 1) THEN
                  first_try := 0;
                ELSE
                  RETURN;
                END IF;
                -- Do nothing, and loop to try the UPDATE again.
              END;
            END LOOP;
          END;
          $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alliances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE alliances (
    id integer NOT NULL,
    name character varying(255),
    ranking integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    credit integer
);


--
-- Name: alliances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE alliances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alliances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE alliances_id_seq OWNED BY alliances.id;


--
-- Name: boinc_stats_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE boinc_stats_items (
    id integer NOT NULL,
    boinc_id integer,
    credit integer,
    "RAC" integer,
    rank integer,
    general_stats_item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: boinc_stats_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE boinc_stats_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: boinc_stats_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE boinc_stats_items_id_seq OWNED BY boinc_stats_items.id;


--
-- Name: ckeditor_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ckeditor_assets (
    id integer NOT NULL,
    data_file_name character varying(255) NOT NULL,
    data_content_type character varying(255),
    data_file_size integer,
    assetable_id integer,
    assetable_type character varying(30),
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ckeditor_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ckeditor_assets_id_seq OWNED BY ckeditor_assets.id;


--
-- Name: general_stats_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE general_stats_items (
    id integer NOT NULL,
    total_credit integer,
    recent_avg_credit integer,
    rank integer,
    profile_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_trophy_credit_value integer DEFAULT 0 NOT NULL
);


--
-- Name: general_stats_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE general_stats_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: general_stats_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE general_stats_items_id_seq OWNED BY general_stats_items.id;


--
-- Name: nereus_stats_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nereus_stats_items (
    id integer NOT NULL,
    nereus_id integer,
    credit integer,
    daily_credit integer,
    rank integer,
    general_stats_item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: nereus_stats_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nereus_stats_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nereus_stats_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nereus_stats_items_id_seq OWNED BY nereus_stats_items.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE news (
    id integer NOT NULL,
    title character varying(255),
    short text,
    long text,
    published boolean,
    published_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE news_id_seq OWNED BY news.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    title character varying(255),
    content text,
    slug character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id integer NOT NULL,
    first_name character varying(255),
    second_name character varying(255),
    country character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    alliance_id integer,
    alliance_leader_id integer,
    alliance_join_date timestamp without time zone,
    new_profile_step integer DEFAULT 0 NOT NULL
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: profiles_trophies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles_trophies (
    trophy_id integer,
    profile_id integer
);


--
-- Name: rails_admin_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rails_admin_histories (
    id integer NOT NULL,
    message text,
    username character varying(255),
    item integer,
    "table" character varying(255),
    month smallint,
    year bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rails_admin_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rails_admin_histories_id_seq OWNED BY rails_admin_histories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: trophies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trophies (
    id integer NOT NULL,
    title character varying(255),
    "desc" text,
    credits integer,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trophies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trophies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trophies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trophies_id_seq OWNED BY trophies.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    mod boolean DEFAULT false NOT NULL
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alliances ALTER COLUMN id SET DEFAULT nextval('alliances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY boinc_stats_items ALTER COLUMN id SET DEFAULT nextval('boinc_stats_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ckeditor_assets ALTER COLUMN id SET DEFAULT nextval('ckeditor_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY general_stats_items ALTER COLUMN id SET DEFAULT nextval('general_stats_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nereus_stats_items ALTER COLUMN id SET DEFAULT nextval('nereus_stats_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY news ALTER COLUMN id SET DEFAULT nextval('news_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rails_admin_histories ALTER COLUMN id SET DEFAULT nextval('rails_admin_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trophies ALTER COLUMN id SET DEFAULT nextval('trophies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: alliances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY alliances
    ADD CONSTRAINT alliances_pkey PRIMARY KEY (id);


--
-- Name: boinc_stats_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY boinc_stats_items
    ADD CONSTRAINT boinc_stats_items_pkey PRIMARY KEY (id);


--
-- Name: ckeditor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ckeditor_assets
    ADD CONSTRAINT ckeditor_assets_pkey PRIMARY KEY (id);


--
-- Name: general_stats_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY general_stats_items
    ADD CONSTRAINT general_stats_items_pkey PRIMARY KEY (id);


--
-- Name: nereus_stats_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nereus_stats_items
    ADD CONSTRAINT nereus_stats_items_pkey PRIMARY KEY (id);


--
-- Name: news_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: rails_admin_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rails_admin_histories
    ADD CONSTRAINT rails_admin_histories_pkey PRIMARY KEY (id);


--
-- Name: trophies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trophies
    ADD CONSTRAINT trophies_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_ckeditor_assetable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_ckeditor_assetable ON ckeditor_assets USING btree (assetable_type, assetable_id);


--
-- Name: idx_ckeditor_assetable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_ckeditor_assetable_type ON ckeditor_assets USING btree (assetable_type, type, assetable_id);


--
-- Name: index_profiles_trophies_on_profile_id_and_trophy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_profiles_trophies_on_profile_id_and_trophy_id ON profiles_trophies USING btree (profile_id, trophy_id);


--
-- Name: index_profiles_trophies_on_trophy_id_and_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_profiles_trophies_on_trophy_id_and_profile_id ON profiles_trophies USING btree (trophy_id, profile_id);


--
-- Name: index_rails_admin_histories; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rails_admin_histories ON rails_admin_histories USING btree (item, "table", month, year);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130305062419');

INSERT INTO schema_migrations (version) VALUES ('20130305080950');

INSERT INTO schema_migrations (version) VALUES ('20130305081358');

INSERT INTO schema_migrations (version) VALUES ('20130305164432');

INSERT INTO schema_migrations (version) VALUES ('20130306024457');

INSERT INTO schema_migrations (version) VALUES ('20130306072134');

INSERT INTO schema_migrations (version) VALUES ('20130307013623');

INSERT INTO schema_migrations (version) VALUES ('20130307015620');

INSERT INTO schema_migrations (version) VALUES ('20130307054435');

INSERT INTO schema_migrations (version) VALUES ('20130308032335');

INSERT INTO schema_migrations (version) VALUES ('20130308032745');

INSERT INTO schema_migrations (version) VALUES ('20130311071230');

INSERT INTO schema_migrations (version) VALUES ('20130311071347');

INSERT INTO schema_migrations (version) VALUES ('20130314041051');

INSERT INTO schema_migrations (version) VALUES ('20130315063205');

INSERT INTO schema_migrations (version) VALUES ('20130319015844');

INSERT INTO schema_migrations (version) VALUES ('20130319073328');

INSERT INTO schema_migrations (version) VALUES ('20130319073329');

INSERT INTO schema_migrations (version) VALUES ('20130319075654');

INSERT INTO schema_migrations (version) VALUES ('20130322062339');

INSERT INTO schema_migrations (version) VALUES ('20130422034513');