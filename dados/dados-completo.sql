--
-- PostgreSQL database dump
--

\restrict bfkiFJOC6DgW317sneRuSjXz07rb5II3hvaxBcE3qM6hkBxOaL6faKN211wCFUc

-- Dumped from database version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)

-- Started on 2026-11-22 10:10:49 -04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 223 (class 1259 OID 16582)
-- Name: entradas_mercadoria; Type: TABLE; Schema: public; Owner: andw
--

CREATE TABLE public.entradas_mercadoria (
    data_entrada date,
    nro_nfe character varying(255) NOT NULL,
    item bigint NOT NULL,
    produto_id character varying(25) NOT NULL,
    qtde_recebida numeric(14,3),
    custo_unitario numeric(12,4) DEFAULT 0 NOT NULL,
    ordem_compra bigint NOT NULL,
    filial_id integer NOT NULL
);


ALTER TABLE public.entradas_mercadoria OWNER TO andw;

--
-- TOC entry 220 (class 1259 OID 16528)
-- Name: fornecedor; Type: TABLE; Schema: public; Owner: andw
--

CREATE TABLE public.fornecedor (
    id_fornecedor integer NOT NULL,
    razao_social character varying(255) NOT NULL
);


ALTER TABLE public.fornecedor OWNER TO andw;

--
-- TOC entry 222 (class 1259 OID 16556)
-- Name: pedido_compra; Type: TABLE; Schema: public; Owner: andw
--

CREATE TABLE public.pedido_compra (
    pedido_id bigint NOT NULL,
    data_pedido date,
    item bigint NOT NULL,
    produto_id character varying(25) NOT NULL,
    ordem_compra bigint NOT NULL,
    qtde_pedida numeric(14,3),
    filial_id integer NOT NULL,
    data_entrega date,
    qtde_entregue numeric(14,3) DEFAULT 0 NOT NULL,
    qtde_pendente numeric(14,3) DEFAULT 0 NOT NULL,
    preco_compra numeric(12,4),
    id_fornecedor integer
);


ALTER TABLE public.pedido_compra OWNER TO andw;

--
-- TOC entry 221 (class 1259 OID 16535)
-- Name: produtos_filial; Type: TABLE; Schema: public; Owner: andw
--

CREATE TABLE public.produtos_filial (
    filial_id integer NOT NULL,
    produto_id character varying(25) NOT NULL,
    descricao character varying(255) NOT NULL,
    estoque numeric(14,3) DEFAULT 0 NOT NULL,
    preco_unitario numeric(12,4) DEFAULT 0 NOT NULL,
    preco_compra numeric(12,4) DEFAULT 0 NOT NULL,
    preco_venda numeric(12,4) DEFAULT 0 NOT NULL,
    id_fornecedor integer
);


ALTER TABLE public.produtos_filial OWNER TO andw;

--
-- TOC entry 219 (class 1259 OID 16402)
-- Name: venda; Type: TABLE; Schema: public; Owner: andw
--

CREATE TABLE public.venda (
    venda_id bigint NOT NULL,
    data_emissao date NOT NULL,
    horariomov character varying(8) DEFAULT '00:00:00'::character varying NOT NULL,
    produto_id character varying(25) DEFAULT ''::character varying NOT NULL,
    qtde_vendida double precision,
    valor_unitario numeric(12,4) DEFAULT 0 NOT NULL,
    filial_id bigint DEFAULT 1 NOT NULL,
    item integer DEFAULT 0 NOT NULL,
    unidade_medida character varying(3)
);


ALTER TABLE public.venda OWNER TO andw;

--
-- TOC entry 3523 (class 0 OID 16582)
-- Dependencies: 223
-- Data for Name: entradas_mercadoria; Type: TABLE DATA; Schema: public; Owner: andw
--

COPY public.entradas_mercadoria (data_entrada, nro_nfe, item, produto_id, qtde_recebida, custo_unitario, ordem_compra, filial_id) FROM stdin;
2025-02-27	NFE1	1	1	77.000	8435.0000	1	1
2025-01-20	NFE2	1	2	64.000	1666.0000	2	1
2025-02-18	NFE3	1	3	88.000	9036.0000	3	1
2025-02-12	NFE4	1	4	4.000	8468.0000	4	1
2025-02-19	NFE5	1	5	95.000	9899.0000	5	1
2025-02-08	NFE6	1	6	41.000	9029.0000	6	1
2025-01-03	NFE7	1	7	75.000	2722.0000	7	1
2025-02-21	NFE8	1	8	25.000	711.0000	8	1
2025-02-13	NFE9	1	9	57.000	1955.0000	9	1
2025-03-01	NFE10	1	10	7.000	5439.0000	10	1
2025-01-23	NFE11	1	11	85.000	9189.0000	11	1
2025-01-02	NFE12	1	12	12.000	3853.0000	12	1
2025-02-20	NFE13	1	13	7.000	6086.0000	13	1
2025-01-10	NFE14	1	14	92.000	3848.0000	14	1
2025-01-13	NFE15	1	15	68.000	9558.0000	15	1
2025-01-22	NFE16	1	16	89.000	3946.0000	16	1
2025-02-24	NFE17	1	17	10.000	1032.0000	17	1
2025-01-31	NFE18	1	18	48.000	6256.0000	18	1
2025-02-13	NFE19	1	19	64.000	8454.0000	19	1
2025-01-01	NFE20	1	20	6.000	657.0000	20	1
\.


--
-- TOC entry 3520 (class 0 OID 16528)
-- Dependencies: 220
-- Data for Name: fornecedor; Type: TABLE DATA; Schema: public; Owner: andw
--

COPY public.fornecedor (id_fornecedor, razao_social) FROM stdin;
1	Fornecedor 1 LTDA
2	Fornecedor 2 LTDA
3	Fornecedor 3 LTDA
4	Fornecedor 4 LTDA
5	Fornecedor 5 LTDA
6	Fornecedor 6 LTDA
7	Fornecedor 7 LTDA
8	Fornecedor 8 LTDA
9	Fornecedor 9 LTDA
10	Fornecedor 10 LTDA
11	Fornecedor 11 LTDA
12	Fornecedor 12 LTDA
13	Fornecedor 13 LTDA
14	Fornecedor 14 LTDA
15	Fornecedor 15 LTDA
16	Fornecedor 16 LTDA
17	Fornecedor 17 LTDA
18	Fornecedor 18 LTDA
19	Fornecedor 19 LTDA
20	Fornecedor 20 LTDA
\.


--
-- TOC entry 3522 (class 0 OID 16556)
-- Dependencies: 222
-- Data for Name: pedido_compra; Type: TABLE DATA; Schema: public; Owner: andw
--

COPY public.pedido_compra (pedido_id, data_pedido, item, produto_id, ordem_compra, qtde_pedida, filial_id, data_entrega, qtde_entregue, qtde_pendente, preco_compra, id_fornecedor) FROM stdin;
1	2025-01-02	1	1	1	96.000	1	2025-02-27	10.000	86.000	4667.0000	1
2	2025-01-07	1	2	2	14.000	1	2025-01-07	7.000	7.000	7732.0000	2
3	2025-01-05	1	3	3	12.000	1	2025-01-03	2.000	10.000	4782.0000	3
4	2025-01-22	1	4	4	27.000	1	2025-01-28	3.000	24.000	4957.0000	4
5	2025-01-28	1	5	5	35.000	1	2025-02-28	12.000	23.000	5718.0000	5
6	2025-02-22	1	6	6	98.000	1	2025-01-05	55.000	43.000	5996.0000	6
7	2025-03-01	1	7	7	34.000	1	2025-02-01	29.000	5.000	4922.0000	7
8	2025-02-02	1	8	8	29.000	1	2025-02-14	24.000	5.000	3588.0000	8
9	2025-01-15	1	9	9	57.000	1	2025-01-28	34.000	23.000	2848.0000	9
10	2025-01-09	1	10	10	49.000	1	2025-02-09	4.000	45.000	4286.0000	10
11	2025-02-22	1	11	11	24.000	1	2025-01-08	12.000	12.000	1482.0000	11
12	2025-02-25	1	12	12	91.000	1	2025-02-20	48.000	43.000	692.0000	12
13	2025-02-23	1	13	13	99.000	1	2025-02-02	91.000	8.000	6544.0000	13
14	2025-01-21	1	14	14	96.000	1	2025-01-01	27.000	69.000	2191.0000	14
15	2025-02-04	1	15	15	45.000	1	2025-01-04	1.000	44.000	8504.0000	15
16	2025-02-27	1	16	16	84.000	1	2025-01-14	51.000	33.000	6417.0000	16
17	2025-01-08	1	17	17	22.000	1	2025-01-19	7.000	15.000	7455.0000	17
18	2025-02-17	1	18	18	63.000	1	2025-01-02	17.000	46.000	2494.0000	18
19	2025-02-19	1	19	19	20.000	1	2025-01-08	0.000	20.000	2221.0000	19
20	2025-02-10	1	20	20	25.000	1	2025-01-15	0.000	25.000	3851.0000	20
\.


--
-- TOC entry 3521 (class 0 OID 16535)
-- Dependencies: 221
-- Data for Name: produtos_filial; Type: TABLE DATA; Schema: public; Owner: andw
--

COPY public.produtos_filial (filial_id, produto_id, descricao, estoque, preco_unitario, preco_compra, preco_venda, id_fornecedor) FROM stdin;
1	1	Produto 1	88.000	4265.0000	14413.0000	4079.0000	8
1	2	Produto 2	28.000	7952.0000	10356.0000	17418.0000	9
1	3	Produto 3	40.000	1195.0000	2414.0000	6069.0000	10
1	4	Produto 4	73.000	8967.0000	775.0000	2265.0000	11
1	5	Produto 5	97.000	13599.0000	3618.0000	8992.0000	12
1	6	Produto 6	38.000	16131.0000	5537.0000	956.0000	13
1	7	Produto 7	131.000	15382.0000	1404.0000	4664.0000	7
1	8	Produto 8	71.000	14057.0000	1495.0000	9528.0000	17
1	9	Produto 9	2.000	3088.0000	137.0000	16432.0000	18
1	10	Produto 10	38.000	11571.0000	2777.0000	877.0000	19
1	11	Produto 11	154.000	14799.0000	2939.0000	4495.0000	1
1	12	Produto 12	78.000	3247.0000	6463.0000	27658.0000	2
1	13	Produto 13	79.000	19404.0000	583.0000	9905.0000	3
1	14	Produto 14	9.000	19956.0000	568.0000	8074.0000	4
1	15	Produto 15	131.000	10115.0000	1076.0000	2924.0000	5
1	16	Produto 16	177.000	2464.0000	7594.0000	27888.0000	6
1	17	Produto 17	105.000	19563.0000	12625.0000	18392.0000	7
1	18	Produto 18	198.000	1622.0000	13412.0000	10561.0000	18
1	19	Produto 19	148.000	18436.0000	12169.0000	23458.0000	19
1	20	Produto 20	196.000	5204.0000	12487.0000	15793.0000	20
\.


--
-- TOC entry 3519 (class 0 OID 16402)
-- Dependencies: 219
-- Data for Name: venda; Type: TABLE DATA; Schema: public; Owner: andw
--

COPY public.venda (venda_id, data_emissao, horariomov, produto_id, qtde_vendida, valor_unitario, filial_id, item, unidade_medida) FROM stdin;
1	2025-01-11	08:00:00	1	5	7893.0000	1	1	UN
2	2025-03-02	08:00:00	2	7	9296.0000	1	1	UN
3	2025-01-28	08:00:00	3	9	19761.0000	1	1	UN
4	2025-01-10	08:00:00	4	39	13971.0000	1	1	UN
5	2025-01-11	08:00:00	5	3	12679.0000	1	1	UN
6	2025-01-24	08:00:00	6	2	3683.0000	1	1	UN
7	2025-02-22	08:00:00	7	5	4075.0000	1	1	UN
8	2025-01-26	08:00:00	8	20	5137.0000	1	1	UN
9	2025-01-17	08:00:00	9	6	17255.0000	1	1	UN
10	2025-01-03	08:00:00	10	90	4422.0000	1	1	UN
11	2025-01-08	08:00:00	11	6	19037.0000	1	1	UN
12	2025-01-21	08:00:00	12	3	1364.0000	1	1	UN
13	2025-01-24	08:00:00	13	13	6185.0000	1	1	UN
14	2025-02-07	08:00:00	14	53	1063.0000	1	1	UN
15	2025-02-20	08:00:00	15	27	434.0000	1	1	UN
16	2025-02-17	08:00:00	16	37	1441.0000	1	1	UN
17	2025-02-22	08:00:00	17	3	1398.0000	1	1	UN
18	2025-02-18	08:00:00	18	5	18523.0000	1	1	UN
19	2025-02-20	08:00:00	19	10	18251.0000	1	1	UN
20	2025-02-28	08:00:00	20	2	6854.0000	1	1	UN
\.


--
-- TOC entry 3366 (class 2606 OID 16593)
-- Name: entradas_mercadoria entradas_mercadoria_pkey; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.entradas_mercadoria
    ADD CONSTRAINT entradas_mercadoria_pkey PRIMARY KEY (ordem_compra, item, produto_id, nro_nfe);


--
-- TOC entry 3358 (class 2606 OID 16534)
-- Name: fornecedor fornecedor_pkey; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.fornecedor
    ADD CONSTRAINT fornecedor_pkey PRIMARY KEY (id_fornecedor);


--
-- TOC entry 3362 (class 2606 OID 16569)
-- Name: pedido_compra pedido_compra_pkey; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.pedido_compra
    ADD CONSTRAINT pedido_compra_pkey PRIMARY KEY (pedido_id, produto_id, item);


--
-- TOC entry 3356 (class 2606 OID 16420)
-- Name: venda pk_consumo; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT pk_consumo PRIMARY KEY (filial_id, venda_id, data_emissao, produto_id, item, horariomov);


--
-- TOC entry 3360 (class 2606 OID 16550)
-- Name: produtos_filial produtos_filial_pkey; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.produtos_filial
    ADD CONSTRAINT produtos_filial_pkey PRIMARY KEY (filial_id, produto_id);


--
-- TOC entry 3364 (class 2606 OID 16571)
-- Name: pedido_compra uq_pedido_ordem; Type: CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.pedido_compra
    ADD CONSTRAINT uq_pedido_ordem UNIQUE (ordem_compra, produto_id, item, filial_id);


--
-- TOC entry 3370 (class 2606 OID 16599)
-- Name: entradas_mercadoria fk_entrada_compra; Type: FK CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.entradas_mercadoria
    ADD CONSTRAINT fk_entrada_compra FOREIGN KEY (ordem_compra, produto_id, item, filial_id) REFERENCES public.pedido_compra(ordem_compra, produto_id, item, filial_id);


--
-- TOC entry 3371 (class 2606 OID 16594)
-- Name: entradas_mercadoria fk_entrada_produto; Type: FK CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.entradas_mercadoria
    ADD CONSTRAINT fk_entrada_produto FOREIGN KEY (filial_id, produto_id) REFERENCES public.produtos_filial(filial_id, produto_id);


--
-- TOC entry 3368 (class 2606 OID 16572)
-- Name: pedido_compra fk_pedido_fornecedor; Type: FK CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.pedido_compra
    ADD CONSTRAINT fk_pedido_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES public.fornecedor(id_fornecedor);


--
-- TOC entry 3369 (class 2606 OID 16577)
-- Name: pedido_compra fk_pedido_produto; Type: FK CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.pedido_compra
    ADD CONSTRAINT fk_pedido_produto FOREIGN KEY (filial_id, produto_id) REFERENCES public.produtos_filial(filial_id, produto_id);


--
-- TOC entry 3367 (class 2606 OID 16551)
-- Name: produtos_filial fk_produtos_fornecedor; Type: FK CONSTRAINT; Schema: public; Owner: andw
--

ALTER TABLE ONLY public.produtos_filial
    ADD CONSTRAINT fk_produtos_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES public.fornecedor(id_fornecedor);


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO andw;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-11-22 10:10:49 -04

--
-- PostgreSQL database dump complete
--

\unrestrict bfkiFJOC6DgW317sneRuSjXz07rb5II3hvaxBcE3qM6hkBxOaL6faKN211wCFUc

