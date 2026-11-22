-- DDL corrigido para PostgreSQL
CREATE TABLE public.fornecedor (
 id_fornecedor int4 NOT NULL, 
 razao_social varchar(255) NOT NULL,
 CONSTRAINT fornecedor_pkey PRIMARY KEY (id_fornecedor));

CREATE TABLE public.produtos_filial (
 filial_id int4 NOT NULL, 
 produto_id varchar(25) NOT NULL, 
 descricao varchar(255) NOT NULL,
 estoque numeric(14,3) DEFAULT 0 NOT NULL, 
 preco_unitario numeric(12, 4) DEFAULT 0 NOT NULL,
 preco_compra numeric(12, 4) DEFAULT 0 NOT NULL, 
 preco_venda numeric(12, 4) DEFAULT 0 NOT NULL,
 id_fornecedor int4 NULL,
 CONSTRAINT fk_produtos_fornecedor FOREIGN KEY (id_fornecedor)
  REFERENCES public.fornecedor (id_fornecedor),
 CONSTRAINT produtos_filial_pkey PRIMARY KEY (filial_id, produto_id));

CREATE TABLE public.venda (
 venda_id int8 NOT NULL,
 data_emissao date NOT NULL,
 horariomov time NOT NULL,
 produto_id varchar(25) NOT NULL,
 qtde_vendida numeric(14,3) NULL,
 valor_unitario numeric(12, 4) DEFAULT 0 NOT NULL,
 filial_id int4 NOT NULL,
 item int8 NOT NULL,
 unidade_medida varchar(3) NULL,
 CONSTRAINT venda_pkey PRIMARY KEY (filial_id, venda_id, data_emissao, produto_id, item, horariomov),
 CONSTRAINT fk_venda_produto FOREIGN KEY (filial_id, produto_id)
  REFERENCES public.produtos_filial (filial_id, produto_id));

CREATE TABLE public.pedido_compra (
 pedido_id int8 NOT NULL,
 data_pedido date NULL,
 item int8 NOT NULL,
 produto_id varchar(25) NOT NULL,
 ordem_compra int8 NOT NULL,
 qtde_pedida numeric(14,3) NULL,
 filial_id int4 NOT NULL,
 data_entrega date NULL,
 qtde_entregue numeric(14,3) DEFAULT 0 NOT NULL,
 qtde_pendente numeric(14,3) DEFAULT 0 NOT NULL,
 preco_compra numeric(12,4) NULL,
 id_fornecedor int4 NULL,
 CONSTRAINT uq_pedido_ordem UNIQUE (ordem_compra, produto_id, item, filial_id),
 CONSTRAINT pedido_compra_pkey PRIMARY KEY (pedido_id, produto_id, item),
 CONSTRAINT fk_pedido_fornecedor FOREIGN KEY (id_fornecedor)
  REFERENCES public.fornecedor (id_fornecedor),
 CONSTRAINT fk_pedido_produto FOREIGN KEY (filial_id, produto_id)
  REFERENCES public.produtos_filial (filial_id, produto_id));

CREATE TABLE public.entradas_mercadoria (
 data_entrada date NULL,
 nro_nfe varchar(255) NOT NULL,
 item int8 NOT NULL,
 produto_id varchar(25) NOT NULL,
 qtde_recebida numeric(14,3) NULL,
 custo_unitario numeric(12, 4) DEFAULT 0 NOT NULL,
 ordem_compra int8 NOT NULL,
 filial_id int4 NOT NULL,
 CONSTRAINT entradas_mercadoria_pkey PRIMARY KEY (ordem_compra, item, produto_id, nro_nfe),
 CONSTRAINT fk_entrada_produto FOREIGN KEY (filial_id, produto_id)
  REFERENCES public.produtos_filial (filial_id, produto_id),
 CONSTRAINT fk_entrada_compra FOREIGN KEY (ordem_compra, produto_id, item, filial_id)
  REFERENCES public.pedido_compra (ordem_compra, produto_id, item, filial_id));
