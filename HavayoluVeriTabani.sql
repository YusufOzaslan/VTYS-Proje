--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 14.0

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

--
-- Name: YolcuListele(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."YolcuListele"() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    yolcular "Yolcu"%ROWTYPE;
    ekran TEXT;
BEGIN
    ekran := '';
    FOR yolcular IN SELECT * FROM "Yolcu" LOOP
        ekran := ekran || yolcular."yolcuID" ||  E'\t' || yolcular."isim" || E'\t' || yolcular."soyisim" || E'\r\n';
    END LOOP;
    RETURN ekran;
END;
$$;


ALTER FUNCTION public."YolcuListele"() OWNER TO postgres;

--
-- Name: biletAra(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."biletAra"("bilet_Id" integer) RETURNS TABLE("Uçuş Sınıfı" character varying, "Fiyat" money)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "ucusSinifi", "fiyat" FROM "Bilet"
                 WHERE "biletID" = "bilet_Id";
END;
$$;


ALTER FUNCTION public."biletAra"("bilet_Id" integer) OWNER TO postgres;

--
-- Name: koltukKontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."koltukKontrol"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."koltukNumarasi" IS NULL THEN
        RAISE EXCEPTION 'Koltuk numarası alanı boş olamaz';  
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."koltukKontrol"() OWNER TO postgres;

--
-- Name: rezervasyonSayisi(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."rezervasyonSayisi"("ucus_Id" integer, "rez_No" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    rezSayi INTEGER;
BEGIN

    SELECT count(*) INTO rezSayi
    FROM "Rezervasyon"
    WHERE "ucusNo" = $1
    AND "rezID" = $2
    AND "ucusVarMi"("ucus_Id");
    
    RETURN rezSayi;
    
END $_$;


ALTER FUNCTION public."rezervasyonSayisi"("ucus_Id" integer, "rez_No" integer) OWNER TO postgres;

--
-- Name: tarihEkle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."tarihEkle"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."rezervasyonTarihi" = CURRENT_DATE;
    RETURN NEW;
END $$;


ALTER FUNCTION public."tarihEkle"() OWNER TO postgres;

--
-- Name: telefonKontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."telefonKontrol"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF length(NEW.telefon) <> 10 THEN
        RAISE EXCEPTION 'Telefon Numarası 10 hane olmalı';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."telefonKontrol"() OWNER TO postgres;

--
-- Name: ucusVarMi(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."ucusVarMi"("ucus_Id" integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    ucusSayi INTEGER;
BEGIN

    SELECT count(*) INTO ucusSayi
    FROM "Ucus"
    WHERE "ucus_Id" = "ucusID";

    IF ucusSayi = 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $$;


ALTER FUNCTION public."ucusVarMi"("ucus_Id" integer) OWNER TO postgres;

--
-- Name: yolcuEkle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."yolcuEkle"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   INSERT INTO "EskiYolcular"("eskiYolcuID", "sehirNo", "isim", "soyisim", "telefon", "mail")
    VALUES(OLD."yolcuID", OLD."sehirNo", OLD."isim", OLD."soyisim", OLD."telefon", OLD."mail");

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."yolcuEkle"() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Bilet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bilet" (
    "biletID" integer NOT NULL,
    "ucusSinifi" character varying NOT NULL,
    fiyat money NOT NULL
);


ALTER TABLE public."Bilet" OWNER TO postgres;

--
-- Name: EskiYolcular; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EskiYolcular" (
    "eskiYolcuID" integer NOT NULL,
    "sehirNo" integer NOT NULL,
    isim character varying NOT NULL,
    soyisim character varying NOT NULL,
    telefon character(10) NOT NULL,
    mail character varying
);


ALTER TABLE public."EskiYolcular" OWNER TO postgres;

--
-- Name: Hangar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hangar" (
    "hangarID" integer NOT NULL,
    "limanNo" integer NOT NULL,
    metrekare integer NOT NULL
);


ALTER TABLE public."Hangar" OWNER TO postgres;

--
-- Name: HangardakiUcak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HangardakiUcak" (
    "huID" integer NOT NULL,
    "ucakNo" integer NOT NULL,
    "hangarNo" integer NOT NULL,
    "ucakSayisi" integer NOT NULL
);


ALTER TABLE public."HangardakiUcak" OWNER TO postgres;

--
-- Name: HavaLimani; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HavaLimani" (
    "limanID" integer NOT NULL,
    "sehirNo" integer NOT NULL,
    "havalimaniAdi" character varying NOT NULL
);


ALTER TABLE public."HavaLimani" OWNER TO postgres;

--
-- Name: HavaYoluFirmasi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HavaYoluFirmasi" (
    "havaYoluID" integer NOT NULL,
    "sehirNo" integer NOT NULL,
    "firmaAdi" character varying NOT NULL
);


ALTER TABLE public."HavaYoluFirmasi" OWNER TO postgres;

--
-- Name: InisLiman; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InisLiman" (
    "inisID" integer NOT NULL,
    "limanNo" integer NOT NULL
);


ALTER TABLE public."InisLiman" OWNER TO postgres;

--
-- Name: KabinMemuru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."KabinMemuru" (
    "kmID" integer NOT NULL,
    "personelNo" integer NOT NULL,
    "ucakNo" integer NOT NULL,
    maas money NOT NULL
);


ALTER TABLE public."KabinMemuru" OWNER TO postgres;

--
-- Name: KalkisLiman; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."KalkisLiman" (
    "kalkisID" integer NOT NULL,
    "limanNo" integer NOT NULL
);


ALTER TABLE public."KalkisLiman" OWNER TO postgres;

--
-- Name: Personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Personel" (
    "personelID" integer NOT NULL,
    "firmaNo" integer NOT NULL,
    telefon integer NOT NULL,
    adi character varying NOT NULL,
    soyadi character varying NOT NULL,
    "iseBaslamaTarihi" date NOT NULL
);


ALTER TABLE public."Personel" OWNER TO postgres;

--
-- Name: Pilot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Pilot" (
    "pilotID" integer NOT NULL,
    "personelNo" integer NOT NULL,
    "ucakNo" integer NOT NULL,
    maas money NOT NULL
);


ALTER TABLE public."Pilot" OWNER TO postgres;

--
-- Name: Rezervasyon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Rezervasyon" (
    "rezID" integer NOT NULL,
    "yolcuNo" integer NOT NULL,
    "ucusNo" integer NOT NULL,
    "biletNo" integer NOT NULL,
    "ucusTarihi" date NOT NULL,
    "koltukNumarasi" integer,
    "rezervasyonTarihi" date NOT NULL
);


ALTER TABLE public."Rezervasyon" OWNER TO postgres;

--
-- Name: Sehir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sehir" (
    "sehirID" integer NOT NULL,
    "ulkeNo" integer NOT NULL,
    "sehirAdi" character varying NOT NULL
);


ALTER TABLE public."Sehir" OWNER TO postgres;

--
-- Name: Ucak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ucak" (
    "ucakID" integer NOT NULL,
    "firmaNo" integer NOT NULL,
    "yolcuKapasitesi" integer NOT NULL,
    "ucakModeli" integer NOT NULL,
    "ucakOmru(yil)" integer NOT NULL
);


ALTER TABLE public."Ucak" OWNER TO postgres;

--
-- Name: Ucus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ucus" (
    "ucusID" integer NOT NULL,
    "firmaNo" integer NOT NULL,
    "inisLimanNo" integer NOT NULL,
    "kalkisLimanNo" integer NOT NULL,
    "kalkisSaati" timestamp with time zone NOT NULL,
    "varisSaati" timestamp with time zone NOT NULL,
    "ucakNo" integer NOT NULL
);


ALTER TABLE public."Ucus" OWNER TO postgres;

--
-- Name: Ulke; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ulke" (
    "ulkeID" integer NOT NULL,
    "ulkeAdi" character varying NOT NULL
);


ALTER TABLE public."Ulke" OWNER TO postgres;

--
-- Name: YedekParca; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."YedekParca" (
    "yedekID" integer NOT NULL,
    "limanNo" integer NOT NULL,
    "parcaSayisi" integer,
    "ucakNo" integer NOT NULL
);


ALTER TABLE public."YedekParca" OWNER TO postgres;

--
-- Name: YerHizmetleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."YerHizmetleri" (
    "yhID" integer NOT NULL,
    maas money NOT NULL,
    "limanNo" integer NOT NULL,
    "personelNo" integer NOT NULL
);


ALTER TABLE public."YerHizmetleri" OWNER TO postgres;

--
-- Name: Yolcu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Yolcu" (
    "yolcuID" integer NOT NULL,
    isim character varying(40) NOT NULL,
    soyisim character varying(40) NOT NULL,
    telefon character varying(10) NOT NULL,
    mail character varying(40),
    "sehirNo" integer NOT NULL
);


ALTER TABLE public."Yolcu" OWNER TO postgres;

--
-- Name: Yolcu_yolcuID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Yolcu_yolcuID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Yolcu_yolcuID_seq" OWNER TO postgres;

--
-- Name: Yolcu_yolcuID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Yolcu_yolcuID_seq" OWNED BY public."Yolcu"."yolcuID";


--
-- Name: Yonetim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Yonetim" (
    "personelNo" integer NOT NULL,
    maas money NOT NULL,
    "yonetimID" money NOT NULL
);


ALTER TABLE public."Yonetim" OWNER TO postgres;

--
-- Name: Yolcu yolcuID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yolcu" ALTER COLUMN "yolcuID" SET DEFAULT nextval('public."Yolcu_yolcuID_seq"'::regclass);


--
-- Data for Name: Bilet; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Bilet" VALUES
	(1, 'Busniess', '$200.00'),
	(2, 'Economy', '$100.00');


--
-- Data for Name: EskiYolcular; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."EskiYolcular" VALUES
	(35, 47, 'Faruk', 'Balık', '9876543210', 'fff@gmail.com');


--
-- Data for Name: Hangar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Hangar" VALUES
	(1, 1, 25000);


--
-- Data for Name: HangardakiUcak; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."HangardakiUcak" VALUES
	(1, 1, 1, 22);


--
-- Data for Name: HavaLimani; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."HavaLimani" VALUES
	(1, 34, 'Atatürk havalimanı');


--
-- Data for Name: HavaYoluFirmasi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."HavaYoluFirmasi" VALUES
	(1, 1, 'THY');


--
-- Data for Name: InisLiman; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."InisLiman" VALUES
	(1, 1);


--
-- Data for Name: KabinMemuru; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."KabinMemuru" VALUES
	(1, 1, 1, '$10,000.00');


--
-- Data for Name: KalkisLiman; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."KalkisLiman" VALUES
	(1, 1);


--
-- Data for Name: Personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Personel" VALUES
	(1, 1, -30009, 'isim', 'soyisim', '2021-12-16');


--
-- Data for Name: Pilot; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Rezervasyon; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Rezervasyon" VALUES
	(2, 16, 1, 1, '2021-12-16', 12, '2021-12-16'),
	(1, 16, 1, 1, '2021-12-16', 11, '2021-12-16');


--
-- Data for Name: Sehir; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Sehir" VALUES
	(1, 1, 'Adana'),
	(54, 1, 'Sakarya'),
	(34, 1, 'İstanbul'),
	(6, 1, 'Ankara'),
	(21, 1, 'Diyarbakır'),
	(103, 3, 'Londra'),
	(104, 4, 'Paris'),
	(105, 5, 'Moskova'),
	(106, 6, 'Pekin'),
	(107, 7, 'Tahran'),
	(108, 8, 'Ottava'),
	(109, 9, 'Madrid'),
	(110, 10, 'Kahire'),
	(47, 2, 'Berlin');


--
-- Data for Name: Ucak; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Ucak" VALUES
	(1, 1, 0, 0, 0),
	(2, 1, 2, 2, 2);


--
-- Data for Name: Ucus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Ucus" VALUES
	(2, 1, 1, 1, '2021-12-16 16:19:56+03', '2021-12-16 16:19:16+03', 1),
	(1, 1, 1, 1, '2021-12-16 16:19:56+03', '2021-12-16 16:19:56+03', 1);


--
-- Data for Name: Ulke; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Ulke" VALUES
	(1, 'Türkiye'),
	(2, 'Almanya'),
	(3, 'İngiltere'),
	(4, 'Fransa'),
	(5, 'Rusya'),
	(6, 'Çin'),
	(7, 'İran'),
	(8, 'Kanada'),
	(9, 'İspanya'),
	(10, 'Mısır');


--
-- Data for Name: YedekParca; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."YedekParca" VALUES
	(1, 1, NULL, 1),
	(2, 1, NULL, 2);


--
-- Data for Name: YerHizmetleri; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Yolcu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Yolcu" VALUES
	(16, 'Yusuf', 'Özaslan', '1234567897', 'yusuf.ozaslan@ogr.sakarya.edu.tr', 1);


--
-- Data for Name: Yonetim; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: Yolcu_yolcuID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Yolcu_yolcuID_seq"', 35, true);


--
-- Name: Bilet Bilet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bilet"
    ADD CONSTRAINT "Bilet_pkey" PRIMARY KEY ("biletID");


--
-- Name: Hangar Hangar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hangar"
    ADD CONSTRAINT "Hangar_pkey" PRIMARY KEY ("hangarID");


--
-- Name: HangardakiUcak HangardakiUcak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HangardakiUcak"
    ADD CONSTRAINT "HangardakiUcak_pkey" PRIMARY KEY ("huID");


--
-- Name: HavaLimani HavaLimani_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HavaLimani"
    ADD CONSTRAINT "HavaLimani_pkey" PRIMARY KEY ("limanID");


--
-- Name: HavaYoluFirmasi HavaYoluFirmasi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HavaYoluFirmasi"
    ADD CONSTRAINT "HavaYoluFirmasi_pkey" PRIMARY KEY ("havaYoluID");


--
-- Name: KabinMemuru KabinMemuru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KabinMemuru"
    ADD CONSTRAINT "KabinMemuru_pkey" PRIMARY KEY ("kmID");


--
-- Name: Personel Personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "Personel_pkey" PRIMARY KEY ("personelID");


--
-- Name: Pilot Pilot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Pilot"
    ADD CONSTRAINT "Pilot_pkey" PRIMARY KEY ("pilotID");


--
-- Name: Rezervasyon Rezervasyon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "Rezervasyon_pkey" PRIMARY KEY ("rezID");


--
-- Name: Sehir Sehir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir"
    ADD CONSTRAINT "Sehir_pkey" PRIMARY KEY ("sehirID");


--
-- Name: Ucak Ucak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucak"
    ADD CONSTRAINT "Ucak_pkey" PRIMARY KEY ("ucakID");


--
-- Name: Ucus Ucus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "Ucus_pkey" PRIMARY KEY ("ucusID");


--
-- Name: Ulke Ulke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ulke"
    ADD CONSTRAINT "Ulke_pkey" PRIMARY KEY ("ulkeID");


--
-- Name: YedekParca YedekParca_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YedekParca"
    ADD CONSTRAINT "YedekParca_pkey" PRIMARY KEY ("yedekID");


--
-- Name: YerHizmetleri YerHizmetleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YerHizmetleri"
    ADD CONSTRAINT "YerHizmetleri_pkey" PRIMARY KEY ("yhID");


--
-- Name: Yolcu YolcuPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yolcu"
    ADD CONSTRAINT "YolcuPK" PRIMARY KEY ("yolcuID");


--
-- Name: Yonetim Yonetim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetim"
    ADD CONSTRAINT "Yonetim_pkey" PRIMARY KEY ("yonetimID");


--
-- Name: Bilet unique_Bilet_biletID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bilet"
    ADD CONSTRAINT "unique_Bilet_biletID" UNIQUE ("biletID");


--
-- Name: EskiYolcular unique_EskiYolcular_eskiYolcuID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EskiYolcular"
    ADD CONSTRAINT "unique_EskiYolcular_eskiYolcuID" PRIMARY KEY ("eskiYolcuID");


--
-- Name: Hangar unique_Hangar_hangarID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hangar"
    ADD CONSTRAINT "unique_Hangar_hangarID" UNIQUE ("hangarID");


--
-- Name: HangardakiUcak unique_HangardakiUcak_limanID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HangardakiUcak"
    ADD CONSTRAINT "unique_HangardakiUcak_limanID" UNIQUE ("huID");


--
-- Name: HavaYoluFirmasi unique_HavaYoluFirmasi_havaYoluID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HavaYoluFirmasi"
    ADD CONSTRAINT "unique_HavaYoluFirmasi_havaYoluID" UNIQUE ("havaYoluID");


--
-- Name: InisLiman unique_InisLiman_inisID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InisLiman"
    ADD CONSTRAINT "unique_InisLiman_inisID" PRIMARY KEY ("inisID");


--
-- Name: KabinMemuru unique_KabinMemuru_kmID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KabinMemuru"
    ADD CONSTRAINT "unique_KabinMemuru_kmID" UNIQUE ("kmID");


--
-- Name: KalkisLiman unique_KalkisLiman_kalkisID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KalkisLiman"
    ADD CONSTRAINT "unique_KalkisLiman_kalkisID" PRIMARY KEY ("kalkisID");


--
-- Name: Personel unique_Personel_newField; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "unique_Personel_newField" UNIQUE ("personelID");


--
-- Name: Pilot unique_Pilot_pilotID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Pilot"
    ADD CONSTRAINT "unique_Pilot_pilotID" UNIQUE ("pilotID");


--
-- Name: Rezervasyon unique_Rezervasyon_rezID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "unique_Rezervasyon_rezID" UNIQUE ("rezID");


--
-- Name: Sehir unique_Sehir_sehirID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir"
    ADD CONSTRAINT "unique_Sehir_sehirID" UNIQUE ("sehirID");


--
-- Name: Ucak unique_Ucak_ucakID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucak"
    ADD CONSTRAINT "unique_Ucak_ucakID" UNIQUE ("ucakID");


--
-- Name: Ucus unique_Ucus_ucusID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "unique_Ucus_ucusID" UNIQUE ("ucusID");


--
-- Name: Ulke unique_Ulke_ulkeID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ulke"
    ADD CONSTRAINT "unique_Ulke_ulkeID" UNIQUE ("ulkeID");


--
-- Name: YedekParca unique_YedekParca_yedekID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YedekParca"
    ADD CONSTRAINT "unique_YedekParca_yedekID" UNIQUE ("yedekID");


--
-- Name: YerHizmetleri unique_YerHizmetleri_yhID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YerHizmetleri"
    ADD CONSTRAINT "unique_YerHizmetleri_yhID" UNIQUE ("yhID");


--
-- Name: Yonetim unique_Yonetim_yonetimID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetim"
    ADD CONSTRAINT "unique_Yonetim_yonetimID" UNIQUE ("yonetimID");


--
-- Name: Yolcu eskiYolcular; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "eskiYolcular" AFTER DELETE ON public."Yolcu" FOR EACH ROW EXECUTE FUNCTION public."yolcuEkle"();


--
-- Name: Rezervasyon koltukNoKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "koltukNoKontrol" BEFORE INSERT OR UPDATE ON public."Rezervasyon" FOR EACH ROW EXECUTE FUNCTION public."koltukKontrol"();


--
-- Name: Yolcu telefon_Kontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "telefon_Kontrol" BEFORE INSERT OR UPDATE ON public."Yolcu" FOR EACH ROW EXECUTE FUNCTION public."telefonKontrol"();


--
-- Name: Rezervasyon bilet_rezervasyonFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "bilet_rezervasyonFK" FOREIGN KEY ("biletNo") REFERENCES public."Bilet"("biletID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HangardakiUcak hangar_hangardakiucakFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HangardakiUcak"
    ADD CONSTRAINT "hangar_hangardakiucakFK" FOREIGN KEY ("hangarNo") REFERENCES public."Hangar"("hangarID");


--
-- Name: Hangar havalimani_hangarFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hangar"
    ADD CONSTRAINT "havalimani_hangarFK" FOREIGN KEY ("limanNo") REFERENCES public."HavaLimani"("limanID");


--
-- Name: InisLiman havalimani_inislimanFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InisLiman"
    ADD CONSTRAINT "havalimani_inislimanFK" FOREIGN KEY ("limanNo") REFERENCES public."HavaLimani"("limanID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: KalkisLiman havalimani_kalkislimanFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KalkisLiman"
    ADD CONSTRAINT "havalimani_kalkislimanFK" FOREIGN KEY ("limanNo") REFERENCES public."HavaLimani"("limanID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: YedekParca havalimani_yedekparcaFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YedekParca"
    ADD CONSTRAINT "havalimani_yedekparcaFK" FOREIGN KEY ("limanNo") REFERENCES public."HavaLimani"("limanID");


--
-- Name: YerHizmetleri havalimani_yerhizmetleriFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YerHizmetleri"
    ADD CONSTRAINT "havalimani_yerhizmetleriFK" FOREIGN KEY ("limanNo") REFERENCES public."HavaLimani"("limanID") ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Ucus havayoluFirmasi_ucusFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "havayoluFirmasi_ucusFK" FOREIGN KEY ("firmaNo") REFERENCES public."HavaYoluFirmasi"("havaYoluID") MATCH FULL;


--
-- Name: Personel havayolufirmasi_personelFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "havayolufirmasi_personelFK" FOREIGN KEY ("firmaNo") REFERENCES public."HavaYoluFirmasi"("havaYoluID");


--
-- Name: Ucak havayolufirmasi_ucakFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucak"
    ADD CONSTRAINT "havayolufirmasi_ucakFK" FOREIGN KEY ("firmaNo") REFERENCES public."HavaYoluFirmasi"("havaYoluID");


--
-- Name: Ucus inislimani_ucusFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "inislimani_ucusFK" FOREIGN KEY ("inisLimanNo") REFERENCES public."InisLiman"("inisID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Ucus kalkisliman_ucusFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "kalkisliman_ucusFK" FOREIGN KEY ("kalkisLimanNo") REFERENCES public."KalkisLiman"("kalkisID") MATCH FULL;


--
-- Name: KabinMemuru personel_kabinmemuruFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KabinMemuru"
    ADD CONSTRAINT "personel_kabinmemuruFK" FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Pilot personel_pilotFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Pilot"
    ADD CONSTRAINT "personel_pilotFK" FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: YerHizmetleri personel_yerhizmetleriFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YerHizmetleri"
    ADD CONSTRAINT "personel_yerhizmetleriFK" FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Yonetim personel_yonetimFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetim"
    ADD CONSTRAINT "personel_yonetimFK" FOREIGN KEY ("personelNo") REFERENCES public."Personel"("personelID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EskiYolcular sehir_eskiyolcuFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EskiYolcular"
    ADD CONSTRAINT "sehir_eskiyolcuFK" FOREIGN KEY ("sehirNo") REFERENCES public."Sehir"("sehirID") MATCH FULL;


--
-- Name: HavaLimani sehir_havalimaniFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HavaLimani"
    ADD CONSTRAINT "sehir_havalimaniFK" FOREIGN KEY ("sehirNo") REFERENCES public."Sehir"("sehirID");


--
-- Name: HavaYoluFirmasi sehir_havayolufirmasiFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HavaYoluFirmasi"
    ADD CONSTRAINT "sehir_havayolufirmasiFK" FOREIGN KEY ("sehirNo") REFERENCES public."Sehir"("sehirID");


--
-- Name: Yolcu sehir_yolcuFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yolcu"
    ADD CONSTRAINT "sehir_yolcuFK" FOREIGN KEY ("sehirNo") REFERENCES public."Sehir"("sehirID");


--
-- Name: HangardakiUcak ucak_hangardakiucakFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HangardakiUcak"
    ADD CONSTRAINT "ucak_hangardakiucakFK" FOREIGN KEY ("ucakNo") REFERENCES public."Ucak"("ucakID");


--
-- Name: KabinMemuru ucak_kabinmemuruFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KabinMemuru"
    ADD CONSTRAINT "ucak_kabinmemuruFK" FOREIGN KEY ("ucakNo") REFERENCES public."Ucak"("ucakID") ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Pilot ucak_pilotFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Pilot"
    ADD CONSTRAINT "ucak_pilotFK" FOREIGN KEY ("ucakNo") REFERENCES public."Ucak"("ucakID") ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Ucus ucak_ucusFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ucus"
    ADD CONSTRAINT "ucak_ucusFK" FOREIGN KEY ("ucakNo") REFERENCES public."Ucak"("ucakID") MATCH FULL;


--
-- Name: YedekParca ucak_yedekparcaFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YedekParca"
    ADD CONSTRAINT "ucak_yedekparcaFK" FOREIGN KEY ("ucakNo") REFERENCES public."Ucak"("ucakID");


--
-- Name: Rezervasyon ucus_rezervasyonFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "ucus_rezervasyonFK" FOREIGN KEY ("ucusNo") REFERENCES public."Ucus"("ucusID") MATCH FULL;


--
-- Name: Sehir ulke_sehirFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sehir"
    ADD CONSTRAINT "ulke_sehirFK" FOREIGN KEY ("ulkeNo") REFERENCES public."Ulke"("ulkeID") MATCH FULL;


--
-- Name: Rezervasyon yolcu_rezervasyonFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "yolcu_rezervasyonFK" FOREIGN KEY ("yolcuNo") REFERENCES public."Yolcu"("yolcuID") MATCH FULL ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--

